import { z } from 'zod';
import { ApiError } from './http';

export const MAX_UPLOAD_BYTES=10*1024*1024;
export const mimeTypes:Record<string,string>={pdf:'application/pdf',doc:'application/msword',docx:'application/vnd.openxmlformats-officedocument.wordprocessingml.document',txt:'text/plain',md:'text/markdown',rtf:'application/rtf',odt:'application/vnd.oasis.opendocument.text',png:'image/png',jpg:'image/jpeg',jpeg:'image/jpeg',webp:'image/webp'};
const schema=z.object({filename:z.string().min(1).max(180),mimeType:z.string().max(120),size:z.number().int().positive().max(MAX_UPLOAD_BYTES)}).strict();
export function validateUpload(raw:unknown){
  const v=schema.parse(raw);
  if(/[\\/\x00-\x1f]/.test(v.filename)||v.filename.startsWith('.'))throw new ApiError(400,'unsafe_filename');
  const ext=v.filename.split('.').pop()?.toLowerCase()??'';
  if(mimeTypes[ext]!==v.mimeType)throw new ApiError(415,'unsupported_file_type');
  return v;
}
export function validateSourceBytes(bytes:Buffer,mime:string){
  if(!bytes.length||bytes.length>MAX_UPLOAD_BYTES)throw new ApiError(413,'invalid_file_size');
  const head=bytes.subarray(0,16);
  const signatures:Record<string,()=>boolean>={
    'application/pdf':()=>head.toString('ascii').startsWith('%PDF-'),
    'image/png':()=>head.subarray(0,8).equals(Buffer.from([137,80,78,71,13,10,26,10])),
    'image/jpeg':()=>head[0]===255&&head[1]===216&&head[2]===255,
    'image/webp':()=>head.toString('ascii',0,4)==='RIFF'&&head.toString('ascii',8,12)==='WEBP',
    'application/msword':()=>head.subarray(0,8).equals(Buffer.from([208,207,17,224,161,177,26,225])),
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document':()=>head[0]===80&&head[1]===75&&head[2]===3&&head[3]===4,
    'application/vnd.oasis.opendocument.text':()=>head[0]===80&&head[1]===75&&head[2]===3&&head[3]===4,
    'application/rtf':()=>head.toString('ascii').startsWith('{\\rtf'),
    'text/plain':()=>!bytes.includes(0), 'text/markdown':()=>!bytes.includes(0),
  };
  if(!signatures[mime]?.())throw new ApiError(415,'file_content_mismatch');
}
