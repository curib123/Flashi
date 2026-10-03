import { NextResponse } from 'next/server';
import { ApiAuthError } from '@/lib/auth';

export function json(data: unknown, status = 200) {
  return NextResponse.json(data, { status });
}

export function apiError(error: unknown) {
  if (error instanceof ApiAuthError) return json({ error: 'unauthorized' }, 401);
  if (error instanceof Error) console.error(error);
  return json({ error: 'internal_server_error' }, 500);
}
