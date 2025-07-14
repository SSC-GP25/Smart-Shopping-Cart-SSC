import 'package:flutter/material.dart';

import 'widgets/thank_you_view/thank_you_view_body.dart';

class ThankYouView extends StatelessWidget {
  const ThankYouView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // appBar: AppBar(),
      body: ThankYouViewBody(),
    );
  }
}
