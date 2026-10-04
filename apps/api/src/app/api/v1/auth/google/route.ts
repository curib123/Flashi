import { z } from 'zod';
import { createAuthClient } from '@/lib/supabase';
import { authRateLimit } from '@/lib/auth';
import { ApiError,apiError,json,readJson } from '@/lib/http';
import { ensureWallet } from '@/lib/credits';
const schema=z.object({idToken:z.string().min(20).max(10000),accessToken:z.string().max(10000).optional()}).strict();
export async function POST(request:Request){try{
  await authRateLimit(request);const body=schema.parse(await readJson(request,25000));
  const {data,error}=await createAuthClient().auth.signInWithIdToken({provider:'google',token:body.idToken,access_token:body.accessToken});
  if(error||!data.session||!data.user)throw new ApiError(401,'google_sign_in_failed');await ensureWallet(data.user.id);
  return json({session:{accessToken:data.session.access_token,refreshToken:data.session.refresh_token,expiresAt:data.session.expires_at},user:{id:data.user.id,email:data.user.email,name:data.user.user_metadata?.full_name||'Flashi learner'}});
}catch(e){return apiError(e);}}
