import assert from 'node:assert/strict';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterEach, beforeEach, test } from 'node:test';
import { createApi } from '../server.mjs';

let api;
let directory;
let baseUrl;

beforeEach(async () => {
  directory = mkdtempSync(join(tmpdir(), 'encuestas-api-'));
  api = createApi({ databasePath: join(directory, 'test.sqlite') });
  await new Promise((resolve) => api.server.listen(0, '127.0.0.1', resolve));
  const address = api.server.address();
  baseUrl = `http://127.0.0.1:${address.port}`;
});

afterEach(async () => {
  await new Promise((resolve) => api.server.close(resolve));
  api.close();
  rmSync(directory, { recursive: true, force: true });
});

test('lists the active survey and its question count', async () => {
  const response = await fetch(`${baseUrl}/api/surveys`);
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.equal(body.surveys.length, 1);
  assert.equal(body.surveys[0].questionCount, 8);
});

test('returns survey questions and stores a valid response', async () => {
  const surveyResponse = await fetch(`${baseUrl}/api/surveys/participacion-comunitaria`);
  const survey = await surveyResponse.json();
  const response = await fetch(`${baseUrl}/api/responses`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      surveyId: survey.id,
      respondentName: 'Mariana López',
      demographics: {
        surname: 'García',
        residents: '4',
        minors: '1',
        adults: '3',
        occupation: 'Empleado/a',
        maritalStatus: 'Casado/a',
      },
      answers: survey.questions.map((question) => question.options[0]),
    }),
  });
  const body = await response.json();

  assert.equal(response.status, 201);
  assert.equal(body.saved, true);
  assert.ok(body.id > 0);
});

test('rejects incomplete or invalid answers', async () => {
  const response = await fetch(`${baseUrl}/api/responses`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      surveyId: 'participacion-comunitaria',
      respondentName: 'Mariana',
      demographics: {
        surname: 'García',
        residents: '4',
        minors: '1',
        adults: '3',
        occupation: 'Empleado/a',
        maritalStatus: 'Casado/a',
      },
      answers: ['respuesta fuera de opciones'],
    }),
  });

  assert.equal(response.status, 400);
});

test('requires complete demographic data', async () => {
  const response = await fetch(`${baseUrl}/api/responses`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      surveyId: 'participacion-comunitaria',
      respondentName: 'Mariana',
      demographics: { surname: 'García' },
      answers: Array(8).fill('Muy buena'),
    }),
  });

  assert.equal(response.status, 400);
});