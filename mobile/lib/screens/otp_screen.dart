import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../design_tokens.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  final Function(AuthResult) onVerified;
  final String pendingId;
  const OtpScreen({
    super.key,
    required this.onVerified,
    required this.pendingId,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'OTP Verification',
                  style: AppTypography.title.copyWith(
                    color: AppColors.primaryText,
                    fontSize: 32,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Enter the 4–6 digit code sent to you',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                Form(
                  key: _formKey,
                  child: Semantics(
                    label: 'Enter your 4 to 6 digit OTP code',
                    hint: 'Type the verification code sent to your device',
                    child: TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: AppTypography.title.copyWith(
                        fontSize: 24,
                        letterSpacing: 20,
                        color: AppColors.primaryText,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '••••••',
                        hintStyle: AppTypography.title.copyWith(
                          fontSize: 24,
                          letterSpacing: 20,
                          color: AppColors.mutedText,
                        ),
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
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 4) {
                          return 'Enter a valid OTP';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 50),
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
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              try {
                                final auth = Provider.of<AuthProvider>(
                                  context,
                                  listen: false,
                                );
                                await auth.verifyOtp(_otpController.text);
                                if (mounted) {
                                  widget.onVerified(
                                    AuthResult(
                                      accessToken: auth.state.accessToken,
                                      refreshToken: auth.state.refreshToken,
                                      user: auth.state.user,
                                      isNew: auth.state.isNewUser,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor: AppColors.warning,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                }
                              }
                            }
                          },
                    child: _isLoading
                        ? SizedBox(
                            height: 28,
                            width: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.background,
                              ),
                            ),
                          )
                        : Text(
                            'Verify',
                            style: AppTypography.buttonLarge.copyWith(
                              color: AppColors.background,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
