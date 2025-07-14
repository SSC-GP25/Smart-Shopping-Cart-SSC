import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_cart_app/core/routing/app_router.dart';
import 'thank_you_check_mark.dart';
import 'thank_you_container.dart';
import 'thank_you_dashed_line.dart';
import 'thank_you_half_circle.dart';

class ThankYouViewBody extends StatelessWidget {
  const ThankYouViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 0, left: 24, right: 24, top: 72),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ThankYouContainer(),
              ThankYouDashedLine(),
              ThankYouHalfCircle(left: -20),
              ThankYouHalfCircle(right: -20),
              ThankYouCheckMark(),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: CustomButton(
                    title: "Go to Home Page",
                    route: AppRouter.homeView,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.title,
    required this.route,
  });
  final String title, route;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        GoRouter.of(context).push(route);
      },
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        backgroundColor: WidgetStateProperty.all(const Color(0xff5b9ee1)),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.w400,
              color: Colors.white,
              fontFamily: "Carmen",
            ),
      ),
    );
  }
}
