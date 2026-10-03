import { createAdminClient } from '@/lib/supabase';
import { env } from '@/lib/env';

export async function ensureWallet(userId: string) {
  const admin = createAdminClient();
  const { error } = await admin
    .from('credit_wallets')
    .upsert(
      { user_id: userId, balance: env.initialCredits() },
      { onConflict: 'user_id', ignoreDuplicates: true },
    );
  if (error) throw error;
}

export async function getBalance(userId: string): Promise<number> {
  await ensureWallet(userId);
  const admin = createAdminClient();
  const { data, error } = await admin
    .from('credit_wallets')
    .select('balance')
    .eq('user_id', userId)
    .single();
  if (error) throw error;
  return Number(data.balance);
}

export async function consumeCredits(userId: string, cost: number, referenceId: string) {
  await ensureWallet(userId);
  const admin = createAdminClient();
  const { data, error } = await admin.rpc('consume_generation_credits', {
    p_user_id: userId,
    p_cost: cost,
    p_reference_id: referenceId,
  });
  if (error) throw error;
  return Number(data);
}

export async function refundCredits(userId: string, cost: number, referenceId: string) {
  const admin = createAdminClient();
  const { error } = await admin.rpc('refund_generation_credits', {
    p_user_id: userId,
    p_cost: cost,
    p_reference_id: referenceId,
  });
  if (error) throw error;
}

export function creditCost(questionCount: number): number {
  const counts = [10, 20, 30, 40, 50] as const;
  const index = counts.indexOf(questionCount as (typeof counts)[number]);
  if (index < 0) throw new Error('Unsupported question count');
  return index + 1;
}
