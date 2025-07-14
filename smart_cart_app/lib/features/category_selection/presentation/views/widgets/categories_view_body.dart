import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_cart_app/core/routing/app_router.dart';
import 'package:smart_cart_app/core/services/helper_functions.dart';
import 'package:smart_cart_app/core/themes/light_theme/app_colors_light.dart';
import 'package:smart_cart_app/features/category_selection/presentation/manager/category_cubit.dart';
import 'package:smart_cart_app/features/category_selection/presentation/manager/category_states.dart';
import 'package:smart_cart_app/features/home/presentation/views/widgets/custom_home_app_bar.dart';

import 'custom_submit_button.dart';

class CategoriesViewBody extends StatelessWidget {
  CategoriesViewBody({super.key});

  final controller = MultiSelectController();
  final List<String> selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    var cubit = CategoryCubit.get(context);
    cubit.getCategories();
    return BlocConsumer<CategoryCubit, CategoryStates>(
      listener: (context, state) {
        if (state is CategoryGetFailure) {
          showCustomSnackBar(
              context: context, message: state.errMessage, vPadding: 64);
        } else if (state is CategoryPostFailure) {
          showCustomSnackBar(
              context: context, message: state.errMessage, vPadding: 32);
        } else if (state is CategoryPostSuccess) {
          showCustomSnackBar(
              context: context,
              message: "Categories Added Successfully",
              vPadding: 8);
          GoRouter.of(context).go(AppRouter.homeView);
        }
      },
      builder: (context, state) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: state is CategoryGetSuccess ||
                  state is CategoryPostLoading ||
                  state is CategoryPostSuccess
              ? CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(
                      child: CustomHomeAppBar(
                          title: "Choose Your Favorite Categories"),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: MultiSelectContainer(
                          controller: controller,
                          items: cubit.categories,
                          itemsPadding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          itemsDecoration: MultiSelectDecorations(
                            selectedDecoration: selectionDecoration(
                                AppColorsLight.primaryColor),
                            decoration:
                                selectionDecoration(Colors.grey.withAlpha(25)),
                          ),
                          textStyles: MultiSelectTextStyles(
                            selectedTextStyle: TextStyle(fontSize: 20.sp),
                            textStyle: TextStyle(fontSize: 18.sp),
                          ),
                          splashColor: AppColorsLight.primaryColor,
                          highlightColor: AppColorsLight.primaryColor,
                          onChange: (selectedItems, selectedItem) {
                            selectedCategories.clear();
                            selectedCategories.addAll(selectedItems.map(
                              (selectedItem) {
                                return selectedItem;
                              },
                            ));
                          },
                        ),
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: SizedBox(
                          width: double.infinity,
                          child: CustomSubmitButton(
                            title: "Submit",
                            onPressed: () {
                              cubit.postCategories(selectedCategories);
                            },
                            isLoading: state is CategoryPostLoading,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  ShapeDecoration selectionDecoration(Color color) {
    return ShapeDecoration(
      color: color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
    );
  }
}
