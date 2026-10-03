import OpenAI from 'openai';
import { zodTextFormat } from 'openai/helpers/zod';
import { z } from 'zod';
import { createAdminClient } from '@/lib/supabase';
import { env, LUNA_MODEL, STUDY_SOURCE_BUCKET } from '@/lib/env';

export const quizTypes = [
  'multiple_choice',
  'identification',
  'true_false',
  'definition',
  'fill_blank',
  'enumeration',
] as const;

export type QuizType = (typeof quizTypes)[number];

const itemSchema = z.object({
  question: z.string().min(1),
  answer: z.string().min(1),
  options: z.array(z.string()).max(4),
  explanation: z.string(),
});

const outputSchema = z.object({
  title: z.string().min(1),
  items: z.array(itemSchema),
});

export type GeneratedStudySet = z.infer<typeof outputSchema>;

export type GenerationInput = {
  sourceType: 'topic' | 'file' | 'image';
  title?: string;
  description?: string;
  storagePath?: string;
  filename?: string;
  mimeType?: string;
  quizType: QuizType;
  count: number;
};

function instructions(input: GenerationInput) {
  const typeRules: Record<QuizType, string> = {
    multiple_choice: 'Each item must have exactly four plausible options. Include the correct answer verbatim in options.',
    identification: 'Ask for the exact term or concept. Return an empty options array.',
    true_false: 'Write a factual statement. The answer must be True or False and options must be ["True","False"].',
    definition: 'Ask for a concise definition or meaning. Return an empty options array.',
    fill_blank: 'Write a sentence with exactly one meaningful blank shown as _____. Return an empty options array.',
    enumeration: 'Ask the learner to list a bounded set of items. Put the expected list in answer and return an empty options array.',
  };

  return [
    'Create exactly ' + input.count + ' high-quality study items.',
    'Quiz type: ' + input.quizType + '.',
    typeRules[input.quizType],
    'Use only information supported by the supplied study source.',
    'Avoid duplicate questions, trick wording, and unsupported facts.',
    'Keep questions concise and answers study-friendly.',
    'The explanation should briefly justify the answer from the source.',
  ].join('\n');
}

async function sourceContent(input: GenerationInput, userId: string): Promise<any[]> {
  const prompt = instructions(input);

  if (input.sourceType === 'topic') {
    const topic = input.title?.trim();
    const description = input.description?.trim();
    if (!topic || !description) throw new Error('Topic and description are required');
    return [{ type: 'input_text', text: prompt + '\n\nTopic: ' + topic + '\nStudy scope/notes: ' + description }];
  }

  const path = input.storagePath?.trim();
  if (!path || !path.startsWith(userId + '/')) throw new Error('Invalid storage path');

  const admin = createAdminClient();
  const { data, error } = await admin.storage.from(STUDY_SOURCE_BUCKET).download(path);
  if (error || !data) throw error ?? new Error('Could not download study source');

  const bytes = Buffer.from(await data.arrayBuffer());
  const mime = input.mimeType?.trim() || data.type || 'application/octet-stream';
  const filename = input.filename?.trim() || path.split('/').pop() || 'study-source';

  if (input.sourceType === 'image') {
    return [
      { type: 'input_text', text: prompt },
      { type: 'input_image', image_url: 'data:' + mime + ';base64,' + bytes.toString('base64'), detail: 'high' },
    ];
  }

  const filePart: Record<string, unknown> = {
    type: 'input_file',
    filename,
    file_data: 'data:' + mime + ';base64,' + bytes.toString('base64'),
  };
  if (mime === 'application/pdf') filePart.detail = 'high';

  return [filePart, { type: 'input_text', text: prompt }];
}

function normalize(result: GeneratedStudySet, input: GenerationInput): GeneratedStudySet {
  const items = result.items.slice(0, input.count).map((item) => {
    if (input.quizType === 'multiple_choice') {
      const options = Array.from(new Set(item.options.map((x) => x.trim()))).filter(Boolean).slice(0, 4);
      if (!options.includes(item.answer) && options.length < 4) options.push(item.answer);
      return { ...item, options: options.slice(0, 4) };
    }
    if (input.quizType === 'true_false') return { ...item, options: ['True', 'False'] };
    return { ...item, options: [] };
  });

  if (items.length !== input.count) throw new Error('Model returned an incomplete study set');
  if (input.quizType === 'multiple_choice' && items.some((item) => item.options.length !== 4)) {
    throw new Error('Model returned invalid multiple-choice options');
  }
  return { title: result.title, items };
}

export async function generateStudySet(input: GenerationInput, userId: string) {
  const openai = new OpenAI({ apiKey: env.openAiKey() });
  const content = await sourceContent(input, userId);

  const response = await openai.responses.parse({
    model: LUNA_MODEL,
    reasoning: { effort: 'low' },
    store: false,
    input: [{ role: 'user', content }],
    text: { format: zodTextFormat(outputSchema, 'flashi_study_set') },
  });

  if (!response.output_parsed) throw new Error('Luna returned no structured study set');
  return normalize(response.output_parsed, input);
}
