import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_cart_app/features/home/data/models/cart_product_model/cart_product_model.dart';

class CartListViewItem extends StatelessWidget {
  const CartListViewItem({
    super.key,
    required this.cartProductModel,
  });
  final CartProductModel cartProductModel;
  @override
  Widget build(BuildContext context) {
    final String total =
        (cartProductModel.productID!.price! * cartProductModel.quantity!)
            .toStringAsFixed(2);
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.2,
      child: Container(
        margin: const EdgeInsets.only(bottom: 0),
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 0.95,
                child: CachedNetworkImage(
                  imageUrl: cartProductModel.productID!.image ?? "",
                  errorWidget: (context, url, error) => SvgPicture.asset(
                    "assets/images/ImagePlaceholder.svg",
                    width: MediaQuery.sizeOf(context).width * 0.22,
                    fit: BoxFit.scaleDown,
                  ),
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            SizedBox(
              width: 18.w,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartProductModel.productID!.title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "${cartProductModel.productID!.price} L.E",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontFamily: "Carmen",
                        color: Colors.grey,
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text(
                        "Quantity",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontFamily: "Carmen", fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Spacer(),
                      Text(
                        "${cartProductModel.quantity}",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontFamily: "Carmen",
                            color: Colors.grey,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        "Total",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontFamily: "Carmen",
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        "$total L.E",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontFamily: "Carmen",
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
