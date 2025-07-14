import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_cart_app/core/services/service_locator.dart';
import 'package:smart_cart_app/features/home/data/repos/home_repo_impl.dart';
import 'package:smart_cart_app/features/home/presentation/manager/recommendation_cubit/recommendation_cubit.dart';
import 'package:smart_cart_app/features/home/presentation/views/cart_view.dart';
import 'package:smart_cart_app/features/home/presentation/views/map_view.dart';
import 'package:smart_cart_app/features/home/presentation/views/offers_view.dart';
import 'package:smart_cart_app/features/home/presentation/views/profile_view.dart';

import '../../../../../core/routing/app_router.dart';
import 'layout_states.dart';

class LayoutCubit extends Cubit<LayoutStates> {
  LayoutCubit() : super(LayoutInitial()) {
    monitorConnectivity();
  }

  static LayoutCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  StreamSubscription? _subscription;
  String? lastRoute;
  List<BottomNavigationBarItem> bottomItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart),
      label: "Cart",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.redeem_rounded),
      label: "Offers",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.map),
      label: "Map",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: "Profile",
    ),
  ];
  List<Widget> screens = [
    const CartView(),
    BlocProvider(
        create: (context) => RecommendationCubit(getIt.get<HomeRepoImpl>()),
        child: const OffersView()),
    const MapView(),
    const ProfileView()
  ];

  void changeBottomNav(int index) {
    currentIndex = index;
    emit(LayoutChangeBottomNavState());
  }

  @override
  Future<void> close() {
    _subscription!.cancel();
    return super.close();
  }

  void monitorConnectivity() {
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      final context = AppRouter.navigatorKey.currentContext;
      if (context == null) return;
      if (result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile)) {
        if (GoRouter.of(context)
                .routerDelegate
                .currentConfiguration
                .lastOrNull!
                .matchedLocation ==
            AppRouter.noConnectionView) {
          GoRouter.of(context).pop();
        }

        emit(LayoutConnectedState());
      } else if (result.contains(ConnectivityResult.none)) {
        if (GoRouter.of(context)
                .routerDelegate
                .currentConfiguration
                .lastOrNull!
                .matchedLocation !=
            AppRouter.noConnectionView) {
          lastRoute = GoRouter.of(context)
              .routerDelegate
              .currentConfiguration
              .lastOrNull!
              .matchedLocation;
        }
        GoRouter.of(context).push(AppRouter.noConnectionView);
        emit(LayoutNotConnectedState());
      }
    });
  }
}
