const { onCall, HttpsError } = require('firebase-functions/v2/https');
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');

admin.initializeApp();

exports.classifyThought = onCall(
  {
    region: 'us-central1',
    timeoutSeconds: 60,
    memory: '256MiB',
  },
  async (request) => {
    const text = `${request.data?.text ?? ''}`.trim();

    if (!text) {
      throw new HttpsError('invalid-argument', 'Text is required.');
    }

    try {
      const classification = process.env.OPENAI_API_KEY
        ? await classifyWithOpenAI(text)
        : classifyHeuristically(text);

      return normalizeClassification(classification);
    } catch (error) {
      logger.error('Classification failed, using heuristic fallback.', error);
      return normalizeClassification(classifyHeuristically(text));
    }
  },
);

async function classifyWithOpenAI(text) {
  const model = process.env.OPENAI_MODEL || 'gpt-4.1-mini';
  const response = await fetch('https://api.openai.com/v1/responses', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model,
      input: [
        {
          role: 'system',
          content: [
            {
              type: 'input_text',
              text:
                'Classify the following text into tasks, ideas, and worries. Return only compact JSON with keys tasks, ideas, worries. Each key must contain an array of strings.',
            },
          ],
        },
        {
          role: 'user',
          content: [{ type: 'input_text', text }],
        },
      ],
      text: {
        format: {
          type: 'json_schema',
          name: 'thought_classification',
          schema: {
            type: 'object',
            additionalProperties: false,
            properties: {
              tasks: {
                type: 'array',
                items: { type: 'string' },
              },
              ideas: {
                type: 'array',
                items: { type: 'string' },
              },
              worries: {
                type: 'array',
                items: { type: 'string' },
              },
            },
            required: ['tasks', 'ideas', 'worries'],
          },
        },
      },
    }),
  });

  if (!response.ok) {
    const message = await response.text();
    throw new Error(`OpenAI request failed: ${response.status} ${message}`);
  }

  const data = await response.json();
  const jsonText = data.output_text;

  if (!jsonText) {
    throw new Error('OpenAI response did not include output_text.');
  }

  return JSON.parse(jsonText);
}

function classifyHeuristically(text) {
  const segments = text
    .split(/[\n.!?]+/)
    .map((item) => item.trim())
    .filter(Boolean);

  const tasks = [];
  const ideas = [];
  const worries = [];

  for (const segment of segments.length ? segments : [text]) {
    const value = segment.toLowerCase();

    if (
      hasKeyword(value, [
        'need to',
        'todo',
        'must',
        'finish',
        'send',
        'call',
        'schedule',
        'book',
        'buy',
        'submit',
      ])
    ) {
      tasks.push(segment);
      continue;
    }

    if (
      hasKeyword(value, [
        'idea',
        'maybe',
        'what if',
        'build',
        'create',
        'launch',
        'start',
        'experiment',
      ])
    ) {
      ideas.push(segment);
      continue;
    }

    if (
      hasKeyword(value, [
        'worried',
        'stress',
        'anxious',
        'afraid',
        'fear',
        'nervous',
        'concerned',
        'overthinking',
      ])
    ) {
      worries.push(segment);
      continue;
    }
  }

  if (!tasks.length && !ideas.length && !worries.length) {
    ideas.push(text);
  }

  return { tasks, ideas, worries };
}

function hasKeyword(value, keywords) {
  return keywords.some((keyword) => value.includes(keyword));
}

function normalizeClassification(result) {
  return {
    tasks: normalizeList(result.tasks),
    ideas: normalizeList(result.ideas),
    worries: normalizeList(result.worries),
  };
}

function normalizeList(items) {
  if (!Array.isArray(items)) {
    return [];
  }

  return items
    .map((item) => `${item}`.trim())
    .filter(Boolean)
    .slice(0, 12);
}
