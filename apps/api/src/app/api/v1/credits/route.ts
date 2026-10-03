import { NextRequest } from 'next/server';
import { requireUser } from '@/lib/auth';
import { getBalance } from '@/lib/credits';
import { apiError, json } from '@/lib/http';

export const runtime = 'nodejs';

export async function GET(request: NextRequest) {
  try {
    const user = await requireUser(request);
    return json({ credits: await getBalance(user.id) });
  } catch (error) {
    return apiError(error);
  }
}
