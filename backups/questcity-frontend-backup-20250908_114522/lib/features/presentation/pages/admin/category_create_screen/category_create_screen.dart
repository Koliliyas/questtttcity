import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/features/domain/entities/category_entity.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/category_create_screen/components/category_quests_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/category_create_screen/cubit/category_create_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/features/presentation/widgets/quest_card_edit.dart';
import 'package:los_angeles_quest/locator_service.dart';

class CategoryCreateScreen extends StatelessWidget {
  const CategoryCreateScreen({super.key, this.category});

  final CategoryEntity? category;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoryCreateScreenCubit(
          category: category,
          createCategoryUC: sl(),
          updateCategoryUC: sl(),
          uploadFileUC: sl()),
      child: BlocBuilder<CategoryCreateScreenCubit, CategoryCreateScreenState>(
        builder: (context, state) {
          CategoryCreateScreenCubit cubit =
              context.read<CategoryCreateScreenCubit>();

          CategoryCreateScreenInitial loadedState =
              state as CategoryCreateScreenInitial;

          return Scaffold(
            body: Form(
              key: cubit.formKey,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(Paths.backgroundGradient1Path),
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high),
                ),
                child: Padding(
                  padding: getMarginOrPadding(
                      top: MediaQuery.of(context).padding.top + 20,
                      right: 16,
                      left: 16),
                  child: Column(
                    children: [
                      CustomAppBar(
                        onTapBack: () => Navigator.pop(context),
                        title: 'New category',
                        action: GestureDetector(
                          onTap: () => category != null
                              ? cubit.updateCategory(context)
                              : cubit.createCategory(context),
                          child: SvgPicture.asset(Paths.checkInCircleIcon2Path,
                              width: 52.w, height: 52.w),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Expanded(
                        child: ListView(
                          padding: getMarginOrPadding(top: 24, bottom: 24),
                          children: [
                            QuestCardEdit(
                                image: loadedState.image ?? category?.photoPath,
                                onChangeImage: cubit.changeImage),
                            SizedBox(height: 12.h),
                            CustomTextField(
                                hintText: LocaleKeys.kTextNameOfCategory.tr(),
                                controller: cubit.nameCategoryController,
                                fillColor: UiConstants.whiteColor,
                                textStyle: UiConstants.textStyle12
                                    .copyWith(color: UiConstants.blackColor),
                                textColor: UiConstants.blackColor,
                                isExpanded: true,
                                validator: (value) => Utils.validate(value),
                                isShowError: true,
                                errorText: 'The field must not be empty'),
                            SizedBox(height: 24.h),
                            CategoryQuestsView(
                                selectedIndexes: loadedState.selectedQuestIndexes,
                                onTap: cubit.onTapQuest)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

