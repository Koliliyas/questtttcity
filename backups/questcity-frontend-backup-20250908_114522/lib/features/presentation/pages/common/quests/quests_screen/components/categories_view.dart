import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/domain/entities/category_entity.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/components/category_item.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class CategoriesView extends StatelessWidget {
  final void Function(int categoryIndex) onTap;
  const CategoriesView(
      {super.key, required this.categoriesList, required this.onTap});

  final List<CategoryEntity> categoriesList;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        HomeScreenCubit homeCubit = context.read<HomeScreenCubit>();

        // Р—Р°С‰РёС‚Р° РѕС‚ РїСѓСЃС‚РѕРіРѕ СЃРїРёСЃРєР° РєР°С‚РµРіРѕСЂРёР№
        if (categoriesList.isEmpty) {
          print('рџ”Ќ DEBUG: Categories list is empty');
          return SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: getMarginOrPadding(left: 16, right: 16),
              child: Text(
                LocaleKeys.kTextCategories.tr(),
                style: UiConstants.textStyle3
                    .copyWith(color: UiConstants.whiteColor),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 78.w,
              child: ListView.separated(
                  padding: getMarginOrPadding(left: 16, right: 16),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    // Р‘РµР·РѕРїР°СЃРЅС‹Р№ РґРѕСЃС‚СѓРї Рє РєР°С‚РµРіРѕСЂРёСЏРј СЃ РїСЂРѕРІРµСЂРєРѕР№ РіСЂР°РЅРёС†
                    final adjustedIndex =
                        index - (homeCubit.role == Role.ADMIN ? 1 : 0);

                    // РџСЂРѕРІРµСЂСЏРµРј, С‡С‚Рѕ РёРЅРґРµРєСЃ РЅР°С…РѕРґРёС‚СЃСЏ РІ РґРѕРїСѓСЃС‚РёРјС‹С… РіСЂР°РЅРёС†Р°С…
                    if (adjustedIndex < 0 ||
                        adjustedIndex >= categoriesList.length) {
                      print(
                          'рџ”Ќ DEBUG: Invalid category index: $adjustedIndex, categories count: ${categoriesList.length}');
                      return SizedBox.shrink(); // Р’РѕР·РІСЂР°С‰Р°РµРј РїСѓСЃС‚РѕР№ РІРёРґ
                    }

                    return CategoryItem(
                      onTap: onTap,
                      category: categoriesList[adjustedIndex],
                    );
                  },
                  separatorBuilder: (context, index) => SizedBox(width: 12.w),
                  // Р‘РµР·РѕРїР°СЃРЅРѕРµ РІС‹С‡РёСЃР»РµРЅРёРµ itemCount
                  itemCount: categoriesList.isEmpty
                      ? 0
                      : categoriesList.length +
                          (homeCubit.role == Role.ADMIN ? 1 : 0)),
            ),
          ],
        );
      },
    );
  }
}

