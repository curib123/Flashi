import { z } from 'zod';
import { requireUser } from '@/lib/auth';
import { createAdminClient } from '@/lib/supabase';
import { syncChangeSchema } from '@/lib/study';
import { apiError,json,readJson } from '@/lib/http';
export async function POST(request:Request){try{
  const user=await requireUser(request);const body=z.object({changes:z.array(syncChangeSchema).max(100)}).strict().parse(await readJson(request));
  if(new Set(body.changes.map(c=>c.id)).size!==body.changes.length)return json({error:'duplicate_sync_ids'},400);
  const {data,error}=await createAdminClient().rpc('sync_entities',{p_user_id:user.id,p_changes:body.changes});if(error)throw error;return json(data);
}catch(e){return apiError(e);}}
export async function GET(request:Request){try{
  const user=await requireUser(request);const cursor=z.coerce.number().int().min(0).max(Number.MAX_SAFE_INTEGER).parse(new URL(request.url).searchParams.get('cursor')||0);
  const {data,error}=await createAdminClient().from('study_entities').select('id,entity_type,revision,change_seq,deleted,payload').eq('user_id',user.id).gt('change_seq',cursor).order('change_seq').limit(201);if(error)throw error;
  const entities=data.slice(0,200).map(e=>({id:e.id,entityType:e.entity_type,revision:e.revision,changeSeq:e.change_seq,deleted:e.deleted,payload:e.payload}));
  return json({entities,cursor:entities.at(-1)?.changeSeq||cursor,hasMore:data.length>200});
}catch(e){return apiError(e);}}
