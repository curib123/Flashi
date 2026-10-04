import { createHmac } from 'node:crypto';
import { createAdminClient } from './supabase';
import { ApiError } from './http';
import { env } from './env';
export async function rateLimit(key:string,limit=120,window=60){
  const {data,error}=await createAdminClient().rpc('check_rate_limit',{p_key:key,p_limit:limit,p_window:window});
  if(error)throw error;if(!data)throw new ApiError(429,'rate_limited','Too many requests. Please wait a moment.');
}
export async function authRateLimit(request:Request){
  const ip=request.headers.get('x-vercel-forwarded-for')||request.headers.get('x-forwarded-for')?.split(',')[0]||'unknown';
  await rateLimit('auth:'+createHmac('sha256',env.rateLimitKey()).update(ip).digest('hex'),30,60);
}
export async function requireUser(request:Request){
  const token=request.headers.get('authorization')?.match(/^Bearer\s+(\S+)$/i)?.[1];
  if(!token)throw new ApiError(401,'unauthorized','Sign in with Google to use this online feature.');
  const {data,error}=await createAdminClient().auth.getUser(token);
  if(error||!data.user||data.user.is_anonymous)throw new ApiError(401,'unauthorized');
  await rateLimit('api:'+data.user.id);return data.user;
}
