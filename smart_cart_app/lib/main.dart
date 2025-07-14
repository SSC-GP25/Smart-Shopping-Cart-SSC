import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:smart_cart_app/core/networking/api/api_consts.dart';
import 'package:smart_cart_app/core/services/cache_helper.dart';
import 'package:smart_cart_app/core/services/notification_service.dart';
import 'package:smart_cart_app/core/services/service_locator.dart';
import 'package:smart_cart_app/core/themes/light_theme/light_theme.dart';
import 'package:smart_cart_app/features/authentication/data/repos/auth_repo_impl.dart';
import 'package:smart_cart_app/features/authentication/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:smart_cart_app/features/checkout/data/repos/checkout_repo_impl.dart';
import 'package:smart_cart_app/features/checkout/presentation/manager/checkout_cubit.dart';
import 'package:smart_cart_app/features/home/data/repos/home_repo_impl.dart';
import 'package:smart_cart_app/features/home/presentation/manager/home_cubit/home_cubit.dart';
import 'package:smart_cart_app/features/home/presentation/manager/layout_cubit/layout_cubit.dart';
import 'package:smart_cart_app/features/home/presentation/manager/map_cubit/map_cubit.dart';
import 'package:smart_cart_app/features/rating/data/repo/rating_repo_impl.dart';
import 'package:smart_cart_app/features/rating/presentation/manager/rating_cubit.dart';

import 'core/routing/app_router.dart';
import 'core/services/bloc_observer.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = ApiConsts.stripePK;
  setupServiceLocator();
  Bloc.observer = MyBlocObserver();
  NotificationService().initialize();
  await CacheHelper.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => const SmartCart(),
    ),
  );
}

class SmartCart extends StatelessWidget {
  const SmartCart({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LayoutCubit()..monitorConnectivity()),
        BlocProvider(create: (context) => AuthCubit(getIt.get<AuthRepoImpl>())),
        BlocProvider(
            create: (context) =>
                HomeCubit(getIt.get<HomeRepoImpl>())..initialize()),
        BlocProvider(
            create: (context) =>
                MapCubit(getIt.get<HomeRepoImpl>())..initialize()),
        BlocProvider(
            create: (context) => CheckoutCubit(getIt.get<CheckoutRepoImpl>())),
        BlocProvider(
            create: (context) => RatingCubit(getIt.get<RatingRepoImpl>())),
      ],
      child: ScreenUtilInit(
        designSize: const Size(380, 700),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
            theme: getLightTheme(),
          );
        },
      ),
    );
  }
}
