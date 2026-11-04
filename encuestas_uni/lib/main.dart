import 'package:flutter/material.dart';
import 'package:encuestas_uni/app_theme.dart';
import 'package:encuestas_uni/services/survey_api.dart';
import 'package:encuestas_uni/screens/splashencuesta.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.surveyApi});

  final SurveyApi? surveyApi;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final SurveyApi _surveyApi;
  late final bool _ownsSurveyApi;

  @override
  void initState() {
    super.initState();
    _ownsSurveyApi = widget.surveyApi == null;
    _surveyApi = widget.surveyApi ?? SurveyApi();
  }

  @override
  void dispose() {
    if (_ownsSurveyApi) _surveyApi.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SurveyApiProvider(
      api: _surveyApi,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Encuestas Anáhuac Cancún',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: appOrange,
            surface: appBackground,
          ),
          scaffoldBackgroundColor: appBackground,
          useMaterial3: true,
        ),
        home: const Splashencuesta(),
      ),
    );
  }
}
