import 'package:flutter/material.dart';

class ThankYouCheckMark extends StatelessWidget {
  const ThankYouCheckMark({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      left: 0,
      right: 0,
      top: -35,
      child: CircleAvatar(
        radius: 35,
        backgroundColor: Color(0xffededed),
        child: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.green,
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}
