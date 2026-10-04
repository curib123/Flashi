import { env,LUNA_MODEL } from '@/lib/env';
import { apiError,json } from '@/lib/http';
import { mimeTypes,MAX_UPLOAD_BYTES } from '@/lib/uploads';
import { questionTypes } from '@/lib/study';
export async function GET(){try{return json({
  version:1,brand:{name:'Flashi AI',tagline:'Turn Notes Into Knowledge.'},minVersion:env.mobileMinVersion(),
  auth:{enabled:env.configured()&&Boolean(env.googleWebClientId()),googleWebClientId:env.googleWebClientId()},
  generation:{enabled:env.configured()&&env.aiConfigured(),model:LUNA_MODEL,maxQuestions:100,maxUploadBytes:MAX_UPLOAD_BYTES,extensions:Object.keys(mimeTypes),questionTypes,creditsPerTenQuestions:1},
  ads:{enabled:env.startIoEnabled()&&Boolean(env.startIoAppId()),appId:env.startIoAppId(),testMode:env.startIoTestMode(),libraryBanner:env.bannerEnabled(),rewardedCredits:false,splash:false,returnAds:false,interstitial:false},
});}catch(error){return apiError(error);}}
