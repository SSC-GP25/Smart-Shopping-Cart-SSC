import 'package:smart_cart_app/features/category_selection/data/models/category_model/category.dart';

abstract class CategoryStates {}

class CategoryInitial extends CategoryStates {}

class CategoryGetLoading extends CategoryStates {}

class CategoryGetFailure extends CategoryStates {
  String errMessage;

  CategoryGetFailure(this.errMessage);
}

class CategoryGetSuccess extends CategoryStates {
  List<Categories> categories;

  CategoryGetSuccess(this.categories);
}

class CategoryPostLoading extends CategoryStates {}

class CategoryPostFailure extends CategoryStates {
  String errMessage;

  CategoryPostFailure(this.errMessage);
}

class CategoryPostSuccess extends CategoryStates {}
