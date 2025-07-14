import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_cart_app/core/services/helper_functions.dart';
import 'package:smart_cart_app/features/authentication/presentation/manager/auth_cubit/auth_states.dart';
import '../../../../../core/routing/app_router.dart';
import '../../manager/auth_cubit/auth_cubit.dart';
import 'ForgotPasswordWidget.dart';
import 'custom_login_button.dart';
import 'custom_text_form_field.dart';
import 'dont_have_account_widget.dart';

class LoginViewBody extends StatelessWidget {
  LoginViewBody({super.key});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormFieldState> emailFieldKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> passwordFieldKey =
      GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is AuthLoginSuccess) {
          showCustomSnackBar(
              context: context, message: "Welcome Back!", vPadding: 16);
          if (state.loginModel.firstTime! == true) {
            GoRouter.of(context).push(AppRouter.categoriesView);
          } else {
            GoRouter.of(context)
                .go(AppRouter.homeView, extra: state.loginModel.id);
          }
          emailController.clear();
          passwordController.clear();
          AuthCubit.get(context).resetVisibility();
        } else if (state is AuthLoginFailure) {
          showCustomSnackBar(
              context: context, message: state.errMessage, vPadding: 64);
        }
      },
      builder: (context, state) {
        var cubit = AuthCubit.get(context);
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.15,
                      ),
                      SvgPicture.asset(
                        "assets/images/loginIcon.svg",
                        height: 100,
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        "Hello Again!",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff1A2530),
                            ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Welcome Back You've Been Missed!",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      CustomTextFormField(
                        fieldKey: emailFieldKey,
                        controller: emailController,
                        label: "Email Address",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "This field is required!";
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
                        height: 16,
                      ),
                      CustomTextFormField(
                        fieldKey: passwordFieldKey,
                        controller: passwordController,
                        label: "Password",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "This field is required!";
                          }

                          return null;
                        },
                        onChanged: (value) {
                          passwordFieldKey.currentState!.validate();
                        },
                        onSubmit: (p0) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (formKey.currentState!.validate()) {
                            cubit.loginUser(
                                email: emailController.text,
                                password: passwordController.text);
                          }
                          return null;
                        },
                        prefixIcon: const Icon(Icons.password),
                        type: TextInputType.text,
                        obsecureText: cubit.isPassword,
                        suffixIcon: IconButton(
                          icon: cubit.passwordIcon,
                          onPressed: () {
                            cubit.changePasswordVisibility();
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const ForgotPasswordWidget(),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomLoginButton(
                        formKey: formKey,
                        cubit: cubit,
                        emailController: emailController,
                        passwordController: passwordController,
                        isLoading: state is AuthLoginLoading,
                      ),
                    ],
                  ),
                ),
              ),
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: DoNotHaveAccountWidget(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
