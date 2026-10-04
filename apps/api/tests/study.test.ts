import { test } from 'node:test';
import assert from 'node:assert/strict';
import { generationRequestSchema, validateGenerated, questionSchema } from '../src/lib/study';
import { validateUpload, validateSourceBytes } from '../src/lib/uploads';

const input = { sourceType: 'text', text: 'Photosynthesis converts light energy into chemical energy.', kind: 'quiz', count: 1, difficulty: 'medium', questionTypes: ['multiple_choice'], topics: [] };
const valid = { title: 'Biology', subject: 'Science', questions: [{ type: 'multiple_choice', question: 'What does photosynthesis convert?', answer: 'Light', options: ['Light', 'Sound', 'Wind', 'Heat'], explanation: 'Light energy is converted.', topic: 'Photosynthesis', pairs: [] }] };

test('a correct MC answer must be present in its four distinct options', () => {
  assert.throws(() => validateGenerated({ ...valid, questions: [{ ...valid.questions[0], answer: 'Water' }] }, generationRequestSchema.parse(input)));
});
test('successful output preserves typed questions, explanations and difficulty', () => {
  const out = validateGenerated(valid, generationRequestSchema.parse(input));
  assert.equal(out.questions[0].type, 'multiple_choice');
  assert.equal(out.questions[0].explanation, 'Light energy is converted.');
});
test('incomplete or unrequested question types do not consume a success', () => {
  assert.throws(() => validateGenerated({ ...valid, questions: [] }, generationRequestSchema.parse(input)));
  assert.throws(() => validateGenerated({ ...valid, questions: [{ ...valid.questions[0], type: 'definition', options: [] }] }, generationRequestSchema.parse(input)));
});
test('empty study source and over-limit count are rejected', () => {
  assert.equal(generationRequestSchema.safeParse({ ...input, text: '  ' }).success, false);
  assert.equal(generationRequestSchema.safeParse({ ...input, count: 101 }).success, false);
});
test('matching pairs must have distinct left and right terms', () => {
  const q = { id: '1de5f9a6-d65f-4c8c-b61c-f3b13e2b0ae1', type: 'matching', question: 'Match terms', answer: '', options: [], explanation: '', topic: '', pairs: [{left:'a',right:'b'},{left:'a',right:'c'}] };
  assert.equal(questionSchema.safeParse(q).success, false);
});
test('reject disguised uploads, unsafe names and oversized files', () => {
  assert.throws(() => validateUpload({filename:'../../notes.pdf',mimeType:'application/pdf',size:100}));
  assert.throws(() => validateUpload({filename:'notes.pdf',mimeType:'image/png',size:100}));
  assert.throws(() => validateUpload({filename:'notes.pdf',mimeType:'application/pdf',size:11*1024*1024}));
  assert.throws(() => validateSourceBytes(Buffer.from('not a pdf'), 'application/pdf'));
  assert.doesNotThrow(() => validateSourceBytes(Buffer.from('%PDF-1.7\n'), 'application/pdf'));
});
