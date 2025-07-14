import 'package:either_dart/either.dart';
import 'package:smart_cart_app/core/networking/api/api_consts.dart';
import 'package:smart_cart_app/core/networking/api/api_service.dart';
import 'package:smart_cart_app/core/networking/errors/exceptions.dart';
import 'package:smart_cart_app/features/category_selection/data/models/category_model/category.dart';
import 'package:smart_cart_app/features/category_selection/data/repos/category_repo.dart';

class CategoryRepoImpl extends CategoryRepo {
  final ApiService apiService;

  CategoryRepoImpl(this.apiService);

  @override
  Future<Either<String, List<Categories>>> getCategories() async {
    try {
      var response = await apiService.getCategories();
      List<Categories> categories = [];
      for (var i in response[ApiKeys.data]["categories"]) {
        categories.add(Categories.fromJson(i));
      }
      return Right(categories);
    } on ServerException catch (e) {
      return Left(e.errorModel.errMessage);
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> postCategories(
      {required List<String> categories}) async {
    try {
      var response = await apiService.postCategories(categories);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errMessage);
    }
  }
}
