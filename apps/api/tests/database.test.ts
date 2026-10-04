import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { PGlite } from '@electric-sql/pglite';

const uid = '11111111-1111-4111-8111-111111111111';
const job = '22222222-2222-4222-8222-222222222222';
async function database() {
  const db = new PGlite();
  await db.exec("create role anon; create role authenticated; create role service_role bypassrls; create schema auth; create table auth.users(id uuid primary key); insert into auth.users values ('"+uid+"');");
  await db.exec(await readFile(new URL('../../../supabase/migrations/20261004000000_study_app.sql', import.meta.url), 'utf8'));
  return db;
}
test('reservation is not a charge; completion charges once; replay returns saved content', async () => {
  const db = await database();
  try {
    await db.query('select ensure_credit_wallet($1,10)',[uid]);
    await db.query('select begin_generation($1,$2,$3,3,$4,20)',[uid,job,'hash',{}]);
    let wallet = (await db.query<{balance:number,reserved:number}>('select balance,reserved from credit_wallets')).rows[0];
    assert.deepEqual(wallet,{balance:10,reserved:3});
    const payload = {title:'Saved result',questions:[]};
    await db.query('select complete_generation($1,$2,$3)',[uid,job,payload]);
    await db.query('select complete_generation($1,$2,$3)',[uid,job,payload]);
    wallet = (await db.query<{balance:number,reserved:number}>('select balance,reserved from credit_wallets')).rows[0];
    assert.deepEqual(wallet,{balance:7,reserved:0});
    const replay = (await db.query<{result:{status:string,result:unknown}}>('select begin_generation($1,$2,$3,3,$4,20) as result',[uid,job,'hash',{}])).rows[0].result;
    assert.equal(replay.status,'completed'); assert.deepEqual(replay.result,payload);
    assert.equal((await db.query('select * from credit_ledger where delta=-3')).rows.length,1);
  } finally { await db.close(); }
});
test('failed and abandoned reservations release without debit; overdraw is refused', async () => {
  const db = await database();
  try {
    await db.query('select ensure_credit_wallet($1,2)',[uid]);
    await assert.rejects(db.query('select begin_generation($1,$2,$3,3,$4,20)',[uid,job,'hash',{}]),/insufficient_credits/);
    await db.query('select begin_generation($1,$2,$3,2,$4,20)',[uid,job,'hash',{}]);
    await assert.rejects(db.query('select begin_generation($1,$2,$3,1,$4,20)',[uid,'33333333-3333-4333-8333-333333333333','other',{}]),/insufficient_credits/);
    await db.query('select fail_generation($1,$2,$3)',[uid,job,'model_error']);
    assert.deepEqual((await db.query('select balance,reserved from credit_wallets')).rows[0],{balance:2,reserved:0});
    await db.query('select begin_generation($1,$2,$3,2,$4,20)',[uid,'44444444-4444-4444-8444-444444444444','new',{}]);
    await db.exec("update generation_jobs set expires_at=now()-interval '1 minute'");
    await db.query('select reap_generation_jobs()');
    assert.deepEqual((await db.query('select balance,reserved from credit_wallets')).rows[0],{balance:2,reserved:0});
  } finally { await db.close(); }
});
test('clients cannot mutate credits or call privileged RPCs', async () => {
  const db = await database();
  try {
    await db.exec('set role authenticated');
    await assert.rejects(db.query('select ensure_credit_wallet($1,1000000)',[uid]),/permission denied/);
    await assert.rejects(db.exec('update credit_wallets set balance=1000000'),/permission denied/);
  } finally { await db.close(); }
});
test('sync checks optimistic revisions, retains tombstones and isolates users',async()=>{
  const db=await database();
  try {
    const entity='55555555-5555-4555-8555-555555555555';
    const first=(await db.query<{r:{accepted:any[],conflicts:any[]}}>('select sync_entities($1,$2) r',[uid,[{id:entity,entityType:'subject',baseRevision:0,deleted:false,payload:{title:'Biology'}}]])).rows[0].r;
    assert.equal(first.accepted[0].revision,1);
    const conflict=(await db.query<{r:{conflicts:any[]}}>('select sync_entities($1,$2) r',[uid,[{id:entity,entityType:'subject',baseRevision:0,deleted:false,payload:{title:'Chemistry'}}]])).rows[0].r;
    assert.equal(conflict.conflicts.length,1);
    await db.query('select sync_entities($1,$2)',[uid,[{id:entity,entityType:'subject',baseRevision:1,deleted:true,payload:null}]]);
    assert.equal((await db.query<{deleted:boolean,revision:number}>('select deleted,revision from study_entities')).rows[0].deleted,true);
    assert.equal((await db.query('select * from study_entities where user_id=$1',['66666666-6666-4666-8666-666666666666'])).rows.length,0);
  } finally {await db.close();}
});
