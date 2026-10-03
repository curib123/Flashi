import { NextRequest } from 'next/server';
import { z } from 'zod';
import { requireUser } from '@/lib/auth';
import { env } from '@/lib/env';
import { apiError, json } from '@/lib/http';
import { createAdminClient } from '@/lib/supabase';

export const runtime = 'nodejs';

const schema = z.object({ sessionId: z.string().uuid() });

export async function POST(request: NextRequest) {
  try {
    const user = await requireUser(request);
    const body = schema.parse(await request.json());
    const admin = createAdminClient();

    const { data, error } = await admin.rpc('complete_reward_session', {
      p_user_id: user.id,
      p_session_id: body.sessionId,
      p_max_per_day: env.maxRewardsPerDay(),
    });

    if (error) throw error;
    const balance = Number(data);
    if (balance < 0) {
      return json({ error: 'invalid_or_expired_reward_session' }, 409);
    }

    return json({ credits: balance, credited: env.rewardCredits() });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return json({ error: 'invalid_reward_request' }, 400);
    }
    return apiError(error);
  }
}
