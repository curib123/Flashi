import { NextRequest } from 'next/server';
import { requireUser } from '@/lib/auth';
import { getBalance } from '@/lib/credits';
import { apiError, json } from '@/lib/http';

export const runtime = 'nodejs';

export async function GET(request: NextRequest) {
  try {
    const user = await requireUser(request);
    const credits = await getBalance(user.id);
    return json({
      user: {
        id: user.id,
        email: user.email ?? null,
        name: user.user_metadata?.full_name ?? user.user_metadata?.name ?? null,
        avatarUrl: user.user_metadata?.avatar_url ?? null,
      },
      credits,
    });
  } catch (error) {
    return apiError(error);
  }
}
