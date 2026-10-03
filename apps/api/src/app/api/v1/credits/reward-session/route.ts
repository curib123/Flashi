import { NextRequest } from 'next/server';
import { requireUser } from '@/lib/auth';
import { env } from '@/lib/env';
import { apiError, json } from '@/lib/http';
import { createAdminClient } from '@/lib/supabase';

export const runtime = 'nodejs';

export async function POST(request: NextRequest) {
  try {
    const user = await requireUser(request);
    const admin = createAdminClient();
    const { data, error } = await admin.rpc('create_reward_session', {
      p_user_id: user.id,
      p_credit_amount: env.rewardCredits(),
      p_max_per_day: env.maxRewardsPerDay(),
      p_cooldown_seconds: env.rewardCooldownSeconds(),
    });
    if (error) throw error;
    if (!data) return json({ error: 'reward_unavailable' }, 429);

    return json({
      sessionId: data,
      creditAmount: env.rewardCredits(),
      expiresInSeconds: 600,
    }, 201);
  } catch (error) {
    return apiError(error);
  }
}
