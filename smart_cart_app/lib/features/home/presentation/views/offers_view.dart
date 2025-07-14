import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_cart_app/core/themes/light_theme/app_colors_light.dart';
import 'package:smart_cart_app/features/authentication/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:smart_cart_app/features/home/presentation/views/widgets/offers_list_view_item.dart';

import '../../../../core/services/helper_functions.dart';
import '../manager/recommendation_cubit/recommendation_cubit.dart';
import 'widgets/custom_home_app_bar.dart';

class OffersView extends StatelessWidget {
  const OffersView({super.key});
  @override
  Widget build(BuildContext context) {
    var cubit = RecommendationCubit.get(context);
    if (cubit.recommendedProducts.isEmpty) {
      var userID = context.read<AuthCubit>().loginModel!.userReommID;
      cubit.getRecommendations(userID: userID!);
    }
    return BlocConsumer<RecommendationCubit, RecommendationState>(
      listener: (context, state) {
        if (state is RecommendedProductsFailure) {
          showCustomSnackBar(
              context: context, message: state.errMessage, vPadding: 16);
        }
      },
      builder: (context, state) {
        return SafeArea(
            child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomHomeAppBar(
                  title: "Recommendations for You",
                ),
                if (state is RecommendedProductsSuccess)
                  GridView.builder(
                    reverse: true,
                    itemBuilder: (context, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: OffersListViewItem(
                        recommendedItem: state.recommendations[index],
                      ),
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.recommendations.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                  )
                else
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          color: AppColorsLight.primaryColor,
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ));
      },
    );
  }
}
