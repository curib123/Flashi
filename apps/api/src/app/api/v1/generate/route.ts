import { randomUUID } from 'crypto';
import { NextRequest } from 'next/server';
import { z } from 'zod';
import { requireUser } from '@/lib/auth';
import { consumeCredits, creditCost, refundCredits } from '@/lib/credits';
import { generateStudySet, quizTypes } from '@/lib/generation';
import { apiError, json } from '@/lib/http';
import { createAdminClient } from '@/lib/supabase';
import { LUNA_MODEL, STUDY_SOURCE_BUCKET } from '@/lib/env';

export const runtime = 'nodejs';
export const maxDuration = 120;

const requestSchema = z.object({
  sourceType: z.enum(['topic', 'file', 'image']),
  title: z.string().max(200).optional(),
  description: z.string().max(8000).optional(),
  storagePath: z.string().max(500).optional(),
  filename: z.string().max(180).optional(),
  mimeType: z.string().max(120).optional(),
  quizType: z.enum(quizTypes),
  count: z.union([z.literal(10),z.literal(20),z.literal(30),z.literal(40),z.literal(50)]),
});

export async function POST(request: NextRequest) {
  let debited = false;
  let userId = '';
  let jobId = '';
  let cost = 0;
  let storagePath: string | undefined;

  try {
    const user = await requireUser(request);
    userId = user.id;
    const input = requestSchema.parse(await request.json());
    storagePath = input.storagePath;
    cost = creditCost(input.count);
    jobId = randomUUID();

    const admin = createAdminClient();
    const { error: jobError } = await admin.from('generation_jobs').insert({
      id: jobId,
      user_id: userId,
      source_type: input.sourceType,
      quiz_type: input.quizType,
      question_count: input.count,
      credit_cost: cost,
      model: LUNA_MODEL,
      status: 'processing',
    });
    if (jobError) throw jobError;

    const remainingAfterDebit = await consumeCredits(userId, cost, jobId);
    if (remainingAfterDebit < 0) {
      await admin.from('generation_jobs')
        .update({ status: 'failed', error_code: 'insufficient_credits' })
        .eq('id', jobId);
      return json({ error: 'insufficient_credits' }, 402);
    }
    debited = true;

    const result = await generateStudySet(input, userId);

    const { error: completeError } = await admin.from('generation_jobs')
      .update({ status: 'completed', completed_at: new Date().toISOString() })
      .eq('id', jobId);
    if (completeError) throw completeError;

    return json({
      generationId: jobId,
      model: LUNA_MODEL,
      creditCost: cost,
      credits: remainingAfterDebit,
      result,
    });
  } catch (error) {
    const admin = createAdminClient();

    if (debited && userId && jobId) {
      try {
        await refundCredits(userId, cost, jobId);
      } catch (refundError) {
        console.error('Credit refund failed', refundError);
      }
    }

    if (jobId) {
      await admin.from('generation_jobs')
        .update({
          status: 'failed',
          error_code: error instanceof Error ? error.name.toLowerCase() : 'generation_failed',
          completed_at: new Date().toISOString(),
        })
        .eq('id', jobId);
    }

    if (error instanceof z.ZodError) {
      return json({ error: 'invalid_generation_request', issues: error.issues }, 400);
    }
    return apiError(error);
  } finally {
    if (userId && storagePath && storagePath.startsWith(userId + '/')) {
      const admin = createAdminClient();
      await admin.storage.from(STUDY_SOURCE_BUCKET).remove([storagePath]);
    }
  }
}
