import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_cart_app/core/services/helper_functions.dart';
import 'package:smart_cart_app/features/rating/presentation/manager/rating_cubit.dart';
import 'package:smart_cart_app/features/rating/presentation/views/widgets/rate_product_list_view_item.dart';

import '../../../../home/presentation/views/widgets/custom_home_app_bar.dart';

class RateProductsViewBody extends StatelessWidget {
  const RateProductsViewBody({
    super.key,
  });

  // final OrderModel orderModel;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RatingCubit, RatingState>(listener: (context, state) {
      if (state is RatingPostUserRatingsSuccess) {
        showCustomSnackBar(
          context: context,
          message: "Ratings Submitted Successfully!",
          vPadding: 32,
        );
        GoRouter.of(context).pop();
      }
    }, builder: (context, state) {
      var cubit = RatingCubit.get(context);
      cubit.initRatingList(cubit.currentOrder.products!);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomHomeAppBar(
                title: "Rate Products",
              ),
              ListView.separated(
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: RateProductListViewItem(
                    products: cubit.currentOrder.products![index],
                  ),
                ),
                shrinkWrap: true,
                itemCount: cubit.currentOrder.products!.length,
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    cubit.postUserRatings(
                        ratings: cubit.ratingList,
                        orderID: cubit.currentOrder.orderId!);
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
                  child: state is RatingPostUserRatingsLoading
                      ? const SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Submit Ratings",
                          style:
                              Theme.of(context).textTheme.titleSmall!.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                        ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
