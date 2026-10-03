import { randomUUID } from 'crypto';
import { NextRequest } from 'next/server';
import { z } from 'zod';
import { requireUser } from '@/lib/auth';
import { apiError, json } from '@/lib/http';
import { createAdminClient } from '@/lib/supabase';
import { STUDY_SOURCE_BUCKET } from '@/lib/env';

export const runtime = 'nodejs';

const schema = z.object({
  filename: z.string().min(1).max(180),
  mimeType: z.string().min(1).max(120),
  size: z.number().int().positive().max(50 * 1024 * 1024),
});

const allowedExtensions = new Set([
  'pdf','doc','docx','txt','md','rtf','odt','png','jpg','jpeg','webp','gif',
]);

function safeFilename(filename: string) {
  return filename
    .replace(/[^a-zA-Z0-9._-]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(-120) || 'study-source';
}

export async function POST(request: NextRequest) {
  try {
    const user = await requireUser(request);
    const body = schema.parse(await request.json());
    const extension = body.filename.split('.').pop()?.toLowerCase() ?? '';
    if (!allowedExtensions.has(extension)) {
      return json({ error: 'unsupported_file_type' }, 415);
    }

    const path = user.id + '/' + randomUUID() + '-' + safeFilename(body.filename);
    const admin = createAdminClient();
    const { data, error } = await admin.storage
      .from(STUDY_SOURCE_BUCKET)
      .createSignedUploadUrl(path, { upsert: false });

    if (error) throw error;

    return json({
      bucket: STUDY_SOURCE_BUCKET,
      path,
      token: data.token,
      signedUrl: data.signedUrl,
      expiresInSeconds: 7200,
    }, 201);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return json({ error: 'invalid_upload_request', issues: error.issues }, 400);
    }
    return apiError(error);
  }
}
