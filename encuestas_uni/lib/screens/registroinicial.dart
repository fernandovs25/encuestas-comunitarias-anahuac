import 'package:encuestas_uni/app_theme.dart';
import 'package:encuestas_uni/screens/centro_encuestas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegistroInicial extends StatefulWidget {
  const RegistroInicial({super.key});

  @override
  State<RegistroInicial> createState() => _RegistroInicialState();
}

class _RegistroInicialState extends State<RegistroInicial> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => CentroEncuestas(nombre: _nameController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _BrandHeader(),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _panelDecoration(),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Bienvenido! 👋',
                          style: TextStyle(
                            color: appInk,
                            fontSize: 29,
                            height: 1.1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Antes de comenzar, necesitamos saber tu nombre. Lo utilizaremos para identificar quién está realizando las encuestas.\n¿Cuál es tu nombre?',
                          style: TextStyle(
                            color: appMuted,
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              size: 16,
                              color: Color(0xFF4A9670),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tus respuestas son confidenciales y solo se usarán para mejorar los programas de la comunidad.',
                                style: TextStyle(
                                  color: appMuted,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: _panelDecoration(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'TU NOMBRE',
                            style: TextStyle(
                              color: Color(0xFF93431F),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 9),
                          TextFormField(
                            key: const Key('nameField'),
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _continue(),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Escribe tu nombre para continuar.'
                                : null,
                            decoration: InputDecoration(
                              hintText: 'Escribe tu nombre',
                              filled: true,
                              fillColor: const Color(0xFFFFF1E4),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: appLine),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: appOrange,
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(height: 9),
                          const Text(
                            'Puedes usar tu nombre completo o el nombre que prefieras que aparezca en tus encuestas.',
                            style: TextStyle(
                              color: appMuted,
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 52,
                            child: FilledButton.icon(
                              key: const Key('continueButton'),
                              onPressed: _continue,
                              iconAlignment: IconAlignment.end,
                              icon: const Icon(Icons.arrow_forward, size: 19),
                              label: const Text('Continuar'),
                              style: FilledButton.styleFrom(
                                backgroundColor: appOrange,
                                foregroundColor: appInk,
                                textStyle: const TextStyle(
                                  fontSize: 15,
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
                  ),
                  const SizedBox(height: 16),
                  const _OrganizationStrip(),
                  const SizedBox(height: 30),
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/logo_jfm.svg',
                      width: 150,
                      height: 135,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

BoxDecoration _panelDecoration() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: appLine),
  boxShadow: const [
    BoxShadow(color: Color(0x100E0905), blurRadius: 16, offset: Offset(0, 7)),
  ],
);

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 19,
          backgroundColor: appInk,
          child: Text(
            'JFM',
            style: TextStyle(
              color: appOrange,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Encuestas',
              style: TextStyle(
                color: appInk,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Anáhuac Cancún',
              style: TextStyle(
                color: Color(0xFF8A4722),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OrganizationStrip extends StatelessWidget {
  const _OrganizationStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1E2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: appOrange,
            child: Text(
              'JFM',
              style: TextStyle(
                color: appInk,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Juventud y Familia Misionera · Universidad Anáhuac Cancún',
              style: TextStyle(
                color: Color(0xFF87401F),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
