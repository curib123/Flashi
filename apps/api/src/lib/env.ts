export const LUNA_MODEL = 'gpt-5.6-luna' as const;
export const STUDY_SOURCE_BUCKET = 'study-sources' as const;

function required(name: string): string {
  const value = process.env[name]?.trim();
  if (!value) throw new Error('Missing required environment variable: ' + name);
  return value;
}

function integer(name: string, fallback: number): number {
  const raw = process.env[name];
  if (!raw) return fallback;
  const parsed = Number.parseInt(raw, 10);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function boolean(name: string, fallback: boolean): boolean {
  const raw = process.env[name]?.trim().toLowerCase();
  if (!raw) return fallback;
  return raw === 'true' || raw === '1' || raw === 'yes';
}

export const env = {
  openAiKey: () => required('OPENAI_API_KEY'),
  supabaseUrl: () => required('SUPABASE_URL'),
  supabasePublishableKey: () => required('SUPABASE_PUBLISHABLE_KEY'),
  supabaseSecretKey: () => required('SUPABASE_SECRET_KEY'),
  googleWebClientId: () => process.env.GOOGLE_WEB_CLIENT_ID?.trim() ?? '',
  startIoAppId: () => process.env.START_IO_APP_ID?.trim() ?? '',
  startIoEnabled: () => boolean('START_IO_ENABLED', true),
  startIoTestMode: () => boolean('START_IO_TEST_MODE', true),
  rewardCredits: () => Math.max(1, integer('START_IO_REWARD_CREDITS', 5)),
  maxRewardsPerDay: () => Math.max(1, integer('START_IO_MAX_REWARDS_PER_DAY', 10)),
  rewardCooldownSeconds: () => Math.max(0, integer('START_IO_REWARD_COOLDOWN_SECONDS', 60)),
  initialCredits: () => Math.max(0, integer('INITIAL_CREDITS', 10)),
  mobileMinVersion: () => process.env.MOBILE_MIN_VERSION?.trim() ?? '1.6.3',
};
