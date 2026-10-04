import { z } from 'zod';
import { createAuthClient } from '@/lib/supabase';
import { authRateLimit } from '@/lib/auth';
import { ApiError,apiError,json,readJson } from '@/lib/http';
export async function POST(request:Request){try{
  await authRateLimit(request);const {refreshToken}=z.object({refreshToken:z.string().min(1).max(10000)}).strict().parse(await readJson(request,15000));
  const {data,error}=await createAuthClient().auth.refreshSession({refresh_token:refreshToken});if(error||!data.session)throw new ApiError(401,'session_expired');
  return json({session:{accessToken:data.session.access_token,refreshToken:data.session.refresh_token,expiresAt:data.session.expires_at},user:{id:data.user!.id,email:data.user!.email,name:data.user!.user_metadata?.full_name||'Flashi learner'}});
}catch(e){return apiError(e);}}
