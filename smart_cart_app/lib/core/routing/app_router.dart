import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_cart_app/core/services/cache_helper.dart';
import 'package:smart_cart_app/core/services/service_locator.dart';
import 'package:smart_cart_app/core/widgets/no_connection_view.dart';
import 'package:smart_cart_app/features/authentication/presentation/views/login_view.dart';
import 'package:smart_cart_app/features/authentication/presentation/views/password_recovery.dart';
import 'package:smart_cart_app/features/authentication/presentation/views/register_view.dart';
import 'package:smart_cart_app/features/authentication/presentation/views/verification_view.dart';
import 'package:smart_cart_app/features/category_selection/data/repos/category_repo_impl.dart';
import 'package:smart_cart_app/features/category_selection/presentation/manager/category_cubit.dart';
import 'package:smart_cart_app/features/category_selection/presentation/views/categories_view.dart';
import 'package:smart_cart_app/features/checkout/presentation/views/cash_payment_view.dart';
import 'package:smart_cart_app/features/checkout/presentation/views/checkout_cart_view.dart';
import 'package:smart_cart_app/features/checkout/presentation/views/thank_you_view.dart';
import 'package:smart_cart_app/features/home/presentation/manager/layout_cubit/layout_cubit.dart';
import 'package:smart_cart_app/features/home/presentation/manager/layout_cubit/layout_states.dart';
import 'package:smart_cart_app/features/home/presentation/views/home_view.dart';
import 'package:smart_cart_app/features/home/presentation/views/scan_qr_view.dart';
import 'package:smart_cart_app/features/on_boarding/presentation/views/onboarding_view.dart';
import 'package:smart_cart_app/features/rating/presentation/views/rate_products_view.dart';
import 'package:smart_cart_app/features/rating/presentation/views/user_orders_view.dart';

abstract class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static const homeView = "/homeView";
  static const onBoardingView = "/onBoardingView";
  static const loginView = "/loginView";
  static const registerView = "/registerView";
  static const verificationView = "/verificationView";
  static const passwordRecoveryView = "/passwordRecoveryView";
  static const scanQRCodeView = "/scanQRCodeView";
  static const checkoutCartView = "/checkoutCartView";
  static const cashPaymentView = "/cashPaymentView";
  static const paymentDetailsView = "/paymentDetailsView";
  static const thankYouView = "/thankYouView";
  static const rateProductsView = "/rateProductsView";
  static const categoriesView = "/categoriesView";
  static const userOrdersView = "/userOrdersView";
  static const noConnectionView = "/noConnectionView";

  static final router = GoRouter(
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(
        path: "/",
        builder: (context, state) => BlocBuilder<LayoutCubit, LayoutStates>(
          builder: (context, state) {
            if (CacheHelper.getBoolean(key: CacheHelperKeys.onBoarding) ==
                    null ||
                CacheHelper.getBoolean(key: CacheHelperKeys.onBoarding) ==
                    false) {
              return const OnBoardingView();
            }
            return const LoginView();
          },
        ),
      ),
      GoRoute(
        path: loginView,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LoginView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: onBoardingView,
        builder: (context, state) => const OnBoardingView(),
      ),
      GoRoute(
        path: noConnectionView,
        builder: (context, state) => const NoConnectionView(),
      ),
      GoRoute(
        path: registerView,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const RegisterView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: userOrdersView,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const UserOrdersView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: homeView,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const HomeView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0);
            const end = Offset.zero;
            const curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: verificationView,
        builder: (context, state) => const VerificationView(),
      ),
      GoRoute(
        path: passwordRecoveryView,
        builder: (context, state) => PasswordRecoveryView(),
        pageBuilder: (context, state) => CustomTransitionPage(
          child: PasswordRecoveryView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: scanQRCodeView,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: BlocProvider(
            create: (context) => CategoryCubit(getIt.get<CategoryRepoImpl>()),
            child: ScanQrView(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            );
            final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            );
            return ScaleTransition(
              scale: scaleAnimation,
              child: FadeTransition(opacity: fadeAnimation, child: child),
            );
          },
        ),
      ),
      GoRoute(
        path: checkoutCartView,
        builder: (context, state) => const CheckoutCartView(),
      ),
      GoRoute(
        path: cashPaymentView,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const CashPaymentView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ),
      // GoRoute(
      //   path: paymentDetailsView,
      //   builder: (context, state) => const PaymentDetailsView(),
      // ),
      GoRoute(
        path: thankYouView,
        builder: (context, state) => const ThankYouView(),
      ),
      GoRoute(
        path: rateProductsView,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const RateProductsView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: categoriesView,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: BlocProvider(
            create: (context) => CategoryCubit(getIt.get<CategoryRepoImpl>()),
            child: const CategoriesView(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            );
            final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            );
            return ScaleTransition(
              scale: scaleAnimation,
              child: FadeTransition(opacity: fadeAnimation, child: child),
            );
          },
        ),
      ),
    ],
  );
}
