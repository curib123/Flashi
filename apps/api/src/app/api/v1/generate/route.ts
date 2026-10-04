import { createHash } from 'node:crypto';
import { z } from 'zod';
import { requireUser } from '@/lib/auth';
import { ensureWallet,creditCost,getWallet } from '@/lib/credits';
import { generateStudySet } from '@/lib/generation';
import { generationRequestSchema } from '@/lib/study';
import { ApiError,apiError,json,readJson } from '@/lib/http';
import { createAdminClient } from '@/lib/supabase';
import { env,LUNA_MODEL } from '@/lib/env';
export const runtime='nodejs';export const maxDuration=180;
export async function POST(request:Request){
  let reserved=false;let userId='';let id='';
  try{
    const user=await requireUser(request);userId=user.id;id=z.uuid().parse(request.headers.get('idempotency-key'));
    const input=generationRequestSchema.parse(await readJson(request,100000));
    if(!env.aiConfigured())throw new ApiError(503,'ai_not_configured','AI generation is not configured yet. Manual study is available offline.');
    const hash=createHash('sha256').update(JSON.stringify(input)).digest('hex');await ensureWallet(userId);
    const admin=createAdminClient();const cost=creditCost(input.count);
    const {data:job,error}=await admin.rpc('begin_generation',{p_user_id:userId,p_id:id,p_hash:hash,p_cost:cost,p_metadata:{kind:input.kind,count:input.count,difficulty:input.difficulty,questionTypes:input.questionTypes},p_hour_limit:env.generationHourLimit()});if(error)throw error;
    if(job.status==='completed')return json({generationId:id,model:LUNA_MODEL,creditCost:job.cost,credits:(await getWallet(userId)).balance,result:job.result});
    if(job.status==='processing')throw new ApiError(409,'generation_processing','This request is still generating. Recover it from your account.');
    if(job.status==='failed')throw new ApiError(422,job.errorCode||'generation_failed','This generation failed without a charge. Start a new request to retry.');
    reserved=true;const result=await generateStudySet(input,userId);
    result.creator=String(user.user_metadata?.name||user.user_metadata?.full_name||'Flashi learner').slice(0,200);
    const {data:balance,error:finishError}=await admin.rpc('complete_generation',{p_user_id:userId,p_id:id,p_result:result});if(finishError)throw finishError;
    reserved=false;return json({generationId:id,model:LUNA_MODEL,creditCost:cost,credits:balance,result});
  }catch(error){
    if(reserved){try{await createAdminClient().rpc('fail_generation',{p_user_id:userId,p_id:id,p_error:'generation_failed'});}catch{console.error('Reservation will be recovered on expiry');}}
    return apiError(error);
  }
}
