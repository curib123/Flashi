import { json } from '@/lib/http';
import { env, LUNA_MODEL, STUDY_SOURCE_BUCKET } from '@/lib/env';
import { quizTypes } from '@/lib/generation';

export const runtime = 'nodejs';

export async function GET() {
  return json({
    apiVersion: 1,
    ai: {
      model: LUNA_MODEL,
      quizTypes,
      questionCounts: [10, 20, 30, 40, 50],
      creditCosts: { '10': 1, '20': 2, '30': 3, '40': 4, '50': 5 },
      sourceTypes: ['topic', 'file', 'image'],
    },
    auth: {
      supabaseUrl: env.supabaseUrl(),
      supabasePublishableKey: env.supabasePublishableKey(),
      googleWebClientId: env.googleWebClientId(),
    },
    uploads: {
      bucket: STUDY_SOURCE_BUCKET,
      maxBytes: 50 * 1024 * 1024,
      allowedExtensions: ['pdf','doc','docx','txt','md','rtf','odt','png','jpg','jpeg','webp','gif'],
    },
    ads: {
      provider: 'startio',
      appId: env.startIoAppId(),
      enabled: env.startIoEnabled(),
      testMode: env.startIoTestMode(),
      rewardCredits: env.rewardCredits(),
      maxRewardsPerDay: env.maxRewardsPerDay(),
      rewardCooldownSeconds: env.rewardCooldownSeconds(),
    },
    mobile: { minimumVersion: env.mobileMinVersion() },
  });
}
