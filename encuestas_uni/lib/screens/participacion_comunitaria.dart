import 'package:encuestas_uni/app_theme.dart';
import 'package:encuestas_uni/services/survey_api.dart';
import 'package:flutter/material.dart';

class ParticipacionComunitaria extends StatefulWidget {
  const ParticipacionComunitaria({
    super.key,
    required this.nombre,
    required this.surveyId,
    required this.demographics,
  });

  final String nombre;
  final String surveyId;
  final Map<String, String> demographics;

  @override
  State<ParticipacionComunitaria> createState() =>
      _ParticipacionComunitariaState();
}

class _ParticipacionComunitariaState extends State<ParticipacionComunitaria> {
  SurveyApi? _api;
  List<SurveyQuestion> _questions = [];
  List<String?> _answers = [];
  int _currentQuestion = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _loadError;
  String? _submitError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _api ??= SurveyApiProvider.of(context);
    if (_isLoading && _loadError == null && _questions.isEmpty) _loadSurvey();
  }

  Future<void> _loadSurvey() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final survey = await _api!.fetchSurvey(widget.surveyId);
      if (!mounted) return;
      setState(() {
        _questions = survey.questions;
        _answers = List<String?>.filled(_questions.length, null);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'No se pudo cargar la encuesta. Revisa la conexión e inténtalo de nuevo.';
        _isLoading = false;
      });
    }
  }

  Future<void> _advance() async {
    if (_answers[_currentQuestion] == null) return;
    if (_currentQuestion < _questions.length - 1) {
      setState(() => _currentQuestion++);
      return;
    }
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });
    try {
      await _api!.submitResponse(
        surveyId: widget.surveyId,
        respondentName: widget.nombre,
        demographics: widget.demographics,
        answers: _answers.cast<String>(),
      );
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Encuesta completada'),
          content: Text('Gracias por compartir tu opinión, ${widget.nombre}.'),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Finalizar'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _submitError = 'No se pudo guardar. Intenta enviarla de nuevo.',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _loadState() {
    return Scaffold(
      backgroundColor: appOrange,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoading)
                    const CircularProgressIndicator(color: appInk)
                  else ...[
                    Text(
                      _loadError ?? 'No hay preguntas disponibles.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: appInk, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _loadSurvey,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _loadError != null || _questions.isEmpty) {
      return _loadState();
    }
    final question = _questions[_currentQuestion];

    return Scaffold(
      backgroundColor: appOrange,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Stack(
              children: [
                const _QuestionBackdrop(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SurveyHeader(),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'PARTICIPACIÓN COMUNITARIA',
                              style: TextStyle(
                                color: appInk,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            '${_currentQuestion + 1} de ${_questions.length}',
                            style: const TextStyle(
                              color: appInk,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (_currentQuestion + 1) / _questions.length,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFFFF0E1),
                          color: appInk,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: appLine),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Pregunta ${_currentQuestion + 1}',
                                  style: const TextStyle(
                                    color: Color(0xFF984A23),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  question.prompt,
                                  key: const Key('surveyQuestionPrompt'),
                                  style: const TextStyle(
                                    color: appInk,
                                    fontSize: 23,
                                    height: 1.2,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                ...question.options.map(
                                  (option) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _AnswerOption(
                                      key: Key('answer_$option'),
                                      label: option,
                                      selected:
                                          _answers[_currentQuestion] == option,
                                      onTap: () => setState(
                                        () =>
                                            _answers[_currentQuestion] = option,
                                      ),
                                    ),
                                  ),
                                ),
                                const Text(
                                  'Tus respuestas son confidenciales.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: appMuted,
                                    fontSize: 11,
                                  ),
                                ),
                                if (_submitError != null) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    _submitError!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          if (_currentQuestion > 0)
                            IconButton(
                              tooltip: 'Pregunta anterior',
                              onPressed: () =>
                                  setState(() => _currentQuestion--),
                              icon: const Icon(Icons.arrow_back),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: appInk,
                                fixedSize: const Size(52, 52),
                              ),
                            ),
                          if (_currentQuestion > 0) const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: FilledButton.icon(
                                key: const Key('nextQuestionButton'),
                                onPressed:
                                    _answers[_currentQuestion] == null ||
                                        _isSubmitting
                                    ? null
                                    : _advance,
                                iconAlignment: IconAlignment.end,
                                icon: _isSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: appInk,
                                        ),
                                      )
                                    : Icon(
                                        _currentQuestion ==
                                                _questions.length - 1
                                            ? Icons.check
                                            : Icons.arrow_forward,
                                        size: 19,
                                      ),
                                label: Text(
                                  _isSubmitting
                                      ? 'Enviando...'
                                      : _currentQuestion ==
                                            _questions.length - 1
                                      ? _submitError == null
                                            ? 'Finalizar encuesta'
                                            : 'Reintentar envío'
                                      : 'Siguiente pregunta',
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFD97727),
                                  foregroundColor: appInk,
                                  disabledBackgroundColor: const Color(
                                    0xFFCC9B73,
                                  ),
                                  disabledForegroundColor: appInk,
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFFE6CC) : const Color(0xFFFFF8F1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? appOrange : appLine,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? appOrange : appMuted,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: appInk,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionBackdrop extends StatelessWidget {
  const _QuestionBackdrop();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -60,
            child: _BackdropCircle(size: 220, color: Color(0x22FFFFFF)),
          ),
          Positioned(
            bottom: -90,
            left: -90,
            child: _BackdropCircle(size: 250, color: Color(0x188C3E13)),
          ),
        ],
      ),
    );
  }
}

class _BackdropCircle extends StatelessWidget {
  const _BackdropCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SurveyHeader extends StatelessWidget {
  const _SurveyHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: appInk,
          child: Text(
            'JFM',
            style: TextStyle(
              color: appOrange,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Encuestas',
              style: TextStyle(
                color: appInk,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Anáhuac Cancún',
              style: TextStyle(color: Color(0xFF74401F), fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}
