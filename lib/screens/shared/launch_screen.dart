import 'package:flutter/material.dart';

import '../../l10n.dart';
import '../../theme.dart';
import 'login_screen.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 88, this.onDark = false});
  final double size;

  /// White version, for use on the brand gradient.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: onDark ? Colors.white : null,
            gradient: onDark ? null : kBrandGradient,
            borderRadius: BorderRadius.circular(size * 0.3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x402347D9),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.medical_services_rounded,
            size: size * 0.55,
            color: onDark ? kPrimary : Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'MyDoctor',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: onDark ? Colors.white : kPrimary,
          ),
        ),
      ],
    );
  }
}

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kBrandGradient),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutBack,
              builder: (context, v, child) =>
                  Transform.scale(scale: v, child: child),
              child: const AppLogo(onDark: true),
            ),
            const SizedBox(height: 8),
            Text(
              t('Your doctor, one tap away'),
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 36),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
