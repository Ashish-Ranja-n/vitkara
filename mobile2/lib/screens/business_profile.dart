import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/text_input.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _locationController.text = 'Mumbai, Maharashtra'; // Default location
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _shopNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  void _detectLocation() {
    // TODO: Implement real geolocation
    setState(() {
      _locationController.text = 'Mumbai, Maharashtra';
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Location detected (mock)')));
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final profile = {
          'owner_name': _ownerNameController.text,
          'shop_name': _shopNameController.text,
          'location': _locationController.text,
        };

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_profile', profile.toString());
        await prefs.setBool('onboarding_complete', true);

        if (!mounted) return;

        Navigator.pushReplacementNamed(context, '/dashboard');
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save profile. Please try again.'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.horizontalPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Business Profile', style: AppTheme.headlineLarge),
                const SizedBox(height: 8),
                const Text(
                  'Tell us about your business to get started',
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                AppTextInput(
                  label: 'Owner Name',
                  controller: _ownerNameController,
                  validator: _validateRequired,
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                AppTextInput(
                  label: 'Shop Name',
                  controller: _shopNameController,
                  validator: _validateRequired,
                ),
                const SizedBox(height: 16),
                AppTextInput(
                  label: 'Location',
                  controller: _locationController,
                  validator: _validateRequired,
                  suffix: IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: _detectLocation,
                    tooltip: 'Detect location',
                  ),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'Save & Continue',
                  onPressed: _saveProfile,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
