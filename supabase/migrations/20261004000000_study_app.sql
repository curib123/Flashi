-- Fresh Flashi-specific project. All mutations pass through the verified API.
create table public.credit_wallets (
  user_id uuid primary key references auth.users(id) on delete cascade,
  balance integer not null default 0 check(balance >= 0),
  reserved integer not null default 0 check(reserved >= 0 and reserved <= balance),
  updated_at timestamptz not null default now()
);
create table public.credit_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  delta integer not null,
  reason text not null check(reason in ('welcome','ai_generation','purchase','verified_reward','adjustment')),
  reference_id uuid not null,
  created_at timestamptz not null default now(),
  unique(user_id,reason,reference_id)
);
create index credit_ledger_user_created_idx on public.credit_ledger(user_id,created_at desc,id);
create table public.generation_jobs (
  user_id uuid not null references auth.users(id) on delete cascade,
  id uuid not null,
  request_hash text not null,
  request_metadata jsonb not null,
  cost integer not null check(cost between 1 and 10),
  model text not null default 'gpt-5.6-luna' check(model='gpt-5.6-luna'),
  status text not null default 'processing' check(status in ('processing','completed','failed')),
  result jsonb,
  error_code text,
  expires_at timestamptz not null default (now()+interval '5 minutes'),
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  primary key(user_id,id)
);
create index generation_jobs_user_created_idx on public.generation_jobs(user_id,created_at desc);
create table public.study_uploads (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  path text not null unique,
  filename text not null,
  mime_type text not null,
  byte_size integer not null check(byte_size between 1 and 10485760),
  created_at timestamptz not null default now()
);
create index study_uploads_owner_idx on public.study_uploads(user_id,created_at);
create sequence public.study_change_seq;
create table public.study_entities (
  user_id uuid not null references auth.users(id) on delete cascade,
  id uuid not null,
  entity_type text not null check(entity_type in ('set','subject','attempt')),
  revision integer not null default 1,
  change_seq bigint not null default nextval('public.study_change_seq'),
  deleted boolean not null default false,
  payload jsonb,
  updated_at timestamptz not null default now(),
  primary key(user_id,id),
  check((deleted and payload is null) or (not deleted and payload is not null))
);
create index study_entities_sync_idx on public.study_entities(user_id,change_seq);
create table public.api_rate_limits (
  key text primary key,
  hits integer not null default 1,
  reset_at timestamptz not null
);

alter table public.credit_wallets enable row level security;
alter table public.credit_ledger enable row level security;
alter table public.generation_jobs enable row level security;
alter table public.study_uploads enable row level security;
alter table public.study_entities enable row level security;
alter table public.api_rate_limits enable row level security;
revoke all on public.credit_wallets,public.credit_ledger,public.generation_jobs,public.study_uploads,public.study_entities,public.api_rate_limits from public,anon,authenticated;
revoke all on sequence public.study_change_seq from public,anon,authenticated;
grant all on public.credit_wallets,public.credit_ledger,public.generation_jobs,public.study_uploads,public.study_entities,public.api_rate_limits to service_role;
grant usage,select on sequence public.study_change_seq to service_role;

create function public.ensure_credit_wallet(p_user_id uuid,p_initial integer) returns void
language plpgsql security invoker set search_path='' as $$
declare created uuid;
begin
  if p_initial < 0 or p_initial > 10000 then raise exception 'invalid_initial_credits'; end if;
  insert into public.credit_wallets(user_id,balance) values(p_user_id,p_initial)
    on conflict(user_id) do nothing returning user_id into created;
  if created is not null then
    insert into public.credit_ledger(user_id,delta,reason,reference_id) values(p_user_id,p_initial,'welcome',p_user_id);
  end if;
end; $$;

create function public.reap_generation_jobs() returns integer
language plpgsql security invoker set search_path='' as $$
declare u uuid; j record; released integer:=0;
begin
  for u in select distinct user_id from public.generation_jobs where status='processing' and expires_at < now() loop
    perform 1 from public.credit_wallets where user_id=u for update;
    for j in select id,cost from public.generation_jobs where user_id=u and status='processing' and expires_at < now() for update loop
      update public.credit_wallets set reserved=reserved-j.cost,updated_at=now() where user_id=u;
      update public.generation_jobs set status='failed',error_code='generation_expired',completed_at=now() where user_id=u and id=j.id;
      released:=released+1;
    end loop;
  end loop;
  delete from public.api_rate_limits where reset_at < now()-interval '1 day';
  return released;
end; $$;

create function public.begin_generation(p_user_id uuid,p_id uuid,p_hash text,p_cost integer,p_metadata jsonb,p_hour_limit integer) returns jsonb
language plpgsql security invoker set search_path='' as $$
declare w public.credit_wallets; j public.generation_jobs; old record;
begin
  select * into w from public.credit_wallets where user_id=p_user_id for update;
  if not found then raise exception 'wallet_missing'; end if;
  -- Recover this user's abandoned jobs without acquiring other users' locks.
  for old in select id,cost from public.generation_jobs where user_id=p_user_id and status='processing' and expires_at<now() for update loop
    update public.credit_wallets set reserved=reserved-old.cost where user_id=p_user_id;
    update public.generation_jobs set status='failed',error_code='generation_expired',completed_at=now() where user_id=p_user_id and id=old.id;
  end loop;
  select * into j from public.generation_jobs where user_id=p_user_id and id=p_id;
  if found then
    if j.request_hash<>p_hash then raise exception 'idempotency_conflict'; end if;
    return jsonb_build_object('status',j.status,'result',j.result,'errorCode',j.error_code,'cost',j.cost);
  end if;
  if p_cost<1 or p_cost>10 then raise exception 'invalid_credit_cost'; end if;
  if (select count(*) from public.generation_jobs where user_id=p_user_id and created_at>now()-interval '1 hour')>=p_hour_limit then raise exception 'rate_limited'; end if;
  select * into w from public.credit_wallets where user_id=p_user_id;
  if w.balance-w.reserved<p_cost then raise exception 'insufficient_credits'; end if;
  update public.credit_wallets set reserved=reserved+p_cost,updated_at=now() where user_id=p_user_id;
  insert into public.generation_jobs(user_id,id,request_hash,cost,request_metadata) values(p_user_id,p_id,p_hash,p_cost,p_metadata);
  return jsonb_build_object('status','new','cost',p_cost);
end; $$;

create function public.complete_generation(p_user_id uuid,p_id uuid,p_result jsonb) returns integer
language plpgsql security invoker set search_path='' as $$
declare j public.generation_jobs; remaining integer;
begin
  perform 1 from public.credit_wallets where user_id=p_user_id for update;
  select * into j from public.generation_jobs where user_id=p_user_id and id=p_id for update;
  if not found then raise exception 'generation_missing'; end if;
  if j.status='completed' then return (select balance from public.credit_wallets where user_id=p_user_id); end if;
  if j.status<>'processing' or j.expires_at<now() then raise exception 'generation_expired'; end if;
  if p_result is null then raise exception 'invalid_result'; end if;
  update public.credit_wallets set balance=balance-j.cost,reserved=reserved-j.cost,updated_at=now() where user_id=p_user_id returning balance into remaining;
  insert into public.credit_ledger(user_id,delta,reason,reference_id) values(p_user_id,-j.cost,'ai_generation',p_id);
  update public.generation_jobs set result=p_result,status='completed',completed_at=now() where user_id=p_user_id and id=p_id;
  return remaining;
end; $$;

create function public.fail_generation(p_user_id uuid,p_id uuid,p_error text) returns void
language plpgsql security invoker set search_path='' as $$
declare j public.generation_jobs;
begin
  perform 1 from public.credit_wallets where user_id=p_user_id for update;
  select * into j from public.generation_jobs where user_id=p_user_id and id=p_id for update;
  if found and j.status='processing' then
    update public.credit_wallets set reserved=reserved-j.cost,updated_at=now() where user_id=p_user_id;
    update public.generation_jobs set status='failed',error_code=p_error,completed_at=now() where user_id=p_user_id and id=p_id;
  end if;
end; $$;

-- Reserved for future verified payment/provider callbacks. Never expose a client route.
create function public.grant_credits(p_user_id uuid,p_amount integer,p_reason text,p_event uuid) returns void
language plpgsql security invoker set search_path='' as $$
begin
  if p_amount<1 or p_amount>10000 or p_reason not in ('purchase','verified_reward','adjustment') then raise exception 'invalid_credit_grant'; end if;
  perform 1 from public.credit_wallets where user_id=p_user_id for update;
  if not found then raise exception 'wallet_missing'; end if;
  insert into public.credit_ledger(user_id,delta,reason,reference_id) values(p_user_id,p_amount,p_reason,p_event) on conflict do nothing;
  if found then update public.credit_wallets set balance=balance+p_amount,updated_at=now() where user_id=p_user_id; end if;
end; $$;

create function public.check_rate_limit(p_key text,p_limit integer,p_window integer) returns boolean
language plpgsql security invoker set search_path='' as $$
declare n integer;
begin
  insert into public.api_rate_limits(key,hits,reset_at) values(p_key,1,now()+make_interval(secs=>p_window))
  on conflict(key) do update set hits=case when public.api_rate_limits.reset_at<now() then 1 else public.api_rate_limits.hits+1 end,
    reset_at=case when public.api_rate_limits.reset_at<now() then now()+make_interval(secs=>p_window) else public.api_rate_limits.reset_at end
  returning hits into n;
  return n<=p_limit;
end; $$;

create function public.sync_entities(p_user_id uuid,p_changes jsonb) returns jsonb
language plpgsql security invoker set search_path='' as $$
declare c jsonb; existing public.study_entities; saved public.study_entities; accepted jsonb:='[]'; conflicts jsonb:='[]'; entity_id uuid;
begin
  perform pg_advisory_xact_lock(hashtext(p_user_id::text));
  if jsonb_array_length(p_changes)>100 then raise exception 'sync_batch_too_large'; end if;
  for c in select value from jsonb_array_elements(p_changes) loop
    entity_id:=(c->>'id')::uuid;
    select * into existing from public.study_entities where user_id=p_user_id and id=entity_id for update;
    if (found and (existing.revision<>(c->>'baseRevision')::integer or existing.entity_type<>c->>'entityType')) or (not found and (c->>'baseRevision')::integer<>0) then
      conflicts:=conflicts||jsonb_build_array(jsonb_build_object('id',entity_id,'entityType',coalesce(existing.entity_type,c->>'entityType'),'revision',coalesce(existing.revision,0),'deleted',coalesce(existing.deleted,true),'payload',existing.payload));
      continue;
    end if;
    insert into public.study_entities(user_id,id,entity_type,payload,deleted) values(p_user_id,entity_id,c->>'entityType',case when (c->>'deleted')::boolean then null else c->'payload' end,(c->>'deleted')::boolean)
    on conflict(user_id,id) do update set payload=excluded.payload,deleted=excluded.deleted,revision=public.study_entities.revision+1,change_seq=nextval('public.study_change_seq'),updated_at=now()
    returning * into saved;
    accepted:=accepted||jsonb_build_array(jsonb_build_object('id',saved.id,'revision',saved.revision));
  end loop;
  return jsonb_build_object('accepted',accepted,'conflicts',conflicts);
end; $$;

revoke all on function public.ensure_credit_wallet(uuid,integer),public.reap_generation_jobs(),public.begin_generation(uuid,uuid,text,integer,jsonb,integer),public.complete_generation(uuid,uuid,jsonb),public.fail_generation(uuid,uuid,text),public.grant_credits(uuid,integer,text,uuid),public.check_rate_limit(text,integer,integer),public.sync_entities(uuid,jsonb) from public,anon,authenticated;
grant execute on function public.ensure_credit_wallet(uuid,integer),public.reap_generation_jobs(),public.begin_generation(uuid,uuid,text,integer,jsonb,integer),public.complete_generation(uuid,uuid,jsonb),public.fail_generation(uuid,uuid,text),public.grant_credits(uuid,integer,text,uuid),public.check_rate_limit(text,integer,integer),public.sync_entities(uuid,jsonb) to service_role;
