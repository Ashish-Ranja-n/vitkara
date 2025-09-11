import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/investor_dashboard.dart';
import 'screens/profile_info_screen.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MbdimApp());
}

class MbdimApp extends StatelessWidget {
  const MbdimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vitkara',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          textTheme: GoogleFonts.poppinsTextTheme(),
          scaffoldBackgroundColor: Colors.white,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            // Show loading while checking auth state
            if (auth.state.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (auth.state.isAuthenticated && !auth.state.isNewUser) {
              return const InvestorDashboard();
            }

            // If authenticated but new user, start from profile completion
            if (auth.state.isAuthenticated && auth.state.isNewUser) {
              return ProfileInfoScreen(
                onNext: () {
                  auth.markFlowCompleted();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const InvestorDashboard(),
                      ),
                    );
                  }
                },
              );
            }

            return const MbdimFlow();
          },
        ),
      ),
    );
  }
}

class MbdimFlow extends StatefulWidget {
  const MbdimFlow({super.key});

  @override
  State<MbdimFlow> createState() => _MbdimFlowState();
}

class _MbdimFlowState extends State<MbdimFlow> {
  int _step = 0;
  String? _pendingId;
  bool _initialized = false;

  void _handleAuthStart(AuthResult result) {
    if (result.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.error!)));
      return;
    }

    // Handle Google Sign In result
    if (result.accessToken != null) {
      _handleAuthVerified(result);
      return;
    }

    // Handle OTP flow
    if (result.pendingId != null) {
      setState(() {
        _pendingId = result.pendingId;
        _step++; // Move to OTP screen
      });
    }
  }

  void _handleAuthVerified(AuthResult result) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (result.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.error!)));
      auth.signOut();
      setState(() => _step = 1);
      return;
    }

    // Update auth state with the new tokens
    auth.updateAuthState(
      isAuthenticated: true,
      isNewUser: result.isNew,
      token: result.accessToken,
      user: result.user,
    );

    // If user is new, go to profile completion
    if (result.isNew) {
      setState(() => _step = 3); // Profile Info Screen
    } else {
      setState(() => _step = 4); // Dashboard
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      _initialized = true;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.state.justSignedOut) {
        auth.resetJustSignedOut();
        _step = 1;
      }
    }

    switch (_step) {
      case 0:
        return OnboardingScreen(onGetStarted: () => setState(() => _step++));
      case 1:
        return WelcomeScreen(onContinue: _handleAuthStart);
      case 2:
        if (_pendingId == null) {
          setState(() => _step = 1);
          return WelcomeScreen(onContinue: _handleAuthStart);
        }
        return OtpScreen(
          pendingId: _pendingId!,
          onVerified: _handleAuthVerified,
        );
      case 3:
        return ProfileInfoScreen(
          onNext: () {
            final auth = Provider.of<AuthProvider>(context, listen: false);
            auth.markFlowCompleted();
            if (mounted) {
              setState(() => _step = 4);
            }
          },
        );
      case 4:
        return const InvestorDashboard();
      default:
        return OnboardingScreen(onGetStarted: () => setState(() => _step++));
    }
  }
}
