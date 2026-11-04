import 'package:encuestas_uni/app_theme.dart';
import 'package:encuestas_uni/screens/antesdecomenzar.dart';
import 'package:encuestas_uni/services/survey_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CentroEncuestas extends StatefulWidget {
  const CentroEncuestas({super.key, required this.nombre});

  final String nombre;

  @override
  State<CentroEncuestas> createState() => _CentroEncuestasState();
}

class _CentroEncuestasState extends State<CentroEncuestas> {
  Future<List<SurveySummary>>? _surveysFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _surveysFuture ??= SurveyApiProvider.of(context).fetchSurveys();
  }

  void _reloadSurveys() {
    setState(() {
      _surveysFuture = SurveyApiProvider.of(context).fetchSurveys();
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstName = widget.nombre.split(RegExp(r'\s+')).first;

    return Scaffold(
      backgroundColor: appBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _welcomeHeader(firstName)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _surveyCard(),
                      const SizedBox(height: 17),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Tu actividad',
                              style: TextStyle(
                                color: appInk,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            iconAlignment: IconAlignment.end,
                            icon: const Icon(Icons.chevron_right, size: 18),
                            label: const Text('Ver historial'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF984A23),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      _activityRow(),
                      const SizedBox(height: 14),
                      _organizationStrip(),
                      const SizedBox(height: 18),
                      Center(
                        child: SvgPicture.asset(
                          'assets/images/logo_jfm.svg',
                          width: 92,
                          height: 88,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _welcomeHeader(String firstName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: const BoxDecoration(
        color: appOrange,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: appInk,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  'JFM',
                  style: TextStyle(
                    color: appOrange,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              const Column(
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
              const Spacer(),
              CircleAvatar(
                radius: 17,
                backgroundColor: appBackground,
                child: Text(
                  firstName.isEmpty ? '?' : firstName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF8A4722),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Hola, $firstName 👋',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: appInk,
              fontSize: 26,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Tu opinión ayuda a construir programas más cercanos a nuestra comunidad.',
            style: TextStyle(
              color: Color(0xFF62432D),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _surveyCard() {
    return FutureBuilder<List<SurveySummary>>(
      future: _surveysFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _surveyStatusCard('Cargando encuestas...');
        }
        if (snapshot.hasError) {
          return _surveyStatusCard(
            'No se pudo conectar con el servidor.',
            onRetry: _reloadSurveys,
          );
        }
        final surveys = snapshot.data ?? [];
        if (surveys.isEmpty) {
          return _surveyStatusCard('No hay encuestas disponibles.');
        }
        return _surveyCardContent(surveys.first);
      },
    );
  }

  Widget _surveyStatusCard(String message, {VoidCallback? onRetry}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: appLine),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(message, style: const TextStyle(color: appMuted)),
          ),
          if (onRetry != null)
            IconButton(
              onPressed: onRetry,
              tooltip: 'Reintentar',
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
    );
  }

  Widget _surveyCardContent(SurveySummary survey) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: appLine),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100E0905),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4EC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 7, color: Color(0xFF4C8A62)),
                    SizedBox(width: 5),
                    Text(
                      'DISPONIBLE',
                      style: TextStyle(
                        color: Color(0xFF4C8A62),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            survey.title,
            style: TextStyle(
              color: appInk,
              fontSize: 18,
              height: 1.12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            survey.description,
            style: TextStyle(color: appMuted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _InfoPill(
                icon: Icons.checklist,
                label: '${survey.questionCount} preguntas',
              ),
              SizedBox(width: 7),
              _InfoPill(icon: Icons.schedule, label: '5 min'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tu avance',
                  style: TextStyle(
                    color: appInk,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '0 de ${survey.questionCount}',
                style: const TextStyle(
                  color: appMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0,
              minHeight: 6,
              backgroundColor: const Color(0xFFFFF0E1),
              color: appOrange,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              key: const Key('startSurveyButton'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AntesDeComenzar(
                      nombre: widget.nombre,
                      surveyId: survey.id,
                    ),
                  ),
                );
              },
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Comenzar encuesta'),
              style: FilledButton.styleFrom(
                backgroundColor: appOrange,
                foregroundColor: appInk,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 13,
                  color: Color(0xFF4A9670),
                ),
                SizedBox(width: 5),
                Text(
                  'Tus respuestas son confidenciales',
                  style: TextStyle(color: appMuted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEFE1D5)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFEAF4EC),
            child: Icon(
              Icons.check_circle_outline,
              size: 18,
              color: Color(0xFF4C8A62),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diagnóstico familiar',
                  style: TextStyle(
                    color: appInk,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Completada · 28 sep 2026',
                  style: TextStyle(color: appMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            'Enviada',
            style: TextStyle(
              color: Color(0xFF4C8A62),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _organizationStrip() {
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
            backgroundColor: appOrange,
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

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1E4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF984A23)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF984A23),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
