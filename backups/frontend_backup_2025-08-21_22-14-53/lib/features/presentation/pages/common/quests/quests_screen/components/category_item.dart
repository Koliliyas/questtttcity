import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/core/custom_cache_manager.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/domain/entities/category_entity.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/category_create_screen/category_create_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({super.key, required this.category, required this.onTap});
  final void Function(int categoryIndex)? onTap;

  final CategoryEntity category;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      hasBlur: true,
      width: null,
      height: 78.w,
      onTap: context.read<HomeScreenCubit>().role == Role.ADMIN
          ? () => Navigator.push(
                context,
                FadeInRoute(CategoryCreateScreen(category: category),
                    Routes.categoryCreateScreen),
              )
          : () {
              // Защита от null значений category.id
              if (category.id != null && category.id > 0) {
                onTap?.call(category.id);
              } else {
                print('🔍 DEBUG: Invalid category ID: ${category.id}');
              }
            },
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: UiConstants.black2Color.withValues(alpha: .25),
                        offset: Offset(0, 2.h),
                        blurRadius: 24.3.r),
                    BoxShadow(
                        color: UiConstants.shadow2Color.withValues(alpha: .25),
                        offset: Offset(0, 2.h),
                        blurRadius: 15.8.r),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: SizedBox(
                    width: 57.h,
                    height: 57.h,
                    child: CachedNetworkImage(
                      imageUrl: category.photoPath,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      cacheManager: CustomCacheManager(),
                      errorWidget: (context, url, error) => Icon(Icons.image,
                          size: 56.w, color: UiConstants.greyColor),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                category.title,
                style: UiConstants.textStyle4
                    .copyWith(color: UiConstants.whiteColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
