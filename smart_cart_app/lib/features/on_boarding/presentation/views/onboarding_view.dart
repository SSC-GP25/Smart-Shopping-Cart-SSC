import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_cart_app/core/routing/app_router.dart';
import 'package:smart_cart_app/core/services/cache_helper.dart';
import 'package:smart_cart_app/core/themes/light_theme/app_colors_light.dart';
import 'package:smart_cart_app/features/on_boarding/models/onboarding_model.dart';
import 'package:smart_cart_app/features/on_boarding/presentation/views/widgets/onboarding_list_item.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  List<OnBoardingModel> list = [
    OnBoardingModel(
        image: "assets/images/on_boarding_1.png",
        title: "Scan Products Easily",
        subtitle:
            "Use the barcode scanner to scan barcodes and get product details instantly."),
    OnBoardingModel(
        image: "assets/images/on_boarding_2.png",
        title: "Personalized Recommendations",
        subtitle:
            "Get tailored product suggestions based on your shopping habits."),
    OnBoardingModel(
        image: "assets/images/on_boarding_3.png",
        title: "Online Payments",
        subtitle: "Make secure online payments with ease and convenience."),
  ];

  PageController pageController = PageController();
  bool isLast = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              submitOnBoarding(context);
            },
            child: Container(
              margin: const EdgeInsets.only(left: 16),
              child: Text(
                "Skip",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: const Color(0xff252525)),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              physics: const BouncingScrollPhysics(),
              controller: pageController,
              onPageChanged: (value) {
                if (value == list.length - 1) {
                  isLast = true;
                  setState(() {});
                } else {
                  isLast = false;
                  setState(() {});
                }
              },
              itemBuilder: (context, index) =>
                  OnBoardingItem(model: list[index]),
              itemCount: list.length,
            ),
          ),
          SizedBox(
            height: 8.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SmoothPageIndicator(
                controller: pageController,
                count: list.length,
                effect: const ExpandingDotsEffect(
                  dotColor: Colors.grey,
                  dotHeight: 9,
                  dotWidth: 9,
                  expansionFactor: 2.7,
                  activeDotColor: AppColorsLight.primaryColor,
                ),
              )
            ],
          ),
          SizedBox(
            height: 16.h,
          ),
          Container(
            width: double.infinity,
            // height: 50,
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
            child: ElevatedButton(
              onPressed: () {
                if (isLast) {
                  submitOnBoarding(context);
                }
                pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut);
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColorsLight.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLast
                  ? Text(
                      "Get Started",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.white),
                    )
                  : Text(
                      "Next",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void submitOnBoarding(BuildContext context) {
    CacheHelper.putBoolean(key: CacheHelperKeys.onBoarding, value: true);
    GoRouter.of(context).go(AppRouter.loginView);
  }
}
