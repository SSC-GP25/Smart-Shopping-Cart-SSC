import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_cart_app/core/networking/api/api_consts.dart';
import 'package:smart_cart_app/core/networking/api/api_service.dart';
import 'package:smart_cart_app/core/networking/api/dio_consumer.dart';
import 'package:smart_cart_app/core/services/stripe_service.dart';
import 'package:smart_cart_app/features/authentication/data/repos/auth_repo_impl.dart';
import 'package:smart_cart_app/features/category_selection/data/repos/category_repo_impl.dart';
import 'package:smart_cart_app/features/checkout/data/repos/checkout_repo_impl.dart';
import 'package:smart_cart_app/features/home/data/repos/home_repo_impl.dart';
import 'package:smart_cart_app/features/rating/data/repo/rating_repo_impl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerSingleton<ApiService>(ApiService(DioConsumer(dio: Dio())));

  getIt.registerSingleton<IO.Socket>(
    IO.io(
      ApiConsts.socketIOUrl,
      <String, dynamic>{
        'autoConnect': false,
        'transports': ['websocket'],
      },
    ),
  );

  getIt.registerSingleton<HomeRepoImpl>(
    HomeRepoImpl(
      getIt<ApiService>(),
      getIt<IO.Socket>(),
    ),
  );
  getIt.registerSingleton<AuthRepoImpl>(
    AuthRepoImpl(
      getIt<ApiService>(),
    ),
  );
  getIt.registerSingleton<CategoryRepoImpl>(
    CategoryRepoImpl(
      getIt<ApiService>(),
    ),
  );
  getIt.registerSingleton<RatingRepoImpl>(
    RatingRepoImpl(
      getIt<ApiService>(),
    ),
  );
  getIt.registerSingleton<StripeService>(StripeService(getIt<ApiService>()));
  getIt.registerSingleton<CheckoutRepoImpl>(
      CheckoutRepoImpl(getIt<StripeService>()));
}
