import { createClient } from '@supabase/supabase-js';
import { env } from './env';
const options={auth:{autoRefreshToken:false,detectSessionInUrl:false,persistSession:false}};
export function createAdminClient(){return createClient(env.supabaseUrl(),env.supabaseSecretKey(),options);}
export function createAuthClient(){return createClient(env.supabaseUrl(),env.supabasePublishableKey(),options);}
