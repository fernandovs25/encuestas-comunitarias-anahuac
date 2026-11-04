import { createServer } from 'node:http';
import { mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { DatabaseSync } from 'node:sqlite';

const directory = dirname(fileURLToPath(import.meta.url));
const defaultDatabasePath = resolve(directory, 'data', 'encuestas.sqlite');
const surveyId = 'participacion-comunitaria';
const surveyQuestions = [
  {
    prompt: '¿Cómo describirías la convivencia en tu comunidad?',
    options: ['Muy buena', 'Buena', 'Regular', 'Mala'],
  },
  {
    prompt: '¿Qué tan seguro te sientes en tu comunidad?',
    options: ['Muy seguro/a', 'Seguro/a', 'Poco seguro/a', 'Nada seguro/a'],
  },
  {
    prompt: '¿Con qué frecuencia participas en actividades comunitarias?',
    options: ['Frecuentemente', 'A veces', 'Rara vez', 'Nunca'],
  },
  {
    prompt: '¿Sientes que las personas de tu comunidad se apoyan entre sí?',
    options: ['Siempre', 'Casi siempre', 'A veces', 'Casi nunca'],
  },
  {
    prompt: '¿Qué aspecto de tu comunidad te gustaría mejorar primero?',
    options: ['Seguridad', 'Espacios públicos', 'Actividades', 'Servicios'],
  },
  {
    prompt: '¿Conoces los programas de apoyo disponibles en tu comunidad?',
    options: ['Sí, varios', 'Sí, algunos', 'He escuchado de ellos', 'No'],
  },
  {
    prompt: '¿Qué facilitaría tu participación en actividades comunitarias?',
    options: [
      'Mejores horarios',
      'Más información',
      'Actividades para mi familia',
      'Transporte',
    ],
  },
  {
    prompt: '¿Te gustaría recibir información sobre próximos programas?',
    options: ['Sí', 'Tal vez', 'No'],
  },
];

function sendJson(response, statusCode, body) {
  response.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  });
  response.end(JSON.stringify(body));
}

async function readJson(request) {
  const chunks = [];
  let size = 0;
  for await (const chunk of request) {
    size += chunk.length;
    if (size > 64 * 1024) throw new Error('El cuerpo excede el límite permitido.');
    chunks.push(chunk);
  }
  return JSON.parse(Buffer.concat(chunks).toString('utf8'));
}

function initializeDatabase(database) {
  database.exec(`
    PRAGMA foreign_keys = ON;
    CREATE TABLE IF NOT EXISTS surveys (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      active INTEGER NOT NULL DEFAULT 1
    );
    CREATE TABLE IF NOT EXISTS questions (
      survey_id TEXT NOT NULL REFERENCES surveys(id),
      position INTEGER NOT NULL,
      prompt TEXT NOT NULL,
      options_json TEXT NOT NULL,
      PRIMARY KEY (survey_id, position)
    );
    CREATE TABLE IF NOT EXISTS responses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      survey_id TEXT NOT NULL REFERENCES surveys(id),
      respondent_name TEXT NOT NULL,
      demographics_json TEXT NOT NULL DEFAULT '{}',
      answers_json TEXT NOT NULL,
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
  `);

  const responseColumns = database.prepare('PRAGMA table_info(responses)').all();
  if (!responseColumns.some((column) => column.name === 'demographics_json')) {
    database.exec("ALTER TABLE responses ADD COLUMN demographics_json TEXT NOT NULL DEFAULT '{}'");
  }

  database.prepare(`
    INSERT OR IGNORE INTO surveys (id, title, description, active)
    VALUES (?, ?, ?, 1)
  `).run(
    surveyId,
    'Encuesta de participación comunitaria',
    'Cuéntanos cómo vives tu comunidad para orientar mejor los próximos apoyos.',
  );

  const insertQuestion = database.prepare(`
    INSERT OR IGNORE INTO questions (survey_id, position, prompt, options_json)
    VALUES (?, ?, ?, ?)
  `);
  surveyQuestions.forEach((question, index) => {
    insertQuestion.run(surveyId, index, question.prompt, JSON.stringify(question.options));
  });
}

function loadSurvey(database, id) {
  const survey = database.prepare(`
    SELECT id, title, description FROM surveys WHERE id = ? AND active = 1
  `).get(id);
  if (!survey) return null;

  const questions = database.prepare(`
    SELECT prompt, options_json FROM questions
    WHERE survey_id = ? ORDER BY position
  `).all(id).map((question) => ({
    prompt: question.prompt,
    options: JSON.parse(question.options_json),
  }));

  return { ...survey, questions };
}

export function createApi({ databasePath = process.env.DB_PATH ?? defaultDatabasePath } = {}) {
  if (databasePath !== ':memory:') mkdirSync(dirname(resolve(databasePath)), { recursive: true });
  const database = new DatabaseSync(databasePath);
  initializeDatabase(database);

  const server = createServer(async (request, response) => {
    if (request.method === 'OPTIONS') {
      sendJson(response, 204, {});
      return;
    }

    const url = new URL(request.url ?? '/', 'http://localhost');
    if (request.method === 'GET' && url.pathname === '/health') {
      sendJson(response, 200, { status: 'ok' });
      return;
    }

    if (request.method === 'GET' && url.pathname === '/api/surveys') {
      const surveys = database.prepare(`
        SELECT id, title, description FROM surveys WHERE active = 1 ORDER BY title
      `).all().map((survey) => ({
        ...survey,
        questionCount: database.prepare(
          'SELECT COUNT(*) AS count FROM questions WHERE survey_id = ?',
        ).get(survey.id).count,
      }));
      sendJson(response, 200, { surveys });
      return;
    }

    const surveyMatch = url.pathname.match(/^\/api\/surveys\/([^/]+)$/);
    if (request.method === 'GET' && surveyMatch) {
      const survey = loadSurvey(database, decodeURIComponent(surveyMatch[1]));
      sendJson(response, survey ? 200 : 404, survey ?? { error: 'Encuesta no encontrada.' });
      return;
    }

    if (request.method === 'POST' && url.pathname === '/api/responses') {
      try {
        const body = await readJson(request);
        const survey = typeof body.surveyId === 'string'
          ? loadSurvey(database, body.surveyId)
          : null;
        const respondentName = typeof body.respondentName === 'string'
          ? body.respondentName.trim()
          : '';
        const demographicFields = [
          'surname',
          'residents',
          'minors',
          'adults',
          'occupation',
          'maritalStatus',
        ];
        const validDemographics = body.demographics
          && typeof body.demographics === 'object'
          && !Array.isArray(body.demographics)
          && demographicFields.every((field) =>
            typeof body.demographics[field] === 'string'
            && body.demographics[field].trim().length > 0
            && body.demographics[field].length <= 120,
          );
        const validAnswers = survey
          && Array.isArray(body.answers)
          && body.answers.length === survey.questions.length
          && body.answers.every((answer, index) => survey.questions[index].options.includes(answer));

        if (
          !survey
          || !respondentName
          || respondentName.length > 120
          || !validDemographics
          || !validAnswers
        ) {
          sendJson(response, 400, { error: 'La encuesta, el nombre o las respuestas no son válidos.' });
          return;
        }

        const result = database.prepare(`
          INSERT INTO responses (
            survey_id, respondent_name, demographics_json, answers_json
          ) VALUES (?, ?, ?, ?)
        `).run(
          survey.id,
          respondentName,
          JSON.stringify(body.demographics),
          JSON.stringify(body.answers),
        );
        sendJson(response, 201, { id: Number(result.lastInsertRowid), saved: true });
        return;
      } catch (error) {
        const isJsonError = error instanceof SyntaxError;
        sendJson(response, isJsonError ? 400 : 500, {
          error: isJsonError ? 'El cuerpo debe contener JSON válido.' : 'No se pudo guardar la respuesta.',
        });
        return;
      }
    }

    sendJson(response, 404, { error: 'Ruta no encontrada.' });
  });

  return {
    server,
    close() {
      database.close();
    },
  };
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const api = createApi();
  const port = Number(process.env.PORT ?? 3002);
  const host = process.env.HOST ?? '127.0.0.1';
  api.server.listen(port, host, () => {
    console.log(`Encuestas API disponible en http://localhost:${port}`);
  });
  process.on('SIGINT', () => {
    api.server.close(() => {
      api.close();
      process.exit(0);
    });
  });
}