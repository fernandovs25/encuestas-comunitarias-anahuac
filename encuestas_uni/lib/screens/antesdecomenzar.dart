import 'package:encuestas_uni/app_theme.dart';
import 'package:encuestas_uni/screens/demograficos.dart';
import 'package:flutter/material.dart';

class AntesDeComenzar extends StatelessWidget {
  const AntesDeComenzar({
    super.key,
    required this.nombre,
    required this.surveyId,
  });

  final String nombre;
  final String surveyId;

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
                const _OrangeDecoration(),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SurveyBrandHeader(),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: appLine),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Antes de comenzar',
                              style: TextStyle(
                                color: appInk,
                                fontSize: 28,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 9),
                            const Text(
                              'Te invitamos a compartir tu opinión para entender mejor cómo vives tu comunidad y orientar los próximos apoyos.',
                              style: TextStyle(
                                color: appMuted,
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'ENCUESTA SELECCIONADA',
                              style: TextStyle(
                                color: Color(0xFF984A23),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Encuesta de participación comunitaria',
                              style: TextStyle(
                                color: appInk,
                                fontSize: 19,
                                height: 1.15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Row(
                              children: [
                                _SurveyInfoPill(
                                  icon: Icons.checklist,
                                  label: '8 preguntas',
                                ),
                                SizedBox(width: 8),
                                _SurveyInfoPill(
                                  icon: Icons.schedule,
                                  label: '5 min',
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.verified_user_outlined,
                                  size: 15,
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
                            const SizedBox(height: 18),
                            const Row(
                              children: [
                                Expanded(
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
                                  '0 de 8',
                                  style: TextStyle(
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
                              child: const LinearProgressIndicator(
                                value: 0,
                                minHeight: 6,
                                backgroundColor: Color(0xFFFFF0E1),
                                color: appOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 52,
                        child: TextButton.icon(
                          key: const Key('continueToDemographicsButton'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => Demograficos(
                                  nombre: nombre,
                                  surveyId: surveyId,
                                ),
                              ),
                            );
                          },
                          iconAlignment: IconAlignment.end,
                          icon: const Icon(Icons.arrow_forward, size: 19),
                          label: const Text('Comenzar encuesta'),
                          style: TextButton.styleFrom(
                            foregroundColor: appInk,
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const _OrganizationStrip(),
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

class _OrangeDecoration extends StatelessWidget {
  const _OrangeDecoration();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: _Circle(size: 210, color: Color(0x22FFFFFF)),
          ),
          Positioned(
            bottom: 60,
            left: -100,
            child: _Circle(size: 250, color: Color(0x188C3E13)),
          ),
          Positioned(
            top: 190,
            right: -30,
            child: _Circle(size: 90, color: Color(0x188C3E13)),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.color});

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

class _SurveyBrandHeader extends StatelessWidget {
  const _SurveyBrandHeader();

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

class _SurveyInfoPill extends StatelessWidget {
  const _SurveyInfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1E4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF984A23)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF984A23),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrganizationStrip extends StatelessWidget {
  const _OrganizationStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1E2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: appBackground,
            child: Text(
              'JFM',
              style: TextStyle(
                color: appInk,
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Juventud y Familia Misionera · Universidad Anáhuac Cancún',
              style: TextStyle(
                color: Color(0xFF87401F),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
