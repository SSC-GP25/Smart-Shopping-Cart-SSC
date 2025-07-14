import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'verification_form.dart';

class VerificationViewBody extends StatelessWidget {
  const VerificationViewBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              "Email Verification",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "We sent your code to your Email\nThis code will expired in 15 minutes ",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF757575)),
            ),
            SizedBox(height: 16.h),
            const OtpForm(),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text(
                "Resend Code",
                style: TextStyle(color: Color(0xFF757575)),
              ),
            ),
            SizedBox(
              height: 16.h,
            ),
          ],
        ),
      ),
    );
  }
}
