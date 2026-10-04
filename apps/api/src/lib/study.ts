import { z } from 'zod';

export const questionTypes = ['flashcard','multiple_choice','identification','true_false','definition','fill_blank','matching','question_answer','enumeration'] as const;
const text = (max: number) => z.string().trim().max(max);
export const generatedQuestionSchema = z.object({
  type: z.enum(questionTypes), question: text(4000).min(1), answer: text(4000),
  options: z.array(text(1000).min(1)).max(8), explanation: text(4000), topic: text(200),
  pairs: z.array(z.object({left:text(1000).min(1),right:text(1000).min(1)}).strict()).max(10),
}).strict();
function validQuestion(q: z.infer<typeof generatedQuestionSchema>): boolean {
  if (q.type==='matching') return q.options.length===0 && q.pairs.length>=2 && new Set(q.pairs.map(p=>p.left)).size===q.pairs.length && new Set(q.pairs.map(p=>p.right)).size===q.pairs.length;
  if (!q.answer || q.pairs.length) return false;
  if (q.type==='multiple_choice') return q.options.length===4 && new Set(q.options).size===4 && q.options.includes(q.answer);
  if (q.type==='true_false') return ['True','False'].includes(q.answer) && q.options.length===2 && q.options[0]==='True' && q.options[1]==='False';
  return q.options.length===0 && (q.type!=='fill_blank' || /_{3,}/.test(q.question));
}
export const questionSchema = generatedQuestionSchema.extend({id:z.uuid()}).superRefine((q,ctx)=>{
  if(!validQuestion(q)) ctx.addIssue({code:'custom',message:'Invalid question choices, answer or matching pairs'});
});
export const generatedSchema = z.object({title:text(200).min(1),subject:text(200),questions:z.array(generatedQuestionSchema).min(1).max(100)}).strict();
export const studySetSchema=z.object({
  id:z.uuid(),title:text(200).min(1),subject:text(200),creator:text(200),
  kind:z.enum(['deck','quiz','exam']),difficulty:z.enum(['easy','medium','hard']),
  questions:z.array(questionSchema).max(1000),updatedAt:z.iso.datetime(),
}).strict().superRefine((s,ctx)=>{if(new Set(s.questions.map(q=>q.id)).size!==s.questions.length)ctx.addIssue({code:'custom',message:'Duplicate question IDs'});});
export type StudySet=z.infer<typeof studySetSchema>;
export const generationRequestSchema=z.object({
  sourceType:z.enum(['text','file','image']),text:text(50000).optional(),uploadId:z.uuid().optional(),
  title:text(200).optional(),kind:z.enum(['deck','quiz','exam']),count:z.number().int().min(1).max(100),
  difficulty:z.enum(['easy','medium','hard']),questionTypes:z.array(z.enum(questionTypes)).min(1).max(9),
  topics:z.array(text(200).min(1)).max(10).default([]),
}).strict().superRefine((v,c)=>{
  if(v.sourceType==='text' && (!v.text || v.text.length<10))c.addIssue({code:'custom',message:'Provide at least 10 characters of study notes'});
  if(v.sourceType!=='text' && !v.uploadId)c.addIssue({code:'custom',message:'An owned upload is required'});
  if(new Set(v.questionTypes).size!==v.questionTypes.length)c.addIssue({code:'custom',message:'Duplicate types'});
  if(v.kind==='deck' && (v.questionTypes.length!==1||v.questionTypes[0]!=='flashcard'))c.addIssue({code:'custom',message:'Decks use flashcards'});
  if(v.kind!=='deck' && v.questionTypes.includes('flashcard'))c.addIssue({code:'custom',message:'Quiz/exam types cannot include flashcard'});
  if(v.questionTypes.length>v.count)c.addIssue({code:'custom',message:'Question count must cover all chosen types'});
});
export type GenerationInput=z.infer<typeof generationRequestSchema>;
export function validateGenerated(raw:unknown,input:GenerationInput) {
  const out=generatedSchema.parse(raw);
  if(out.questions.length!==input.count)throw new Error('invalid_model_output');
  if(new Set(out.questions.map(q=>q.question.toLowerCase())).size!==out.questions.length)throw new Error('duplicate_model_questions');
  for(const q of out.questions)if(!input.questionTypes.includes(q.type)||!validQuestion(q))throw new Error('invalid_model_output');
  for(const type of input.questionTypes)if(!out.questions.some(q=>q.type===type))throw new Error('missing_question_type');
  return out;
}
export const subjectSchema=z.object({id:z.uuid(),title:text(200).min(1),updatedAt:z.iso.datetime()}).strict();
export const attemptSchema=z.object({
  id:z.uuid(),setId:z.uuid(),title:text(200).min(1),mode:z.enum(['flashcard','quiz','exam','mistakes']),
  startedAt:z.iso.datetime(),finishedAt:z.iso.datetime(),
  answers:z.array(z.object({question:questionSchema,response:text(8000),correct:z.boolean()}).strict()).max(1000),
}).strict();
export const syncChangeSchema=z.object({id:z.uuid(),entityType:z.enum(['set','subject','attempt']),baseRevision:z.number().int().min(0),deleted:z.boolean(),payload:z.unknown()}).strict().superRefine((v,ctx)=>{
  if(v.deleted){if(v.payload!==null)ctx.addIssue({code:'custom',message:'Deleted payload must be null'});return;}
  const schema=v.entityType==='set'?studySetSchema:v.entityType==='subject'?subjectSchema:attemptSchema;
  const result=schema.safeParse(v.payload);
  if(!result.success||result.data.id!==v.id)ctx.addIssue({code:'custom',message:'Invalid entity payload'});
});
