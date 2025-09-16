import 'package:easy_localization/easy_localization.dart';
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
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/components/merch_preferences_body.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_loading_indicator.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_error_widget.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit_point/edit_quest_point_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/components/credits_preferences_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/components/main_preferences_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/components/mentor_preferences_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/components/mentor_preferences_body_with_switch.dart';
import 'package:los_angeles_quest/features/presentation/widgets/quest_card_edit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/components/quest_edit_dropdown_item.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/components/quest_edit_point_item.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/cubit/edit_quest_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/locator_service.dart';

class EditQuestScreen extends StatelessWidget {
  const EditQuestScreen({
    super.key,
    this.isCreateQuest = false,
    this.questId,
    this.onQuestCreated,
  });

  final bool isCreateQuest;
  final int? questId;
  final VoidCallback? onQuestCreated;

  @override
  Widget build(BuildContext context) {
    print(
        'рџ”Ќ DEBUG: EditQuestScreen.build() - РќР°С‡РёРЅР°РµРј РїРѕСЃС‚СЂРѕРµРЅРёРµ UI');

    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        HomeScreenCubit homeCubit = context.read<HomeScreenCubit>();
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(Paths.backgroundGradient1Path),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high),
            ),
            child: BlocProvider(
              create: (context) => EditQuestScreenCubit(
                  questId: questId,
                  getLevelsUC: sl(),
                  getPlacesUC: sl(),
                  getPricesUC: sl(),
                  getMilesUC: sl(),
                  getVehiclesUC: sl(),
                  createQuestUC: sl(),
                  updateQuestUC: sl(),
                  getQuestUC: sl(),
                  onQuestCreated: onQuestCreated),
              child: BlocBuilder<EditQuestScreenCubit, EditQuestScreenState>(
                builder: (context, state) {
                  print(
                      'рџ”Ќ DEBUG: EditQuestScreen.build() - РЎРѕСЃС‚РѕСЏРЅРёРµ EditQuestScreenCubit: ${state.runtimeType}');

                  if (state is EditQuestScreenLoading) {
                    print(
                        'рџ”Ќ DEBUG: EditQuestScreen.build() - РџРѕРєР°Р·С‹РІР°РµРј Р·Р°РіСЂСѓР·РєСѓ');
                    return const CustomLoadingIndicator();
                  } else if (state is EditQuestScreenError) {
                    print(
                        '🔍 DEBUG: EditQuestScreen.build() - Показываем ошибку: ${state.message}');
                    return CustomTextErrorWidget(textError: state.message);
                  } else if (state is EditQuestScreenSuccess) {
                    print(
                        '✅ DEBUG: EditQuestScreen.build() - Показываем успех: ${state.message}');
                    return _buildSuccessScreen(context, state.message);
                  }

                  EditQuestScreenCubit cubit =
                      context.read<EditQuestScreenCubit>();
                  EditQuestScreenLoaded loadedState =
                      state as EditQuestScreenLoaded;

                  print(
                      'рџ”Ќ DEBUG: EditQuestScreen.build() - РџРѕРєР°Р·С‹РІР°РµРј Р·Р°РіСЂСѓР¶РµРЅРЅС‹Р№ СЌРєСЂР°РЅ');
                  print('  - pointsData: ${loadedState.pointsData.length}');
                  print(
                      '  - selectedIndexes: ${loadedState.selectedIndexes.length}');
                  print('  - merchImages: ${loadedState.merchImages.length}');
                  print('  - hasMentor: ${loadedState.hasMentor}');
                  print(
                      '  - hasMentor type: ${loadedState.hasMentor.runtimeType}');

                  // РџСЂРѕРІРµСЂСЏРµРј С‚РѕР»СЊРєРѕ РєСЂРёС‚РёС‡РµСЃРєРё РІР°Р¶РЅС‹Рµ РїРѕР»СЏ
                  if (loadedState.pointsData.isEmpty) {
                    print(
                        'рџ”Ќ DEBUG: EditQuestScreen.build() - pointsData РїСѓСЃС‚РѕР№, РїРѕРєР°Р·С‹РІР°РµРј Р·Р°РіСЂСѓР·РєСѓ');
                    return const CustomLoadingIndicator();
                  }

                  print(
                      'рџ”Ќ DEBUG: EditQuestScreen.build() - Р РµРЅРґРµСЂРёРј РѕСЃРЅРѕРІРЅРѕР№ UI');
                  return _buildMainContent(
                      context, loadedState, cubit, homeCubit);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(
      BuildContext context,
      EditQuestScreenLoaded loadedState,
      EditQuestScreenCubit cubit,
      HomeScreenCubit homeCubit) {
    return Padding(
      padding: getMarginOrPadding(
          top: MediaQuery.of(context).padding.top + 20, right: 16, left: 16),
      child: Column(
        children: [
          CustomAppBar(
            onTapBack: () => Navigator.pop(context),
            title: isCreateQuest
                ? LocaleKeys.kTextNewQuest.tr()
                : 'Р РµРґР°РєС‚РёСЂРѕРІР°РЅРёРµ РєРІРµСЃС‚Р°',
            action: GestureDetector(
              onTap: loadedState.isFormValid
                  ? () {
                      if (isCreateQuest) {
                        cubit.createQuest();
                      } else {
                        cubit.updateQuest();
                      }
                    }
                  : null,
              child: Opacity(
                opacity: loadedState.isFormValid ? 1.0 : 0.5,
                child: SvgPicture.asset(Paths.checkInCircleIcon2Path,
                    width: 52.w, height: 52.w),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: ListView(
              padding: getMarginOrPadding(top: 24, bottom: 24),
              children: [
                const QuestCardEdit(),
                SizedBox(height: 12.h),
                CustomTextField(
                  hintText: LocaleKeys.kTextQuestName.tr(),
                  controller: cubit.nameCategoryController,
                  fillColor: UiConstants.whiteColor,
                  textStyle: UiConstants.textStyle12
                      .copyWith(color: UiConstants.blackColor),
                  textColor: UiConstants.blackColor,
                  isExpanded: true,
                  validator: (value) => Utils.validate(value),
                ),
                // РћС‚РѕР±СЂР°Р¶РµРЅРёРµ РѕС€РёР±РєРё РІР°Р»РёРґР°С†РёРё РґР»СЏ РЅР°Р·РІР°РЅРёСЏ
                if (loadedState.validationErrors['name'] != null)
                  Padding(
                    padding: getMarginOrPadding(top: 4),
                    child: Text(
                      loadedState.validationErrors['name']!,
                      style: UiConstants.textStyle10.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                SizedBox(height: 12.h),
                CustomTextField(
                  hintText: LocaleKeys.kTextQuestDescription.tr(),
                  controller: cubit.descriptionQuestController,
                  fillColor: UiConstants.whiteColor,
                  textStyle: UiConstants.textStyle12
                      .copyWith(color: UiConstants.blackColor),
                  textColor: UiConstants.blackColor,
                  isExpanded: true,
                  validator: (value) => Utils.validate(value),
                ),
                // РћС‚РѕР±СЂР°Р¶РµРЅРёРµ РѕС€РёР±РєРё РІР°Р»РёРґР°С†РёРё РґР»СЏ РѕРїРёСЃР°РЅРёСЏ
                if (loadedState.validationErrors['description'] != null)
                  Padding(
                    padding: getMarginOrPadding(top: 4),
                    child: Text(
                      loadedState.validationErrors['description']!,
                      style: UiConstants.textStyle10.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                SizedBox(height: 24.h),
                Visibility(
                  visible: homeCubit.role == Role.ADMIN,
                  child: Padding(
                    padding: getMarginOrPadding(bottom: 12),
                    child: QuestEditDropdownItem(
                      title: LocaleKeys.kTextMerch.tr(),
                      body: MerchPreferencesBody(
                          merchDescriptionController:
                              cubit.merchDescriptionController,
                          merchPriceController: cubit.merchPriceController,
                          merchImages: loadedState.merchImages,
                          addedImage: cubit.addMerchImages),
                    ),
                  ),
                ),
                QuestEditDropdownItem(
                  title: LocaleKeys.kTextCredits.tr(),
                  body: CreditsPreferencesBody(
                      creditsAccrueController: cubit.creditsAccrueController,
                      creditsPaysController: cubit.creditsPaysController,
                      changeManualOrAutoRadio:
                          cubit.changeManualOrAutoCreditsRadio,
                      radioIndex: homeCubit.role == Role.ADMIN
                          ? loadedState.creditsRadioIndex
                          : null),
                ),
                SizedBox(height: 12.h),
                QuestEditDropdownItem(
                  title: LocaleKeys.kTextMainPreferences.tr(),
                  body: MainPreferencesBody(
                    preference: cubit.mainPreferencesData,
                    selectedPrefIndexes: loadedState.selectedIndexes,
                    onTap: cubit.onChangePreferences,
                  ),
                ),
                SizedBox(height: 12.h),
                QuestEditDropdownItem(
                    title: LocaleKeys.kTextMentorPreferences.tr(),
                    body: MentorPreferencesBodyWithSwitch(
                      hasMentor: loadedState.hasMentor,
                      onChanged: cubit.setHasMentor,
                    ),
                    isRequired: false),
                // Отладочная информация
                Builder(
                  builder: (context) {
                    print(
                        '🔍 DEBUG: edit_quest_screen.dart - MentorPreferences');
                    print(
                        '  - loadedState.hasMentor: ${loadedState.hasMentor}');
                    print(
                        '  - loadedState.hasMentor type: ${loadedState.hasMentor.runtimeType}');
                    return const SizedBox.shrink();
                  },
                ),
                SizedBox(height: 24.h),
                ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final pointData = loadedState.pointsData;
                      if (pointData == null || index >= pointData.length) {
                        return const SizedBox.shrink();
                      }

                      return QuestEditPointItem(
                        title: pointData[index].title,
                        onTap: () => Navigator.push(
                          context,
                          FadeInRoute(
                            EditQuestPointScreen(pointIndex: index),
                            Routes.editQuestPointScreen,
                            arguments: {'title': pointData[index].title},
                          ),
                        ),
                        isRequired: index == 0 ||
                            index ==
                                (pointData.isNotEmpty
                                    ? pointData.length - 1
                                    : 0),
                        isFilledData:
                            cubit.pointControllers[index].text.isNotEmpty,
                        controller: cubit.pointControllers[index],
                        onDeletePoint: () => cubit.onDeletePoint(index),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemCount: loadedState.pointsData.length),
                SizedBox(height: 24.h),
                CustomButton(
                    title: LocaleKeys.kTextAddHalfwayPoint.tr(),
                    onTap: cubit.onAddPoint,
                    iconLeft: Icon(Icons.add_rounded,
                        size: 25.w, color: UiConstants.whiteColor),
                    buttonColor: UiConstants.greenColor)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen(BuildContext context, String message) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(Paths.backgroundGradient1Path),
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 80.w,
                color: Colors.green,
              ),
              SizedBox(height: 24.h),
              Text(
                message,
                style: UiConstants.textStyle4.copyWith(
                  color: UiConstants.whiteColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              CustomButton(
                title: 'Вернуться к квестам',
                onTap: () => Navigator.pop(context),
                buttonColor: UiConstants.greenColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
