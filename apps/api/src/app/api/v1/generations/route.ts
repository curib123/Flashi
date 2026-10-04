import { requireUser } from '@/lib/auth';
import { createAdminClient } from '@/lib/supabase';
import { apiError,json } from '@/lib/http';
export async function GET(request:Request){try{const u=await requireUser(request);const {data,error}=await createAdminClient().from('generation_jobs').select('id,status,cost,result,error_code,created_at').eq('user_id',u.id).order('created_at',{ascending:false}).limit(25);if(error)throw error;return json({generations:data});}catch(e){return apiError(e);}}
