import { ApiError } from './http';
export const LUNA_MODEL='gpt-5.6-luna' as const;
export const STUDY_SOURCE_BUCKET='study-sources' as const;
const value=(name:string)=>process.env[name]?.trim()??'';
const required=(name:string)=>{const v=value(name);if(!v)throw new ApiError(503,'backend_not_configured','Online features are not configured yet.');return v;};
const int=(name:string,defaultValue:number,max=10000)=>{const v=Number(value(name)||defaultValue);if(!Number.isInteger(v)||v<0||v>max)throw new ApiError(503,'invalid_server_configuration');return v;};
export const env={
  openAiKey:()=>required('OPENAI_API_KEY'),supabaseUrl:()=>required('SUPABASE_URL'),supabasePublishableKey:()=>required('SUPABASE_PUBLISHABLE_KEY'),
  supabaseSecretKey:()=>value('SUPABASE_SERVICE_ROLE_KEY')||required('SUPABASE_SECRET_KEY'),
  configured:()=>Boolean(value('SUPABASE_URL')&&value('SUPABASE_PUBLISHABLE_KEY')&&(value('SUPABASE_SERVICE_ROLE_KEY')||value('SUPABASE_SECRET_KEY'))),
  aiConfigured:()=>Boolean(value('OPENAI_API_KEY')),googleWebClientId:()=>value('GOOGLE_WEB_CLIENT_ID'),initialCredits:()=>int('INITIAL_CREDITS',10),
  startIoAppId:()=>/^\d{6,12}$/.test(value('START_IO_APP_ID'))?value('START_IO_APP_ID'):'',startIoEnabled:()=>value('START_IO_ENABLED')==='true',
  startIoTestMode:()=>value('START_IO_TEST_MODE')!=='false',bannerEnabled:()=>value('START_IO_LIBRARY_BANNER')==='true',
  generationHourLimit:()=>int('GENERATION_HOURLY_LIMIT',20,100),rateLimitKey:()=>required('RATE_LIMIT_HASH_KEY'),cronSecret:()=>required('CRON_SECRET'),
  mobileMinVersion:()=>value('MOBILE_MIN_VERSION')||'2.0.0',
};
