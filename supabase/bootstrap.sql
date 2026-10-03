create table if not exists public.credit_wallets (
  user_id uuid primary key references auth.users(id) on delete cascade,
  balance integer not null default 10 check (balance >= 0),
  earned_total integer not null default 0 check (earned_total >= 0),
  spent_total integer not null default 0 check (spent_total >= 0),
  updated_at timestamptz not null default now()
);

create table if not exists public.credit_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  delta integer not null,
  reason text not null,
  reference_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists credit_ledger_user_created_idx
  on public.credit_ledger (user_id, created_at desc);

create table if not exists public.generation_jobs (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  source_type text not null check (source_type in ('topic','file','image')),
  quiz_type text not null check (quiz_type in ('multiple_choice','identification','true_false','definition','fill_blank','enumeration')),
  question_count integer not null check (question_count in (10,20,30,40,50)),
  credit_cost integer not null check (credit_cost > 0),
  model text not null default 'gpt-5.6-luna' check (model = 'gpt-5.6-luna'),
  status text not null check (status in ('processing','completed','failed')),
  error_code text,
  created_at timestamptz not null default now(),
  completed_at timestamptz
);

create index if not exists generation_jobs_user_created_idx
  on public.generation_jobs (user_id, created_at desc);

create table if not exists public.reward_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  credit_amount integer not null check (credit_amount > 0),
  status text not null default 'pending' check (status in ('pending','completed','expired')),
  expires_at timestamptz not null default (now() + interval '10 minutes'),
  created_at timestamptz not null default now(),
  completed_at timestamptz
);

create index if not exists reward_sessions_user_created_idx
  on public.reward_sessions (user_id, created_at desc);

alter table public.credit_wallets enable row level security;
alter table public.credit_ledger enable row level security;
alter table public.generation_jobs enable row level security;
alter table public.reward_sessions enable row level security;

revoke all on table public.credit_wallets from anon, authenticated;
revoke all on table public.credit_ledger from anon, authenticated;
revoke all on table public.generation_jobs from anon, authenticated;
revoke all on table public.reward_sessions from anon, authenticated;

grant all on table public.credit_wallets to service_role;
grant all on table public.credit_ledger to service_role;
grant all on table public.generation_jobs to service_role;
grant all on table public.reward_sessions to service_role;

create or replace function public.consume_generation_credits(
  p_user_id uuid, p_cost integer, p_reference_id uuid
)
returns integer
language plpgsql
security invoker
set search_path = public
as $$
declare v_balance integer;
begin
  if p_cost <= 0 then return -1; end if;

  update public.credit_wallets
  set balance = balance - p_cost,
      spent_total = spent_total + p_cost,
      updated_at = now()
  where user_id = p_user_id and balance >= p_cost
  returning balance into v_balance;

  if v_balance is null then return -1; end if;

  insert into public.credit_ledger(user_id, delta, reason, reference_id)
  values (p_user_id, -p_cost, 'ai_generation', p_reference_id);

  return v_balance;
end;
$$;

create or replace function public.refund_generation_credits(
  p_user_id uuid, p_cost integer, p_reference_id uuid
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
begin
  update public.credit_wallets
  set balance = balance + p_cost,
      spent_total = greatest(spent_total - p_cost, 0),
      updated_at = now()
  where user_id = p_user_id;

  insert into public.credit_ledger(user_id, delta, reason, reference_id)
  values (p_user_id, p_cost, 'ai_generation_refund', p_reference_id);
end;
$$;

create or replace function public.create_reward_session(
  p_user_id uuid,
  p_credit_amount integer,
  p_max_per_day integer,
  p_cooldown_seconds integer
)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_session_id uuid;
  v_today_count integer;
  v_last_completed timestamptz;
begin
  perform pg_advisory_xact_lock(hashtext(p_user_id::text));

  select count(*), max(completed_at)
  into v_today_count, v_last_completed
  from public.reward_sessions
  where user_id = p_user_id
    and status = 'completed'
    and completed_at >= date_trunc('day', now());

  if v_today_count >= p_max_per_day then return null; end if;

  if v_last_completed is not null
     and v_last_completed + make_interval(secs => p_cooldown_seconds) > now() then
    return null;
  end if;

  update public.reward_sessions
  set status = 'expired'
  where user_id = p_user_id and status = 'pending' and expires_at <= now();

  insert into public.reward_sessions(user_id, credit_amount)
  values (p_user_id, p_credit_amount)
  returning id into v_session_id;

  return v_session_id;
end;
$$;

create or replace function public.complete_reward_session(
  p_user_id uuid, p_session_id uuid, p_max_per_day integer
)
returns integer
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_amount integer;
  v_balance integer;
  v_today_count integer;
begin
  perform pg_advisory_xact_lock(hashtext(p_user_id::text));

  select count(*) into v_today_count
  from public.reward_sessions
  where user_id = p_user_id
    and status = 'completed'
    and completed_at >= date_trunc('day', now());

  if v_today_count >= p_max_per_day then return -2; end if;

  update public.reward_sessions
  set status = 'completed', completed_at = now()
  where id = p_session_id
    and user_id = p_user_id
    and status = 'pending'
    and expires_at > now()
  returning credit_amount into v_amount;

  if v_amount is null then return -1; end if;

  insert into public.credit_wallets(user_id, balance, earned_total)
  values (p_user_id, v_amount, v_amount)
  on conflict (user_id) do update
  set balance = public.credit_wallets.balance + excluded.balance,
      earned_total = public.credit_wallets.earned_total + excluded.earned_total,
      updated_at = now()
  returning balance into v_balance;

  insert into public.credit_ledger(user_id, delta, reason, reference_id, metadata)
  values (p_user_id, v_amount, 'startio_reward', p_session_id, jsonb_build_object('provider','startio'));

  return v_balance;
end;
$$;

revoke all on function public.consume_generation_credits(uuid, integer, uuid) from public, anon, authenticated;
revoke all on function public.refund_generation_credits(uuid, integer, uuid) from public, anon, authenticated;
revoke all on function public.create_reward_session(uuid, integer, integer, integer) from public, anon, authenticated;
revoke all on function public.complete_reward_session(uuid, uuid, integer) from public, anon, authenticated;

grant execute on function public.consume_generation_credits(uuid, integer, uuid) to service_role;
grant execute on function public.refund_generation_credits(uuid, integer, uuid) to service_role;
grant execute on function public.create_reward_session(uuid, integer, integer, integer) to service_role;
grant execute on function public.complete_reward_session(uuid, uuid, integer) to service_role;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'study-sources',
  'study-sources',
  false,
  52428800,
  array[
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'text/plain',
    'text/markdown',
    'application/rtf',
    'application/vnd.oasis.opendocument.text',
    'image/png',
    'image/jpeg',
    'image/webp',
    'image/gif'
  ]
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;
