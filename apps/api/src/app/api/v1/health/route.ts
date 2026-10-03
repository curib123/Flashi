import { json } from '@/lib/http';
import { LUNA_MODEL } from '@/lib/env';

export const runtime = 'nodejs';

export async function GET() {
  return json({ ok: true, service: 'flashi-api', model: LUNA_MODEL });
}
