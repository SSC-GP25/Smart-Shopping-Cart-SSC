import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'custom_text_form_field.dart';

class PasswordRecoveryViewBody extends StatelessWidget {
  PasswordRecoveryViewBody({
    super.key,
    required this.formKey,
    required this.emailController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final GlobalKey<FormFieldState> emailFieldKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        "assets/images/forgotPasswordIcon.svg",
                        height: 100,
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        "Password Recovery",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff1A2530),
                            ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "Please Enter Your Email Address To\nRecieve a Verification Code",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              CustomTextFormField(
                fieldKey: emailFieldKey,
                controller: emailController,
                label: "Email Address",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email Must Not Be Empty!";
                  }
                  return null;
                },
                onChanged: (value) {
                  emailFieldKey.currentState!.validate();
                },
                prefixIcon: const Icon(Icons.email),
                type: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // Password Recovery Code
                    }
                  },
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    backgroundColor:
                        WidgetStateProperty.all(const Color(0xff5b9ee1)),
                  ),
                  child: Text("Continue",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
