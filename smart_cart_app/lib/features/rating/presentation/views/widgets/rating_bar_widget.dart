import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:smart_cart_app/features/rating/presentation/manager/rating_cubit.dart';

class RatingBarWidget extends StatelessWidget {
  const RatingBarWidget({
    super.key,
    required this.prodID,
  });
  final String prodID;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        RatingBar.builder(
          itemSize: 25,
          initialRating: 3,
          minRating: 1,
          direction: Axis.horizontal,
          glow: false,
          itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
          itemBuilder: (context, index) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            RatingCubit.get(context).updateRatingList(prodID, rating.toInt());
          },
        ),
      ],
    );
  }
}
