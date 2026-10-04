import { NextResponse } from 'next/server';
import { ZodError } from 'zod';
export class ApiError extends Error {
  constructor(public status:number,public code:string,message=code){super(message);}
}
export function json(data:unknown,status=200){return NextResponse.json(data,{status,headers:{'Cache-Control':'no-store','X-Content-Type-Options':'nosniff'}});}
export async function readJson(request:Request,maxBytes=2*1024*1024){
  if(Number(request.headers.get('content-length')??0)>maxBytes)throw new ApiError(413,'request_too_large');
  if(!request.headers.get('content-type')?.includes('application/json'))throw new ApiError(415,'json_required');
  const reader=request.body?.getReader();if(!reader)throw new ApiError(400,'invalid_json');
  const chunks:Uint8Array[]=[];let size=0;
  try{while(true){const {value,done}=await reader.read();if(done)break;size+=value.length;if(size>maxBytes)throw new ApiError(413,'request_too_large');chunks.push(value);}}
  finally{reader.releaseLock();}
  try{return JSON.parse(Buffer.concat(chunks).toString('utf8'));}catch{throw new ApiError(400,'invalid_json');}
}
export function apiError(error:unknown){
  if(error instanceof ApiError)return json({error:error.code,message:error.message},error.status);
  if(error instanceof ZodError)return json({error:'invalid_request',message:'Check the source, question types and fields.'},400);
  const message=typeof error==='object'&&error!==null&&'message' in error?String(error.message):'';
  const statuses:Record<string,number>={insufficient_credits:402,idempotency_conflict:409,rate_limited:429,generation_expired:409};
  for(const [code,status] of Object.entries(statuses))if(message.includes(code))return json({error:code,message:code.replaceAll('_',' ')},status);
  console.error('API operation failed',error instanceof Error?error.name:'database_or_service_error');
  return json({error:'service_unavailable',message:'The operation could not complete. Please retry.'},503);
}
