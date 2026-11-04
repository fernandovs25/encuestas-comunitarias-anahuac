# Encuestas comunitarias | Anáhuac Cancún

Prototipo móvil para consultar encuestas comunitarias y capturar respuestas. El cliente está desarrollado en Flutter; el servicio REST usa Node.js y SQLite.

## Requisitos

- Flutter y Dart compatibles con `encuestas_uni/pubspec.yaml`.
- Node.js 22.13 o posterior, con `node:sqlite` disponible.
- Google Chrome para ejecutar la versión web.

## Ejecutar en Chrome

Abre dos terminales desde la carpeta del repositorio.

En la primera, inicia el backend:

```powershell
cd backend
node server.mjs
```

En la segunda, inicia Flutter:

```powershell
cd encuestas_uni
flutter pub get
flutter run -d chrome
```

La API escucha en `http://localhost:3002`. Crea la base SQLite automáticamente en `backend/data/encuestas.sqlite` al iniciar por primera vez.

Para Android Emulator, indica el host del equipo:

```powershell
flutter run --dart-define=SURVEY_API_BASE_URL=http://10.0.2.2:3002/api
```

Para que el emulador Android alcance el backend, inícialo escuchando en todas las interfaces con `$env:HOST="0.0.0.0"; node server.mjs`. En un teléfono físico, reemplaza `10.0.2.2` por la dirección IP local del equipo que ejecuta el backend. Ambos dispositivos deben estar en la misma red.

## Verificación

Desde la carpeta del repositorio:

```powershell
node --test backend/test/server.test.mjs
cd encuestas_uni
flutter test
flutter analyze
```

## API

- `GET /health`: estado del servicio.
- `GET /api/surveys`: encuestas activas para el centro principal.
- `GET /api/surveys/:id`: detalle y preguntas de la encuesta.
- `POST /api/responses`: guarda nombre, datos demográficos y respuestas validadas.

El contrato detallado, el problema propuesto, los objetivos, el alcance y el modelo de datos están en [docs/documentacion_proyecto.md](docs/documentacion_proyecto.md).

## Limitaciones del prototipo

El servicio no tiene autenticación, control de acceso ni cifrado de datos y habilita CORS para desarrollo local. No uses información personal real ni despliegues este backend en producción hasta implementar controles de privacidad, HTTPS, autorización y respaldo de la base de datos. El historial visible en la app aún no consulta respuestas guardadas.

