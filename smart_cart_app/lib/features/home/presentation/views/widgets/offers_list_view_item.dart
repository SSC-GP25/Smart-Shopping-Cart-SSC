import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_cart_app/features/home/data/models/map_search_product_model/map_search_product_model.dart';
import 'package:smart_cart_app/features/home/data/models/recommendations_model/RecommendedItems.dart';
import 'package:smart_cart_app/features/home/presentation/manager/layout_cubit/layout_cubit.dart';
import 'package:smart_cart_app/features/home/presentation/manager/map_cubit/map_cubit.dart';

class OffersListViewItem extends StatelessWidget {
  const OffersListViewItem({
    super.key,
    required this.recommendedItem,
  });

  final RecommendedItems recommendedItem;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        LayoutCubit.get(context).changeBottomNav(2);
        context.read<MapCubit>().selectProduct(MapSearchProductModel(
              x: recommendedItem.x ?? 2,
              y: recommendedItem.y ?? 2,
            ));
        context.read<MapCubit>().findPath();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.white,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 2,
                child: CachedNetworkImage(
                  imageUrl: recommendedItem.image ?? "",
                  errorWidget: (context, url, error) => SvgPicture.asset(
                    "assets/images/ImagePlaceholder.svg",
                    width: 30.w,
                    // width: MediaQuery.sizeOf(context).width * 0.22,
                    fit: BoxFit.scaleDown,
                  ),
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            SizedBox(
              height: 8.w,
            ),
            Text(
              recommendedItem.title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              "${recommendedItem.price} L.E",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontFamily: "Carmen",
                  color: Colors.grey,
                  fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 8.h),
            RatingBar.builder(
              itemSize: 10,
              ignoreGestures: true,
              initialRating: recommendedItem.rating!,
              direction: Axis.horizontal,
              glow: false,
              itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
              itemBuilder: (context, index) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {},
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
