-- Run after the migrations in the Flashi project's SQL editor.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('study-sources','study-sources',false,10485760,array['application/pdf','application/msword','application/vnd.openxmlformats-officedocument.wordprocessingml.document','application/vnd.oasis.opendocument.text','application/rtf','text/plain','text/markdown','image/png','image/jpeg','image/webp'])
on conflict(id) do update set public=false,file_size_limit=excluded.file_size_limit,allowed_mime_types=excluded.allowed_mime_types;
-- No public read/write policies. The backend issues owned signed upload URLs.
