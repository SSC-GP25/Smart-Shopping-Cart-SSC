import 'package:flutter/material.dart';

class CustomHomeAppBar extends StatelessWidget {
  const CustomHomeAppBar({
    super.key,
    required this.title,
  });
  final String title;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .headlineMedium!
              .copyWith(fontFamily: "Carmen"),
        ),
        const SizedBox(
          height: 12,
        ),
        const Divider(
          thickness: 0.5,
          color: Colors.grey,
        ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }
}
