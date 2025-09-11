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
                // Logo section with Vitkara logo
                Center(
                  child: Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(
                        color: AppColors.primaryCyan.withOpacity(0.7),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/vitkara_logo.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Welcome to Vitkara',
                  style: AppTypography.heroTitle.copyWith(
                    fontSize: 32,
                    color: AppColors.primaryText,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'An Investment Marketplace',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
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
                        fillColor: AppColors.surface,
                        filled: true,
                        prefixIcon: Icon(
                          Icons.phone_android_outlined,
                          color: AppColors.primaryCyan,
                          size: 24,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.card),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.card),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.card),
                          borderSide: BorderSide(
                            color: AppColors.primaryCyan,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
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
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(227, 0, 213, 255),
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.button),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
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
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.background,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Sending OTP...',
                                style: AppTypography.button.copyWith(
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.mutedText.withOpacity(0.2),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.mutedText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.mutedText.withOpacity(0.2),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryText,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                        color: AppColors.mutedText.withOpacity(0.2),
                        width: 1,
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
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryCyan,
                              ),
                            ),
                          )
                        : SvgPicture.asset(
                            'assets/images/google_logo.svg',
                            height: 20,
                            width: 20,
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
                              fontWeight: FontWeight.w500,
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
