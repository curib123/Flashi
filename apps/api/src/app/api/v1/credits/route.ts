import { requireUser } from '@/lib/auth';
import { getWallet } from '@/lib/credits';
import { createAdminClient } from '@/lib/supabase';
import { apiError,json } from '@/lib/http';
export async function GET(request:Request){try{
  const user=await requireUser(request);const wallet=await getWallet(user.id);
  const {data,error}=await createAdminClient().from('credit_ledger').select('id,delta,reason,created_at').eq('user_id',user.id).order('created_at',{ascending:false}).limit(100);if(error)throw error;
  return json({...wallet,history:data});
}catch(error){return apiError(error);}}
