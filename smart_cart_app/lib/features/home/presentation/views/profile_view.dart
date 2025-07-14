import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/quickalert.dart';
import 'package:smart_cart_app/core/routing/app_router.dart';
import 'package:smart_cart_app/core/services/helper_functions.dart';
import 'package:smart_cart_app/features/authentication/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:smart_cart_app/features/authentication/presentation/manager/auth_cubit/auth_states.dart';
import 'package:smart_cart_app/features/home/presentation/manager/home_cubit/home_cubit.dart';
import 'package:smart_cart_app/features/home/presentation/manager/layout_cubit/layout_cubit.dart';
import 'package:smart_cart_app/features/home/presentation/views/widgets/custom_home_app_bar.dart';
import 'package:smart_cart_app/features/rating/presentation/manager/rating_cubit.dart';

import 'widgets/profile_info_widget.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is AuthLogoutSuccess) {
            GoRouter.of(context).go(AppRouter.loginView);
          } else if (state is AuthLogoutFailure) {
            showCustomSnackBar(
                context: context, message: state.errMessage, vPadding: 16);
          }
        },
        builder: (context, state) {
          var cubit = AuthCubit.get(context);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                    child: CustomHomeAppBar(title: "Profile")),
                const SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            AssetImage("assets/images/profilePic.png"),
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 20,
                  ),
                ),
                SliverToBoxAdapter(
                  child: ProfileInfoWidget(
                    preIcon: Icons.person,
                    label: "Name",
                    value:
                        context.read<AuthCubit>().loginModel?.name ?? "Unknown",
                  ),
                ),
                const SliverToBoxAdapter(child: MyDivider()),
                SliverToBoxAdapter(
                  child: ProfileInfoWidget(
                    preIcon: Icons.email,
                    label: "Email",
                    value: context.read<AuthCubit>().loginModel?.email ??
                        "Unknown",
                  ),
                ),
                const SliverToBoxAdapter(child: MyDivider()),
                const SliverToBoxAdapter(
                  child: ProfileInfoWidget(
                    preIcon: Icons.password,
                    label: "Change Password",
                    value: "*********",
                  ),
                ),
                const SliverToBoxAdapter(child: MyDivider()),
                SliverToBoxAdapter(
                  child: InkWell(
                    onTap: () {
                      RatingCubit.get(context).gerUserOrders();
                      GoRouter.of(context).push(AppRouter.userOrdersView);
                    },
                    overlayColor: WidgetStateColor.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: const ProfileInfoWidget(
                      preIcon: Icons.card_travel,
                      label: "Your Orders",
                      value: "",
                    ),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: BlocBuilder<AuthCubit, AuthStates>(
                      builder: (context, state) => TextButton(
                          onPressed: () {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.confirm,
                              title: "Are you sure?",
                              text: "You will be logged out",
                              confirmBtnColor: Colors.redAccent,
                              showCancelBtn: true,
                              onCancelBtnTap: () => Navigator.pop(context),
                              onConfirmBtnTap: () {
                                Navigator.pop(context);
                                print(
                                    "Logging out user: ${cubit.loginModel?.id} , Cart ID: ${context.read<HomeCubit>().cartId}");
                                if (context
                                    .read<HomeCubit>()
                                    .cartId
                                    .isNotEmpty) {
                                  HomeCubit.get(context).removeUserFromCart(
                                      context.read<HomeCubit>().cartId,
                                      cubit.loginModel!.id!);
                                }

                                AuthCubit.get(context).logoutUser();
                                LayoutCubit.get(context).changeBottomNav(0);
                              },
                            );
                          },
                          child: state is AuthSignUpLoading
                              ? const SizedBox(
                                  height: 15,
                                  width: 15,
                                  child: CircularProgressIndicator(
                                    color: Colors.redAccent,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Logout",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(color: Colors.redAccent),
                                )),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class MyDivider extends StatelessWidget {
  const MyDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: 0.5,
      endIndent: 20,
      indent: 20,
      color: Colors.grey.withAlpha(50),
    );
  }
}
