import 'package:flutter/material.dart';

class TotalPriceWidget extends StatelessWidget {
  const TotalPriceWidget({
    super.key,
    required this.price,
  });
  final String price;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Total",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Spacer(),
        Text(
          price,
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(color: Colors.green),
        ),
      ],
    );
  }
}
