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
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': Icons.store_outlined,
      'title': 'Invest in local shops',
      'desc': 'Empower small businesses and grow your wealth.',
    },
    {
      'icon': Icons.trending_up_outlined,
      'title': 'Earn daily returns',
      'desc': 'Get rewarded every day for your investments.',
    },
    {
      'icon': Icons.people_outline,
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
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: widget.onGetStarted,
                    child: Text(
                      'Skip',
                      style: AppTypography.button.copyWith(
                        color: AppColors.primaryCyan,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: CarouselSlider.builder(
                  carouselController: _carouselController,
                  itemCount: _slides.length,
                  itemBuilder: (context, index, realIdx) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Clean icon container
                        Container(
                          height: 160,
                          width: 160,
                          decoration: BoxDecoration(
                            color: AppColors.primaryCyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(80),
                            border: Border.all(
                              color: AppColors.primaryCyan.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            slide['icon'],
                            size: 80,
                            color: AppColors.primaryCyan,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Semantics(
                          label:
                              'Onboarding slide ${index + 1} of ${_slides.length}',
                          child: Text(
                            slide['title'],
                            style: AppTypography.heroTitle.copyWith(
                              fontSize: 28,
                              color: AppColors.primaryText,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            slide['desc'],
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.secondaryText,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  },
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height * 0.65,
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
              // Clean Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _slides.asMap().entries.map((entry) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 4.0,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == entry.key
                          ? AppColors.primaryCyan
                          : AppColors.mutedText.withOpacity(0.3),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(228, 0, 213, 255),
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.button),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: _current == _slides.length - 1
                        ? widget.onGetStarted
                        : () => _carouselController.animateToPage(_current + 1),
                    child: Text(
                      _current == _slides.length - 1 ? 'Get Started' : 'Next',
                      style: AppTypography.buttonLarge.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
