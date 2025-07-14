part of 'recommendation_cubit.dart';

abstract class RecommendationState {}

class RecommendationInitial extends RecommendationState {}

class RecommendedProductsLoading extends RecommendationState {}

class RecommendedProductsFailure extends RecommendationState {
  String errMessage;

  RecommendedProductsFailure(this.errMessage);
}

class RecommendedProductsSuccess extends RecommendationState {
  List<RecommendedItems> recommendations;

  RecommendedProductsSuccess(this.recommendations);
}
