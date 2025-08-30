import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quest_edit_screen/cubit/quest_edit_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_loading_indicator.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/features/presentation/widgets/quest_preferences/quest_preference_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/components/quest_edit_dropdown_item.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/components/credits_preferences_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/components/merch_preferences_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/components/main_preferences_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/edit_quest_screen_data.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:los_angeles_quest/locator_service.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/components/quest_edit_point_item.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit_point/edit_quest_point_screen.dart';

class QuestEditScreen extends StatelessWidget {
  const QuestEditScreen({super.key, required this.questId});

  final int questId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuestEditScreenCubit(
        questId: questId,
        getLevelsUC: sl(),
        getPlacesUC: sl(),
        getPricesUC: sl(),
        getMilesUC: sl(),
        getVehiclesUC: sl(),
        updateQuestUC: sl(),
        getQuestUC: sl(),
      ),
      child: BlocBuilder<QuestEditScreenCubit, QuestEditScreenState>(
        builder: (context, state) {
          QuestEditScreenCubit cubit = context.read<QuestEditScreenCubit>();

          if (state is QuestEditScreenLoading) {
            return _buildLoadingScreen(context);
          } else if (state is QuestEditScreenError) {
            return _buildErrorScreen(context, cubit, state);
          } else if (state is QuestEditScreenLoaded) {
            return _buildScreen(context, cubit, state);
          }

          return _buildLoadingScreen(context);
        },
      ),
    );
  }

  Widget _buildScreen(
    BuildContext context,
    QuestEditScreenCubit cubit,
    QuestEditScreenLoaded state,
  ) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Paths.backgroundGradient1Path),
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: Padding(
          padding: getMarginOrPadding(
            top: MediaQuery.of(context).padding.top + 20,
            right: 16,
            left: 16,
          ),
          child: Form(
            key: cubit.formKey,
            child: Column(
              children: [
                CustomAppBar(
                  onTapBack: () => Navigator.pop(context),
                  title: LocaleKeys.kTextEditQuest.tr(),
                  action: GestureDetector(
                    onTap: () => cubit.updateQuest(context),
                    child: SvgPicture.asset(
                      Paths.checkInCircleIcon2Path,
                      width: 52.w,
                      height: 52.w,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Expanded(
                  child: ListView(
                    padding: getMarginOrPadding(top: 24, bottom: 24),
                    children: [
                      // Quest image
                      _buildImageSection(context, cubit, state),
                      SizedBox(height: 12.h),
                      // Quest name
                      CustomTextField(
                        hintText: LocaleKeys.kTextQuestName.tr(),
                        controller: cubit.nameController,
                        fillColor: UiConstants.whiteColor,
                        textStyle: UiConstants.textStyle12.copyWith(
                          color: UiConstants.blackColor,
                        ),
                        textColor: UiConstants.blackColor,
                        isExpanded: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return LocaleKeys.kTextQuestNameRequired.tr();
                          }
                          if (value.length > 128) {
                            return LocaleKeys.kTextQuestNameTooLong.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12.h),
                      // Quest description
                      CustomTextField(
                        hintText: LocaleKeys.kTextQuestDescription.tr(),
                        controller: cubit.descriptionController,
                        fillColor: UiConstants.whiteColor,
                        textStyle: UiConstants.textStyle12.copyWith(
                          color: UiConstants.blackColor,
                        ),
                        textColor: UiConstants.blackColor,
                        isExpanded: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return LocaleKeys.kTextQuestDescriptionRequired
                                .tr();
                          }
                          if (value.length < 10) {
                            return LocaleKeys.kTextQuestDescriptionRequired
                                .tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),
                      // Main preferences
                      QuestEditDropdownItem(
                        title: LocaleKeys.kTextMainPreferences.tr(),
                        body: MainPreferencesBody(
                          preference: _getMainPreferences(),
                          selectedPrefIndexes: _getSelectedPrefIndexes(state),
                          onTap: (preferencesIndex, preferencesItemIndex,
                              {int? preferencesSubItemIndex,
                              bool preferencesItemHasSubitems = false}) {
                            cubit.updateMainPreference(preferencesIndex,
                                preferencesItemIndex, preferencesSubItemIndex);
                          },
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Credits preferences
                      QuestEditDropdownItem(
                        title: LocaleKeys.kTextCreditsToAccrue.tr(),
                        body: CreditsPreferencesBody(
                          radioIndex: state.creditsRadioIndex,
                          creditsAccrueController:
                              cubit.creditsAccrueController,
                          creditsPaysController: cubit.creditsPaysController,
                          changeManualOrAutoRadio: (radioIndex) =>
                              cubit.setCreditsMode(radioIndex),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Merch preferences
                      QuestEditDropdownItem(
                        title: LocaleKeys.kTextMerch.tr(),
                        body: MerchPreferencesBody(
                          addedImage: (image) => cubit.addMerchImage(image),
                          merchImages: state.merchImages,
                          merchDescriptionController:
                              cubit.merchDescriptionController,
                          merchPriceController: cubit.merchPriceController,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Mentor preferences
                      QuestEditDropdownItem(
                        title: LocaleKeys.kTextMentorPreferences.tr(),
                        body: _buildMentorPreferences(context, cubit, state),
                      ),
                      SizedBox(height: 12.h),
                      // Quest points
                      _buildQuestPointsSection(context, cubit, state),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    QuestEditScreenCubit cubit,
    QuestEditScreenLoaded state,
  ) {
    return GradientCard(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.kTextQuestImage.tr(),
            style: UiConstants.textStyle16.copyWith(
              color: UiConstants.whiteColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => cubit.pickImage(),
            child: Container(
              width: double.infinity,
              height: 200.h,
              decoration: BoxDecoration(
                color: UiConstants.greyColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: UiConstants.greyColor,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: state.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.file(
                        state.image!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : state.imageUrl != null && state.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.network(
                            state.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder();
                            },
                          ),
                        )
                      : _buildImagePlaceholder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorPreferences(
    BuildContext context,
    QuestEditScreenCubit cubit,
    QuestEditScreenLoaded state,
  ) {
    return Column(
      children: [
        QuestPreferenceView(
          title: LocaleKeys.kTextMentorPreferences.tr(),
          preferenceIndex: 0,
          preferencesItems: [
            QuestPreferenceItem(LocaleKeys.kTextYes.tr()),
            QuestPreferenceItem(LocaleKeys.kTextNo.tr()),
          ],
          checkedItemIndex: state.hasMentor ? 0 : 1,
          checkedSubIndex: null,
          onTap: (preferencesIndex, preferencesItemIndex,
              {int? preferencesSubItemIndex,
              bool preferencesItemHasSubitems = false}) {
            cubit.setHasMentor(preferencesItemIndex == 0);
          },
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 48.w,
          color: UiConstants.greyColor,
        ),
        SizedBox(height: 8.h),
        Text(
          LocaleKeys.kTextClickToSelectImage.tr(),
          style: UiConstants.textStyle12.copyWith(
            color: UiConstants.greyColor,
          ),
        ),
      ],
    );
  }

  List<QuestPreference> _getMainPreferences() {
    return [
      QuestPreference(
        [
          QuestPreferenceItem(LocaleKeys.kTextEasy.tr()),
          QuestPreferenceItem(LocaleKeys.kTextMedium.tr()),
          QuestPreferenceItem(LocaleKeys.kTextHard.tr()),
        ],
        title: LocaleKeys.kTextDifficultyLevel.tr(),
      ),
      QuestPreference(
        [
          QuestPreferenceItem(LocaleKeys.kTextSolo.tr()),
          QuestPreferenceItem(LocaleKeys.kTextDuo.tr()),
          QuestPreferenceItem(LocaleKeys.kTextTeam.tr()),
          QuestPreferenceItem(LocaleKeys.kTextFamily.tr()),
        ],
        title: LocaleKeys.kTextGroupType.tr(),
      ),
      QuestPreference(
        [
          QuestPreferenceItem(LocaleKeys.kTextAdventure.tr()),
          QuestPreferenceItem(LocaleKeys.kTextDetective.tr()),
          QuestPreferenceItem(LocaleKeys.kTextHistory.tr()),
        ],
        title: LocaleKeys.kTextCategory.tr(),
      ),
      QuestPreference(
        [
          QuestPreferenceItem(LocaleKeys.kTextOnFoot.tr()),
          QuestPreferenceItem(LocaleKeys.kTextBicycle.tr()),
          QuestPreferenceItem(LocaleKeys.kTextCar.tr()),
        ],
        title: LocaleKeys.kTextVehicle.tr(),
      ),
    ];
  }

  List<List<int>> _getSelectedPrefIndexes(QuestEditScreenLoaded state) {
    return [
      [
        state.difficultyLevel == 'Easy'
            ? 0
            : state.difficultyLevel == 'Medium'
                ? 1
                : 2
      ],
      [
        state.groupType == 'Solo'
            ? 0
            : state.groupType == 'Duo'
                ? 1
                : state.groupType == 'Team'
                    ? 2
                    : 3
      ],
      [
        state.categoryId == 1
            ? 0
            : state.categoryId == 2
                ? 1
                : 2
      ],
      [
        state.vehicleId == 1
            ? 0
            : state.vehicleId == 2
                ? 1
                : 2
      ],
    ];
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Paths.backgroundGradient1Path),
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: const CustomLoadingIndicator(),
      ),
    );
  }

  Widget _buildErrorScreen(
    BuildContext context,
    QuestEditScreenCubit cubit,
    QuestEditScreenError state,
  ) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Paths.backgroundGradient1Path),
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.w,
                color: UiConstants.redColor,
              ),
              SizedBox(height: 16.h),
              Text(
                LocaleKeys.kTextQuestUpdateError.tr(),
                style: UiConstants.textStyle16.copyWith(
                  color: UiConstants.whiteColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                state.message,
                style: UiConstants.textStyle12.copyWith(
                  color: UiConstants.whiteColor.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              CustomButton(
                onTap: () => cubit.resetState(),
                title: LocaleKeys.kTextTryAgain.tr(),
                buttonColor: UiConstants.orangeColor,
                textColor: UiConstants.whiteColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestPointsSection(
    BuildContext context,
    QuestEditScreenCubit cubit,
    QuestEditScreenLoaded state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.kTextQuestPoints.tr(),
          style: UiConstants.textStyle16.copyWith(
            color: UiConstants.whiteColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final pointData = state.pointsData;
            if (index >= pointData.length) {
              return const SizedBox.shrink();
            }

            return QuestEditPointItem(
              title: pointData[index].title,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  FadeInRoute(
                    EditQuestPointScreen(
                      pointIndex: index,
                      editData: PointEditData(
                        pointIndex: index,
                        typeId: pointData[index].typeId,
                        toolId: pointData[index].toolId,
                      ),
                    ),
                    Routes.editQuestPointScreen,
                    arguments: {'title': pointData[index].title},
                  ),
                );

                // Обрабатываем результат
                if (result != null && result is PointEditData) {
                  // Добавляем небольшую задержку для стабилизации состояния
                  Future.delayed(Duration(milliseconds: 100), () {
                    // Проверяем состояние перед обновлением
                    if (cubit.state is QuestEditScreenLoaded) {
                      cubit.updatePointData(result);
                    } else {
                      print(
                          '❌ DEBUG: Неверное состояние для updatePointData: ${cubit.state.runtimeType}');
                    }
                  });
                }
              },
              isRequired: index == 0 ||
                  index == (pointData.isNotEmpty ? pointData.length - 1 : 0),
              isFilledData: cubit.pointControllers[index].text.isNotEmpty,
              controller: cubit.pointControllers[index],
              onDeletePoint: () => cubit.deletePoint(index),
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemCount: state.pointsData.length,
        ),
        SizedBox(height: 16.h),
        CustomButton(
          title: LocaleKeys.kTextAddHalfwayPoint.tr(),
          onTap: cubit.addPoint,
          iconLeft: Icon(
            Icons.add_rounded,
            size: 25.w,
            color: UiConstants.whiteColor,
          ),
          buttonColor: UiConstants.greenColor,
        ),
      ],
    );
  }
}
