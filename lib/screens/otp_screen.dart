import 'package:flutter/material.dart';
import 'package:flutter_otp_auth/provider/auth_provider.dart';
import 'package:flutter_otp_auth/screens/user_information.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../widgets/custom_button.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;

  const OtpScreen({
    Key? key,
    required this.verificationId,
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  @override
  Widget build(BuildContext context) {
    String? otpCode;
    final authProvider = context.read<AuthProvider>();
    final isLoading = authProvider.isLoading;
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
                ),
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
                child: Column(
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.purple.shade50,
                      ),
                      child: Image.asset('assets/landing.jpg'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Verification',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Enter the OTP send to your phone number',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black38,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Pinput(
                      length: 6,
                      onCompleted: (value) {
                        otpCode = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        onPressed: () {
                          if (otpCode != null) {
                            verifyOtp(context, otpCode!);
                          } else {
                            print('Exist Enter 6-digit code');
                          }
                        },
                        text: 'Verify',
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Didn\'t receive any code?',
                      style: TextStyle(
                        color: Colors.black38,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Resend new code',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  void verifyOtp(BuildContext context, String otpCode) {
    final authProvider = context.read<AuthProvider>();
    authProvider.verifyOtp(
      context: context,
      verificationId: widget.verificationId,
      userOtp: otpCode,
      onSuccess: () {
        authProvider.checkExistingUser().then(
          (isExist) {
            if (isExist) {
            } else {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserInformation(),
                  ),
                  (route) => false);
            }
          },
        );
      },
    );
  }
}
