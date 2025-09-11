import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../design_tokens.dart';
import '../services/investor_service.dart';

class ProfileInfoScreen extends StatefulWidget {
  final VoidCallback onNext;
  const ProfileInfoScreen({super.key, required this.onNext});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  int _age = 30;
  FixedExtentScrollController? _ageCtrl;

  @override
  void initState() {
    super.initState();
    _ageCtrl = FixedExtentScrollController(initialItem: _age - 18);
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl?.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final investorService = InvestorService();
    final profile = await investorService.getProfile();

    if (profile != null) {
      setState(() {
        _nameCtrl.text = profile['name'] ?? '';
        _age = profile['age'] ?? 30;
        _ageCtrl = FixedExtentScrollController(initialItem: _age - 18);
      });
    }
  }

  Future<void> _saveAndNext() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final investorService = InvestorService();
    final success = await investorService.updateProfile(
      name: _nameCtrl.text.trim(),
      age: _age,
      location: 'Bengaluru, India',
      city: 'Delhi', // Default city
    );

    if (success != null) {
      final prefs = await SharedPreferences.getInstance();
      // Still save to local prefs for offline access
      await prefs.setString('profile_name', _nameCtrl.text.trim());
      await prefs.setInt('profile_age', _age);
      await prefs.setString('profile_location', 'Bengaluru, India');
      await prefs.setBool('flow_completed', true);
      widget.onNext();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save profile. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ages = List.generate(63, (i) => i + 18); // 18..80
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Complete profile',
          style: AppTypography.title.copyWith(color: AppColors.primaryText),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.edge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.inputBackground,
                            child: Icon(
                              Icons.person,
                              size: 48,
                              color: AppColors.primaryText,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Semantics(
                              label: 'Add profile photo',
                              hint: 'Tap to add or change your profile picture',
                              child: InkWell(
                                onTap: () {
                                  // Image picker intentionally omitted — implement with image_picker later.
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Add photo feature coming soon',
                                      ),
                                      backgroundColor: AppColors.warning,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryCyan,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.shadow,
                                        blurRadius: AppElevation.blur,
                                        offset: Offset(0, AppElevation.offsetY),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 20,
                                    color: AppColors.background,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Profile photo (optional)',
                        style: AppTypography.body.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Name',
                        style: AppTypography.sectionHeading.copyWith(
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        label: 'Enter your full name',
                        hint: 'Type your complete name',
                        child: TextFormField(
                          controller: _nameCtrl,
                          textInputAction: TextInputAction.next,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.primaryText,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Your full name',
                            hintStyle: AppTypography.body.copyWith(
                              color: AppColors.mutedText,
                            ),
                            filled: true,
                            fillColor: AppColors.inputBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadii.card,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.primaryCyan.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadii.card,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.primaryCyan.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadii.card,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.primaryCyan,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter your name'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Location',
                        style: AppTypography.sectionHeading.copyWith(
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(AppRadii.card),
                          border: Border.all(
                            color: AppColors.primaryCyan.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColors.primaryCyan,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Bengaluru, India',
                                style: AppTypography.body.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Location detection coming soon',
                                    ),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                              },
                              child: Text(
                                'Detect',
                                style: AppTypography.button.copyWith(
                                  color: AppColors.primaryCyan,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Age',
                        style: AppTypography.sectionHeading.copyWith(
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Semantics(
                        label: 'Select your age',
                        hint: 'Scroll to select your age',
                        child: SizedBox(
                          height: 100,
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: ListWheelScrollView.useDelegate(
                              controller: _ageCtrl,
                              itemExtent: 48,
                              diameterRatio: 1.6,
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (i) =>
                                  setState(() => _age = ages[i]),
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  if (index < 0 || index >= ages.length) {
                                    return null;
                                  }
                                  final val = ages[index];
                                  return RotatedBox(
                                    quarterTurns: 1,
                                    child: Center(
                                      child: Container(
                                        width: 64,
                                        height: 36,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: val == _age
                                              ? AppColors.primaryCyan
                                              : AppColors.surface,
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.card,
                                          ),
                                        ),
                                        child: Text(
                                          '$val',
                                          style: AppTypography.button.copyWith(
                                            color: val == _age
                                                ? AppColors.background
                                                : AppColors.primaryText,
                                            fontWeight: val == _age
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                childCount: ages.length,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _saveAndNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryCyan,
                            foregroundColor: AppColors.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadii.button,
                              ),
                            ),
                            elevation: 4,
                            shadowColor: AppColors.primaryCyan.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          child: Text(
                            'Next',
                            style: AppTypography.buttonLarge.copyWith(
                              color: AppColors.background,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
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
