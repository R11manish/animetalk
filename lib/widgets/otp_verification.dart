import 'dart:async';
import 'package:AnimeTalk/constants/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpVerificationDialog extends StatefulWidget {
  final Function(String) onVerify;
  final VoidCallback onResendOtp;

  const OtpVerificationDialog({
    super.key,
    required this.onVerify,
    required this.onResendOtp,
  });

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );

  Timer? _timer;
  int _timeLeft = 120;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft == 0) {
        timer.cancel();
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  String get formattedTime {
    int minutes = _timeLeft ~/ 60;
    int seconds = _timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _onOtpSubmit() {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length == 5) {
      widget.onVerify(otp);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppLogo(),
        const SizedBox(height: 16),
        const Text(
          'Enter OTP',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "We've sent a verification code to your email",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            6,
            (index) => SizedBox(
              width: 40,
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  }
                  if (value.isNotEmpty && index == 5) {
                    _onOtpSubmit();
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Code expires in $formattedTime',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _onOtpSubmit,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: Colors.deepPurpleAccent,
          ),
          child: const Text('Verify', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _timeLeft == 0
              ? () {
                  widget.onResendOtp();
                  setState(() {
                    _timeLeft = 120;
                  });
                  startTimer();
                }
              : null,
          child: Text(
            "Didn't receive the code?",
            style: TextStyle(
              color: _timeLeft == 0 ? Colors.black : Colors.grey,
            ),
          ),
        ),
        if (_timeLeft == 0)
          TextButton(
            onPressed: () {
              widget.onResendOtp();
              setState(() {
                _timeLeft = 160;
              });
              startTimer();
            },
            child: const Text(
              'Resend OTP',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
