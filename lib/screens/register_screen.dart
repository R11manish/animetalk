import 'package:animetalk/repository/register.dart';
import 'package:animetalk/utility/functions.dart';
import 'package:animetalk/widgets/otp_verification.dart';
import 'package:animetalk/widgets/unboarding.dart';
import 'package:flutter/material.dart';
import 'package:animetalk/models/user_details.dart';

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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleUserDetails(UserDetails details) async {
    try {
      await register.sendOtp(details);
      setState(() {
        _userDetails = details;
        _showOtpVerification = true;
      });
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _handleOtpVerification(String otp) async {
    try {
      await register.validateOtp(otp, _userDetails?.email);
      await SetFirstTime(false);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _handleResendOtp() async {
    try {
      if (_userDetails != null) {
        await register.sendOtp(_userDetails!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
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
