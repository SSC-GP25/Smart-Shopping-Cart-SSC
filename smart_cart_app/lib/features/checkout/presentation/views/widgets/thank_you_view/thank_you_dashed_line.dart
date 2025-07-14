import 'package:flutter/material.dart';

class ThankYouDashedLine extends StatelessWidget {
  const ThankYouDashedLine({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.sizeOf(context).height * 0.16 + 20,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: List.generate(
            30,
            (index) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                height: 2,
                color: const Color(0xffb8b8b8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
