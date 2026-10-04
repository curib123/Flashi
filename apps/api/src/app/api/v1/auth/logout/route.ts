import { requireUser } from '@/lib/auth';
import { createAdminClient } from '@/lib/supabase';
import { apiError,json } from '@/lib/http';
export async function POST(request:Request){try{await requireUser(request);const token=request.headers.get('authorization')!.replace(/^Bearer\s+/i,'');const {error}=await createAdminClient().auth.admin.signOut(token,'local');if(error)throw error;return json({signedOut:true});}catch(e){return apiError(e);}}
