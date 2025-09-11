import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../design_tokens.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onGetStarted;
  const OnboardingScreen({super.key, required this.onGetStarted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _current = 0;
  final List<Map<String, String>> _slides = [
    {
      'image': 'assets/onboard1.png',
      'title': 'Invest in local shops',
      'desc': 'Empower small businesses and grow your wealth.',
    },
    {
      'image': 'assets/onboard2.png',
      'title': 'Earn daily returns',
      'desc': 'Get rewarded every day for your investments.',
    },
    {
      'image': 'assets/onboard3.png',
      'title': 'Support community growth',
      'desc': 'Be a part of the local economic revolution.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Column(
            children: [
              const SizedBox(height: 60),
              Expanded(
                child: CarouselSlider.builder(
                  itemCount: _slides.length,
                  itemBuilder: (context, index, realIdx) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Enhanced placeholder for images with dark theme
                        Container(
                          height: 240,
                          width: 240,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadii.card),
                            border: Border.all(
                              color: AppColors.primaryCyan.withValues(
                                alpha: 0.3,
                              ),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: AppElevation.blur,
                                offset: Offset(0, AppElevation.offsetY),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.store,
                            size: 120,
                            color: AppColors.primaryCyan,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Semantics(
                          label:
                              'Onboarding slide ${index + 1} of ${_slides.length}',
                          child: Text(
                            slide['title']!,
                            style: AppTypography.heroTitle.copyWith(
                              fontSize: 28,
                              color: AppColors.primaryText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          slide['desc']!,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.secondaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                  options: CarouselOptions(
                    height: 500,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: false,
                    enlargeCenterPage: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _slides.asMap().entries.map((entry) {
                  return Container(
                    width: 12.0,
                    height: 12.0,
                    margin: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 6.0,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == entry.key
                          ? AppColors.primaryCyan
                          : AppColors.mutedText.withValues(alpha: 0.3),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SizedBox(
                  width: double.infinity,
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
                    onPressed: widget.onGetStarted,
                    child: Text(
                      'Get Started',
                      style: AppTypography.buttonLarge.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
