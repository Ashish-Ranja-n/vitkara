import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'screens/intro_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/otp_verification.dart';
import 'screens/business_profile.dart';
import 'screens/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop Business',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const OnboardingCheck(),
      routes: {
        '/intro': (context) => const IntroScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/otp': (context) => const OtpVerificationScreen(),
        '/business-profile': (context) => const BusinessProfileScreen(),
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}

class OnboardingCheck extends StatelessWidget {
  const OnboardingCheck({super.key});

  Future<bool> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkOnboarding(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          // Onboarding complete, go to dashboard
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          });
        } else {
          // Start onboarding
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/intro');
          });
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
