import { requireUser } from '@/lib/auth';
import { getWallet } from '@/lib/credits';
import { apiError,json } from '@/lib/http';
export async function GET(request:Request){try{const u=await requireUser(request);return json({user:{id:u.id,email:u.email,name:u.user_metadata?.full_name||u.user_metadata?.name||'Flashi learner'},wallet:await getWallet(u.id)});}catch(e){return apiError(e);}}
