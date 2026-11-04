// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:encuestas_uni/main.dart';
import 'package:encuestas_uni/services/survey_api.dart';

void main() {
  late SurveyApi surveyApi;
  var responseSaved = false;

  setUp(() {
    responseSaved = false;
    surveyApi = SurveyApi(
      baseUrl: 'http://test.local/api',
      client: MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/surveys') {
          return http.Response(
            jsonEncode({
              'surveys': [
                {
                  'id': communitySurveyId,
                  'title': 'Encuesta de participación comunitaria',
                  'description': 'Cuéntanos cómo vives tu comunidad.',
                  'questionCount': 8,
                },
              ],
            }),
            200,
          );
        }
        if (request.method == 'GET' &&
            request.url.path == '/api/surveys/$communitySurveyId') {
          return http.Response(
            jsonEncode({
              'id': communitySurveyId,
              'title': 'Encuesta de participación comunitaria',
              'description': 'Cuéntanos cómo vives tu comunidad.',
              'questions': [
                {
                  'prompt':
                      '¿Cómo describirías la convivencia en tu comunidad?',
                  'options': ['Muy buena', 'Buena', 'Regular', 'Mala'],
                },
                for (var index = 1; index < 8; index++)
                  {
                    'prompt': 'Pregunta de prueba ${index + 1}',
                    'options': ['Opción ${index + 1}', 'Otra opción'],
                  },
              ],
            }),
            200,
          );
        }
        if (request.method == 'POST' && request.url.path == '/api/responses') {
          final payload = jsonDecode(request.body) as Map<String, dynamic>;
          if (payload['demographics'] is! Map<String, dynamic>) {
            return http.Response(
              jsonEncode({'error': 'Faltan datos demográficos.'}),
              400,
            );
          }
          responseSaved = true;
          return http.Response(jsonEncode({'id': 1, 'saved': true}), 201);
        }
        return http.Response(jsonEncode({'error': 'Ruta no encontrada.'}), 404);
      }),
    );
  });

  tearDown(() => surveyApi.close());

  testWidgets('registration continues to the survey center', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(surveyApi: surveyApi));
    expect(find.text('Encuestas'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('¡Bienvenido! 👋'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('nameField')), 'Mariana López');
    await tester.ensureVisible(find.byKey(const Key('continueButton')));
    await tester.tap(find.byKey(const Key('continueButton')));
    await tester.pumpAndSettle();

    expect(find.text('Hola, Mariana 👋'), findsOneWidget);
    expect(find.text('Encuesta de participación comunitaria'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('startSurveyButton')));
    await tester.tap(find.byKey(const Key('startSurveyButton')));
    await tester.pumpAndSettle();
    expect(find.text('Antes de comenzar'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('continueToDemographicsButton')),
    );
    await tester.tap(find.byKey(const Key('continueToDemographicsButton')));
    await tester.pumpAndSettle();
    expect(find.text('DEMOGRÁFICOS'), findsOneWidget);
    expect(find.text('APELLIDO FAMILIA ENCUESTADA'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).last, 'García');
    for (final label in [
      'Número de habitantesDropdown',
      'Menores de 18 añosDropdown',
      'Mayores de 18 añosDropdown',
      'Oficio de persona a cargo de la familiaDropdown',
      'Estado civil de persona a cargo de la familiaDropdown',
    ]) {
      final field = tester.widget<DropdownButtonFormField<String>>(
        find.byKey(Key(label)),
      );
      final answer = label.startsWith('Oficio')
          ? 'Empleado/a'
          : label.startsWith('Estado civil')
          ? 'Soltero/a'
          : '2';
      field.onChanged!(answer);
      await tester.pumpAndSettle();
    }

    expect(find.text('DEMOGRÁFICOS'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('nextSurveyPartButton')),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('nextSurveyPartButton')));
    await tester.pumpAndSettle();
    expect(find.text('PARTICIPACIÓN COMUNITARIA'), findsOneWidget);
    expect(find.byKey(const Key('surveyQuestionPrompt')), findsOneWidget);
    await tester.tap(find.byKey(const Key('answer_Muy buena')));
    await tester.pumpAndSettle();
    final nextButton = tester.widget<FilledButton>(
      find.byKey(const Key('nextQuestionButton')),
    );
    expect(nextButton.onPressed, isNotNull);
    await tester.tap(find.byKey(const Key('nextQuestionButton')));
    await tester.pumpAndSettle();
    expect(find.text('Pregunta 2'), findsOneWidget);

    for (var index = 1; index < 8; index++) {
      await tester.tap(find.byKey(Key('answer_Opción ${index + 1}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('nextQuestionButton')));
      await tester.pumpAndSettle();
    }
    expect(find.text('Encuesta completada'), findsOneWidget);
    expect(responseSaved, isTrue);
  });
}
