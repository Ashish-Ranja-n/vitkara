import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/text_input.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  bool _isEmail = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  String? _validateContact(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email or mobile number';
    }
    if (_isEmail && !value.contains('@')) {
      return 'Please enter a valid email address';
    }
    if (!_isEmail &&
        (value.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(value))) {
      return 'Please enter a valid 10-digit mobile number';
    }
    return null;
  }

  void _updateInputType(String value) {
    setState(() {
      _isEmail = value.contains('@');
    });
  }

  Future<void> _continue() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_contact', _contactController.text);
        await prefs.setBool('is_email_contact', _isEmail);

        if (!mounted) return;

        Navigator.pushReplacementNamed(context, '/otp');
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save contact. Please try again.'),
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.horizontalPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create your account',
                  style: AppTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your email or mobile number to continue',
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                AppTextInput(
                  label: 'Email or Mobile Number',
                  controller: _contactController,
                  validator: _validateContact,
                  keyboardType: _isEmail
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                  onChanged: _updateInputType,
                  autofocus: true,
                ),
                const Spacer(),
                PrimaryButton(
                  text: 'Continue',
                  onPressed: _continue,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/otp'),
                    child: const Text('Already have an account?'),
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
