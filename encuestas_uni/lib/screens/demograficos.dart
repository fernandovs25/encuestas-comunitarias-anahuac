import 'package:encuestas_uni/app_theme.dart';
import 'package:encuestas_uni/screens/participacion_comunitaria.dart';
import 'package:flutter/material.dart';

class Demograficos extends StatefulWidget {
  const Demograficos({super.key, required this.nombre, required this.surveyId});

  final String nombre;
  final String surveyId;

  @override
  State<Demograficos> createState() => _DemograficosState();
}

class _DemograficosState extends State<Demograficos> {
  final _formKey = GlobalKey<FormState>();
  final _surnameController = TextEditingController();
  String? _residents;
  String? _minors;
  String? _adults;
  String? _occupation;
  String? _maritalStatus;

  static const _numberOptions = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10 o más',
  ];
  static const _occupationOptions = [
    'Empleado/a',
    'Trabajo por cuenta propia',
    'Hogar',
    'Estudiante',
    'Desempleado/a',
    'Otro',
  ];
  static const _maritalOptions = [
    'Soltero/a',
    'Casado/a',
    'Unión libre',
    'Separado/a o divorciado/a',
    'Viudo/a',
  ];

  @override
  void dispose() {
    _surnameController.dispose();
    super.dispose();
  }

  int get _answeredCount {
    return [
      _surnameController.text.trim().isNotEmpty,
      _residents != null,
      _minors != null,
      _adults != null,
      _occupation != null,
      _maritalStatus != null,
    ].where((answered) => answered).length;
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ParticipacionComunitaria(
          nombre: widget.nombre,
          surveyId: widget.surveyId,
          demographics: {
            'surname': _surnameController.text.trim(),
            'residents': _residents!,
            'minors': _minors!,
            'adults': _adults!,
            'occupation': _occupation!,
            'maritalStatus': _maritalStatus!,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appOrange,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Stack(
              children: [
                const _SurveyBackground(),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _DemographicsHeader(),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(21),
                          border: Border.all(color: appLine),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'DEMOGRÁFICOS',
                                style: TextStyle(
                                  color: appInk,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _textQuestion(
                                label: 'APELLIDO FAMILIA ENCUESTADA',
                                hint: 'Apellido',
                                controller: _surnameController,
                              ),
                              _dropdownQuestion(
                                label: 'Número de habitantes',
                                hint: 'Seleccionar número',
                                value: _residents,
                                options: _numberOptions,
                                onChanged: (value) =>
                                    setState(() => _residents = value),
                              ),
                              _dropdownQuestion(
                                label: 'Menores de 18 años',
                                hint: 'Seleccionar número',
                                value: _minors,
                                options: _numberOptions,
                                onChanged: (value) =>
                                    setState(() => _minors = value),
                              ),
                              _dropdownQuestion(
                                label: 'Mayores de 18 años',
                                hint: 'Seleccionar número',
                                value: _adults,
                                options: _numberOptions,
                                onChanged: (value) =>
                                    setState(() => _adults = value),
                              ),
                              _dropdownQuestion(
                                label:
                                    'Oficio de persona a cargo de la familia',
                                hint: 'Seleccionar oficio',
                                value: _occupation,
                                options: _occupationOptions,
                                onChanged: (value) =>
                                    setState(() => _occupation = value),
                              ),
                              _dropdownQuestion(
                                label: 'Estado civil de persona a cargo de la familia',
                                hint: 'Seleccionar estado civil',
                                value: _maritalStatus,
                                options: _maritalOptions,
                                onChanged: (value) =>
                                    setState(() => _maritalStatus = value),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Tu avance',
                                      style: TextStyle(
                                        color: appInk,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$_answeredCount de 10',
                                    style: const TextStyle(
                                      color: appMuted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: _answeredCount / 10,
                                  minHeight: 6,
                                  backgroundColor: const Color(0xFFFFF0E1),
                                  color: appOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 52,
                        child: FilledButton.icon(
                          key: const Key('nextSurveyPartButton'),
                          onPressed: _continue,
                          iconAlignment: IconAlignment.end,
                          icon: const Icon(Icons.arrow_forward, size: 19),
                          label: const Text('Siguiente parte de la encuesta'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFD97727),
                            foregroundColor: appInk,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
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

  Widget _textQuestion({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: appInk,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Este campo es obligatorio.'
                : null,
            decoration: _fieldDecoration(hint),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _dropdownQuestion({
    required String label,
    required String hint,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: appInk,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            key: Key('${label}Dropdown'),
            initialValue: value,
            isExpanded: true,
            validator: (_) => value == null ? 'Selecciona una opción.' : null,
            decoration: _fieldDecoration(hint),
            items: options
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(option, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF8F8F8F),
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0xFFE0E0E0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: appInk, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}

class _SurveyBackground extends StatelessWidget {
  const _SurveyBackground();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -70,
            child: _BackgroundCircle(size: 260, color: Color(0x22FFFFFF)),
          ),
          Positioned(
            top: -85,
            right: -80,
            child: _BackgroundCircle(size: 220, color: Color(0x22FFFFFF)),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: _BackgroundCircle(size: 260, color: Color(0x188C3E13)),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: _BackgroundCircle(size: 220, color: Color(0x18FFFFFF)),
          ),
        ],
      ),
    );
  }
}

class _BackgroundCircle extends StatelessWidget {
  const _BackgroundCircle({required this.size, required this.color});

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

class _DemographicsHeader extends StatelessWidget {
  const _DemographicsHeader();

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
