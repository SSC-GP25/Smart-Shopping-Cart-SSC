import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:smart_cart_app/features/category_selection/data/repos/category_repo.dart';
import 'package:smart_cart_app/features/category_selection/presentation/manager/category_states.dart';

class CategoryCubit extends Cubit<CategoryStates> {
  CategoryCubit(this.categoryRepo) : super(CategoryInitial());
  static CategoryCubit get(context) => BlocProvider.of(context);
  final CategoryRepo categoryRepo;
  List<MultiSelectCard> categories = [];

  Future<void> getCategories() async {
    emit(CategoryGetLoading());
    var result = await categoryRepo.getCategories();
    result.fold((failure) {
      categories.clear();
      emit(CategoryGetFailure(failure));
    }, (result) {
      categories = result.map((category) {
        return MultiSelectCard(
          value: category.title, // Use the category ID as the value
          label: category.title, // Use the category title as the label
        );
      }).toList();
      emit(CategoryGetSuccess(result));
    });
  }

  Future<void> postCategories(List<String> categories) async {
    emit(CategoryPostLoading());
    var result = await categoryRepo.postCategories(categories: categories);
    result.fold((failure) {
      emit(CategoryPostFailure(failure));
    }, (result) {
      emit(CategoryPostSuccess());
    });
  }
}
