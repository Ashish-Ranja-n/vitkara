import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../design_tokens.dart';
import '../services/auth_service.dart';

class WelcomeScreen extends StatefulWidget {
  final void Function(AuthResult) onContinue;
  const WelcomeScreen({super.key, required this.onContinue});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isContinueLoading = false;
  bool _isGoogleLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80),
                Text(
                  'Welcome to Vitkara',
                  style: AppTypography.heroTitle.copyWith(
                    fontSize: 36,
                    color: AppColors.primaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Enter your mobile number or email to continue',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                Form(
                  key: _formKey,
                  child: Semantics(
                    label: 'Enter your mobile number or email address',
                    hint: 'Type your phone number or email to continue',
                    child: TextFormField(
                      controller: _controller,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.primaryText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Mobile number or Email',
                        hintStyle: AppTypography.body.copyWith(
                          color: AppColors.mutedText,
                        ),
                        fillColor: AppColors.inputBackground,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.card),
                          borderSide: BorderSide(
                            color: AppColors.primaryCyan.withValues(alpha: 0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.card),
                          borderSide: BorderSide(
                            color: AppColors.primaryCyan.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.card),
                          borderSide: BorderSide(
                            color: AppColors.primaryCyan,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your mobile number or email';
                        }

                        // Email validation
                        if (value.contains('@')) {
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                        }
                        // Phone validation (Indian format)
                        else {
                          final phoneRegex = RegExp(
                            r'^(\+91[\-\s]?)?[0]?(91)?[789]\d{9}$',
                          );
                          if (!phoneRegex.hasMatch(value)) {
                            return 'Please enter a valid Indian mobile number';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCyan,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.button),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.primaryCyan.withValues(alpha: 0.3),
                    ),
                    onPressed: _isContinueLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isContinueLoading = true);

                              final result = await _authService.startAuth(
                                _controller.text.trim(),
                              );

                              if (mounted) {
                                setState(() => _isContinueLoading = false);
                                if (result.error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result.error!),
                                      backgroundColor: AppColors.warning,
                                    ),
                                  );
                                } else {
                                  widget.onContinue(result);
                                }
                              }
                            }
                          },
                    child: _isContinueLoading
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.background,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Sending OTP...',
                                style: AppTypography.buttonLarge.copyWith(
                                  color: AppColors.background,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Continue',
                            style: AppTypography.buttonLarge.copyWith(
                              color: AppColors.background,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'or',
                  style: AppTypography.body.copyWith(
                    color: AppColors.mutedText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 60,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryText,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                        color: AppColors.primaryCyan.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.button),
                      ),
                    ),
                    onPressed: _isGoogleLoading
                        ? null
                        : () async {
                            setState(() => _isGoogleLoading = true);

                            final result = await _authService
                                .signInWithGoogle();

                            if (mounted) {
                              setState(() => _isGoogleLoading = false);
                              if (result.error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result.error!),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                              } else {
                                // Pass the result to parent widget which will handle navigation
                                // based on isNew flag - ProfileInfoScreen or Dashboard
                                widget.onContinue(result);
                              }
                            }
                          },
                    icon: _isGoogleLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryCyan,
                              ),
                            ),
                          )
                        : SvgPicture.asset(
                            'assets/images/google_logo.svg',
                            height: 24,
                            width: 24,
                          ),
                    label: _isGoogleLoading
                        ? Text(
                            'Signing in...',
                            style: AppTypography.button.copyWith(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : Text(
                            'Continue with Google',
                            style: AppTypography.button.copyWith(
                              color: AppColors.primaryText,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
