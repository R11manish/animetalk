import 'package:AnimeTalk/core/network/api_client.dart';
import 'package:AnimeTalk/core/network/api_endpoints.dart';
import 'package:AnimeTalk/repository/register.dart';
import 'package:AnimeTalk/utility/functions.dart';
import 'package:AnimeTalk/widgets/otp_verification.dart';
import 'package:AnimeTalk/widgets/unboarding.dart';
import 'package:flutter/material.dart';
import 'package:AnimeTalk/models/user_details.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _showOtpVerification = false;
  UserDetails? _userDetails;
  late Register register;

  @override
  void initState() {
    super.initState();
    register = Register();
  }

  void _handleUserDetails(UserDetails details) async {
    await register.sendOtp(details);
    setState(() {
      _userDetails = details;
      _showOtpVerification = true;
    });
  }

  void _handleOtpVerification(String otp) {
    // Here you would verify the OTP with your backend
    print('OTP Verified: $otp');
    SetFirstTime(false);
    Navigator.pushReplacementNamed(context, '/main');
  }

  void _handleResendOtp() {
    print('Resending OTP...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: _showOtpVerification
              ? OtpVerificationDialog(
                  onVerify: _handleOtpVerification,
                  onResendOtp: _handleResendOtp,
                )
              : UserOnboardingDialog(
                  onSubmit: _handleUserDetails,
                ),
        ),
      )),
    );
  }
}
