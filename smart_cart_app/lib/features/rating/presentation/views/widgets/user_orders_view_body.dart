import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_cart_app/core/services/helper_functions.dart';
import 'package:smart_cart_app/core/themes/light_theme/app_colors_light.dart';
import 'package:smart_cart_app/features/rating/presentation/manager/rating_cubit.dart';

import '../../../../home/presentation/views/widgets/custom_home_app_bar.dart';
import 'user_orders_list_view_item.dart';

class UserOrdersViewBody extends StatelessWidget {
  const UserOrdersViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RatingCubit, RatingState>(listener: (context, state) {
      if (state is RatingGetUserOrdersFailure) {
        showCustomSnackBar(
            context: context, message: state.errMessage, vPadding: 32);
      }
    }, builder: (context, state) {
      var cubit = RatingCubit.get(context);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomHomeAppBar(title: "Your Orders"),
              if (state is RatingGetUserOrdersLoading)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                        alignment: Alignment.center,
                        heightFactor: MediaQuery.sizeOf(context).height * 0.02,
                        child: const CircularProgressIndicator(
                          color: AppColorsLight.primaryColor,
                        )),
                  ],
                ),
              if (state is RatingGetUserOrdersSuccess ||
                  state is RatingPostUserRatingsSuccess)
                if (cubit.orders.isEmpty)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/no_orders.png",
                        ),
                        Text(
                          "You have no orders yet.",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                        SizedBox(height: 80.h),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: cubit.orders.length,
                      itemBuilder: (context, index) => UserOrdersListViewItem(
                        orderModel: cubit.orders[index],
                      ),
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: 8),
                    ),
                  ),
            ],
          ),
        ),
      );
    });
  }
}
