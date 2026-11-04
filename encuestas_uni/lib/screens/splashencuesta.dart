import 'dart:async';

import 'package:encuestas_uni/app_theme.dart';
import 'package:encuestas_uni/screens/registroinicial.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Splashencuesta extends StatefulWidget {
  const Splashencuesta({super.key});

  @override
  State<Splashencuesta> createState() => _SplashencuestaState();
}

class _SplashencuestaState extends State<Splashencuesta> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(
      const Duration(milliseconds: 1800),
      _openRegistration,
    );
  }

  void _openRegistration() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const RegistroInicial()),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appOrange,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/logo_jfm.svg',
                    width: 210,
                    height: 210,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Encuestas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: appInk,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Anáhuac Cancún',
                    style: TextStyle(
                      color: Color(0xFF684022),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 36),
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: appInk,
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
