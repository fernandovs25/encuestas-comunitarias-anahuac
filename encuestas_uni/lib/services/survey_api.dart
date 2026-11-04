import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

const communitySurveyId = 'participacion-comunitaria';
const _defaultApiBaseUrl = String.fromEnvironment(
  'SURVEY_API_BASE_URL',
  defaultValue: 'http://localhost:3002/api',
);

class SurveyApi {
  SurveyApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = (baseUrl ?? _defaultApiBaseUrl).replaceFirst(
        RegExp(r'/$'),
        '',
      );

  final http.Client _client;
  final String _baseUrl;

  Future<List<SurveySummary>> fetchSurveys() async {
    final response = await _client.get(Uri.parse('$_baseUrl/surveys'));
    final body = _decodeResponse(response);
    return (body['surveys'] as List<dynamic>)
        .map((item) => SurveySummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Survey> fetchSurvey(String id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/surveys/$id'));
    return Survey.fromJson(_decodeResponse(response));
  }

  Future<void> submitResponse({
    required String surveyId,
    required String respondentName,
    required Map<String, String> demographics,
    required List<String> answers,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/responses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'surveyId': surveyId,
        'respondentName': respondentName,
        'demographics': demographics,
        'answers': answers,
      }),
    );
    _decodeResponse(response);
  }

  void close() => _client.close();

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body is Map<String, dynamic>
          ? body['error'] as String? ?? 'Error de comunicación con el servidor.'
          : 'Error de comunicación con el servidor.';
      throw SurveyApiException(message);
    }
    if (body is! Map<String, dynamic>) {
      throw const SurveyApiException(
        'El servidor devolvió una respuesta inválida.',
      );
    }
    return body;
  }
}

class SurveyApiException implements Exception {
  const SurveyApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SurveySummary {
  const SurveySummary({
    required this.id,
    required this.title,
    required this.description,
    required this.questionCount,
  });

  final String id;
  final String title;
  final String description;
  final int questionCount;

  factory SurveySummary.fromJson(Map<String, dynamic> json) => SurveySummary(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    questionCount: json['questionCount'] as int,
  );
}

class Survey {
  const Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
  });

  final String id;
  final String title;
  final String description;
  final List<SurveyQuestion> questions;

  int get questionCount => questions.length;

  factory Survey.fromJson(Map<String, dynamic> json) => Survey(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    questions: (json['questions'] as List<dynamic>)
        .map((item) => SurveyQuestion.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}

class SurveyQuestion {
  const SurveyQuestion({required this.prompt, required this.options});

  final String prompt;
  final List<String> options;

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) => SurveyQuestion(
    prompt: json['prompt'] as String,
    options: (json['options'] as List<dynamic>).cast<String>(),
  );
}

class SurveyApiProvider extends InheritedWidget {
  const SurveyApiProvider({super.key, required this.api, required super.child});

  final SurveyApi api;

  static SurveyApi of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<SurveyApiProvider>();
    assert(
      provider != null,
      'SurveyApiProvider is missing above this context.',
    );
    return provider!.api;
  }

  @override
  bool updateShouldNotify(SurveyApiProvider oldWidget) => api != oldWidget.api;
}
