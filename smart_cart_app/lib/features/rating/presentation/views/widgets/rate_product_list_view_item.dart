import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_cart_app/features/rating/data/models/order_model/product.dart';
import 'rating_bar_widget.dart';

class RateProductListViewItem extends StatelessWidget {
  const RateProductListViewItem({
    super.key,
    required this.products,
  });
  final Product products;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.19,
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 0.95,
                  child: CachedNetworkImage(
                    imageUrl: products.image ?? "",
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
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      products.title!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontFamily: "Carmen", fontWeight: FontWeight.bold),
                    ),
                    RatingBarWidget(
                      prodID: products.productId!,
                    )
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
