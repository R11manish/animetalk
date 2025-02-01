import 'dart:convert';
import 'package:AnimeTalk/models/user_details.dart';
import 'package:AnimeTalk/widgets/otp_verification.dart';
import 'package:AnimeTalk/widgets/unboarding.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingFlow extends StatefulWidget {
  final Function(UserDetails) onUserDetailsSubmit;
  final Function(String) onOtpVerify;
  final VoidCallback onResendOtp;

  const OnboardingFlow({
    super.key,
    required this.onUserDetailsSubmit,
    required this.onOtpVerify,
    required this.onResendOtp,
  });

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  bool showOtp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: !showOtp
                ? UserOnboardingDialog(
                    onSubmit: (userDetails) {
                      widget.onUserDetailsSubmit(userDetails);
                      if (mounted) {
                        setState(() {
                          showOtp = true;
                        });
                      }
                    },
                  )
                : OtpVerificationDialog(
                    onVerify: widget.onOtpVerify,
                    onResendOtp: widget.onResendOtp,
                  ),
          ),
        ),
      ),
    );
  }
}

class FirstTimeUserCheck {
  static const String _isFirstTimeKey = 'isFirstTime';
  static const String _userDetailsKey = 'userDetails';

  Future<bool> isFirstTime(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(name) ?? true;
  }

  void showOnboardingFlow(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAdaptiveDialog(
          context: context,
          builder: (context) => OnboardingFlow(
                onUserDetailsSubmit: _saveUserDetails,
                onOtpVerify: (otp) => _handleOtpVerification(context, otp),
                onResendOtp: () {
                  // Handle OTP resend
                },
              ));
    });
  }

  Future<void> checkFirstTimeUser(BuildContext context) async {
    final isFirstTimeUser = await isFirstTime(_isFirstTimeKey);
    if (isFirstTimeUser && context.mounted) {
      showOnboardingFlow(context);
    }
  }

  Future<void> _handleOtpVerification(BuildContext context, String otp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstTimeKey, false);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveUserDetails(UserDetails userDetails) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = userDetails.toJson();
    await prefs.setString(_userDetailsKey, jsonEncode(userJson));
  }

  Future<UserDetails?> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userDetailsKey);
    if (userJson != null) {
      final Map<String, dynamic> json = jsonDecode(userJson);
      return UserDetails.fromJson(json);
    }
    return null;
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
