import { createAdminClient } from '@/lib/supabase';
import { env,STUDY_SOURCE_BUCKET } from '@/lib/env';
import { ApiError,apiError,json } from '@/lib/http';
export async function GET(request:Request){try{
  if(request.headers.get('authorization')!==`Bearer ${env.cronSecret()}`)throw new ApiError(401,'unauthorized');
  const admin=createAdminClient();const {data:released,error}=await admin.rpc('reap_generation_jobs');if(error)throw error;
  const {data:uploads,error:readError}=await admin.from('study_uploads').select('id,path').lt('created_at',new Date(Date.now()-24*3600000).toISOString()).limit(100);if(readError)throw readError;
  if(uploads.length){const {error:removeError}=await admin.storage.from(STUDY_SOURCE_BUCKET).remove(uploads.map(u=>u.path));if(removeError)throw removeError;const {error:deleteError}=await admin.from('study_uploads').delete().in('id',uploads.map(u=>u.id));if(deleteError)throw deleteError;}
  return json({released,removedUploads:uploads.length});
}catch(e){return apiError(e);}}
