import { createAdminClient } from './supabase';
import { env } from './env';
export const creditCost=(count:number)=>Math.ceil(count/10);
export async function ensureWallet(userId:string){const {error}=await createAdminClient().rpc('ensure_credit_wallet',{p_user_id:userId,p_initial:env.initialCredits()});if(error)throw error;}
export async function getWallet(userId:string){
  await ensureWallet(userId);const {data,error}=await createAdminClient().from('credit_wallets').select('balance,reserved').eq('user_id',userId).single();
  if(error)throw error;return {...data,available:data.balance-data.reserved};
}
