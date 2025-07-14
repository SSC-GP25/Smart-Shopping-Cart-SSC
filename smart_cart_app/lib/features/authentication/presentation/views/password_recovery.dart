import 'package:flutter/material.dart';
import 'widgets/password_recovery_view_body.dart';

class PasswordRecoveryView extends StatelessWidget {
  PasswordRecoveryView({super.key});
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(scrolledUnderElevation: 0),
        body: PasswordRecoveryViewBody(
            formKey: formKey, emailController: emailController),
      ),
    );
  }
}
