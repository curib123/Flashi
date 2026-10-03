import { NextRequest } from 'next/server';
import type { User } from '@supabase/supabase-js';
import { createAdminClient } from '@/lib/supabase';

export class ApiAuthError extends Error {
  constructor(message = 'Unauthorized') {
    super(message);
    this.name = 'ApiAuthError';
  }
}

export async function requireUser(request: NextRequest): Promise<User> {
  const authorization = request.headers.get('authorization') ?? '';
  const match = authorization.match(/^Bearer\s+(.+)$/i);
  if (!match) throw new ApiAuthError();

  const admin = createAdminClient();
  const { data, error } = await admin.auth.getUser(match[1].trim());
  if (error || !data.user) throw new ApiAuthError();
  return data.user;
}
