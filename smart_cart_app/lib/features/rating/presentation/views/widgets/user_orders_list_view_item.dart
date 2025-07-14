import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_cart_app/core/routing/app_router.dart';
import 'package:smart_cart_app/features/rating/data/models/order_model/order_model.dart';
import 'package:smart_cart_app/features/rating/presentation/manager/rating_cubit.dart';

import 'user_order_image_item.dart';

class UserOrdersListViewItem extends StatelessWidget {
  const UserOrdersListViewItem({super.key, required this.orderModel});

  final OrderModel orderModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).push(AppRouter.rateProductsView);
        RatingCubit.get(context).setCurrentOrder(order: orderModel);
      },
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.22,
        child: Container(
          margin: const EdgeInsets.only(bottom: 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.13,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) => UserOrderImageItem(
                        imageUrl: orderModel.products?[index].image,
                      ),
                      itemCount: orderModel.products!.length > 1 ? 2 : 1,
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(width: 12),
                    ),
                  )
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Text(
                      "${orderModel.totalPrice} L.E",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(color: Colors.green),
                    ),
                    const Spacer(),
                    orderModel.products!.length > 1
                        ? Text("+${orderModel.products!.length - 2} more")
                        : Text("+${orderModel.products!.length - 1} more"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
