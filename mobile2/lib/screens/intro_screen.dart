import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.horizontalPadding),
          child: Column(
            children: [
              const Spacer(flex: 1),
              // TODO: Replace with actual intro image
              Expanded(
                flex: 4,
                child: Image.asset(
                  'assets/images/intro.png',
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(flex: 1),
              const Text(
                'Grow your shop with small, local funding',
                style: AppTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Get quick access to working capital from your local community. Build trust, grow faster, and expand your business.',
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Get Started',
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  '/welcome',
                ),
              ),
              const SizedBox(height: AppTheme.horizontalPadding),
            ],
          ),
        ),
      ),
    );
  }
}
