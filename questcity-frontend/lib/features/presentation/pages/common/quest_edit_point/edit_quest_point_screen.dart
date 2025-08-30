import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_search_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit_point/components/edit_quest_point_files_chip_by_artefact_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit_point/components/edit_quest_point_files_chip_by_download_files_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit_point/components/edit_quest_point_files_chip_by_ghost_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit_point/components/edit_quest_point_files_chip_by_photo_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit_point/components/edit_quest_point_place_chip_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit_point/components/edit_quest_point_type_or_tools_chip_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit_point/cubit/edit_quest_point_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit_point/edit_quest_point_screen_controller.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/edit_quest_screen_data.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class EditQuestPointScreen extends StatelessWidget {
  const EditQuestPointScreen({
    super.key,
    required this.pointIndex,
    this.editData,
  });

  final int pointIndex;
  final PointEditData? editData;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    String questTitle = args?['title'] ?? '';

    return BlocProvider(
      create: (context) => EditQuestPointScreenCubit(
        pointIndex: pointIndex,
        editData: editData,
      ),
      child: BlocBuilder<EditQuestPointScreenCubit, EditQuestPointScreenState>(
        builder: (context, state) {
          EditQuestPointScreenCubit cubit =
              context.read<EditQuestPointScreenCubit>();
          PageController pageController = PageController(
              initialPage: cubit.chipNames
                  .indexWhere((name) => name == cubit.typeChip.name),
              viewportFraction: 1.05);
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(Paths.backgroundGradient1Path),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high),
              ),
              child: Padding(
                padding: getMarginOrPadding(
                    top: MediaQuery.of(context).padding.top + 20),
                child: Column(
                  children: [
                    _buildAppBar(context, questTitle, cubit),
                    SizedBox(height: 24.h),
                    Expanded(
                      child: Stack(
                        children: [
                          ListView(
                            padding: getMarginOrPadding(
                                top: 27,
                                bottom: cubit.typeChip != TypeChip.Files
                                    ? 38
                                    : 118),
                            children: [
                              _buildMapSection(cubit),
                              SizedBox(height: 20.h),
                              _buildChipSelector(cubit, pageController),
                              SizedBox(height: 20.h),
                              _buildPageView(cubit, pageController),
                            ],
                          ),
                          Visibility(
                            visible: cubit.typeChip == TypeChip.Files &&
                                (cubit.typeArtefact == TypeArtefact.PHOTO
                                    ? cubit.photoImage == null
                                    : cubit.typeArtefact !=
                                        TypeArtefact.ARTIFACTS),
                            child: Positioned(
                              bottom: 44.h,
                              left: 16.w,
                              right: 16.w,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width - 32.w,
                                child: CustomButton(
                                    title: LocaleKeys.kTextAddFile.tr(),
                                    onTap: () async {
                                      if (cubit.typeArtefact ==
                                          TypeArtefact.GHOST) {
                                        cubit.onChangeGhostFiles(true);
                                      } else if (cubit.typeArtefact ==
                                          TypeArtefact.PHOTO) {
                                        XFile? image =
                                            await EditQuestPointScreenController
                                                .pickImage();
                                        if (image != null) {
                                          cubit.onChangePhotoFile(image);
                                        }
                                      } else if (cubit.typeArtefact ==
                                          TypeArtefact.DOWNLOAD_FILE) {
                                        cubit.onChangeDownloadFile(true);
                                      }
                                    },
                                    iconLeft: Icon(Icons.add_rounded,
                                        size: 25.w,
                                        color: UiConstants.whiteColor),
                                    buttonColor: UiConstants.greenColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Method to build the custom app bar
  Widget _buildAppBar(BuildContext context, String questTitle,
      EditQuestPointScreenCubit cubit) {
    return Padding(
      padding: getMarginOrPadding(right: 16, left: 16),
      child: CustomAppBar(
        onTapBack: () {
          // Сохраняем данные точки перед возвратом
          final pointData = cubit.savePointData();
          Navigator.pop(context, pointData);
        },
        title: questTitle,
        action: GestureDetector(
          onTap: () {
            // Сохраняем данные точки при нажатии на галочку
            final pointData = cubit.savePointData();
            Navigator.pop(context, pointData);
          },
          child: SvgPicture.asset(Paths.checkInCircleIcon2Path,
              width: 52.w, height: 52.w),
        ),
      ),
    );
  }

  // Method to build the map section
  Widget _buildMapSection(EditQuestPointScreenCubit cubit) {
    return Container(
      padding: getMarginOrPadding(right: 16, left: 16),
      height: 328.h,
      child: Stack(
        children: [
          _buildMapBackground(),
          if (cubit.typeChip == TypeChip.Place)
            Positioned(
              top: 11.w,
              left: 11.w,
              right: 11.w,
              child: CustomSearchView(
                controller: cubit.searchController,
                options: const [
                  'Los Angeles',
                  'Los Angeles2',
                  'Los Angeles21',
                  'Los Angeles31',
                  'Los Angeles41',
                  'San Francisco',
                  'New York',
                  'Chicago'
                ],
                focusNode: cubit.searchFocusNode,
                onTapOption: cubit.onChangeCoordinateField,
                onKeyboardChangedVisible: (p0) =>
                    p0 == false ? cubit.searchFocusNode.unfocus() : null,
              ),
            ),
        ],
      ),
    );
  }

  // Method to build the map background
  Widget _buildMapBackground() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        image: const DecorationImage(
          image: AssetImage(Paths.mapPath),
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }

  // Method to build the chip selector
  Widget _buildChipSelector(
      EditQuestPointScreenCubit cubit, PageController pageController) {
    return Padding(
      padding: getMarginOrPadding(right: 16, left: 16),
      child: Wrap(
        runSpacing: 10.w,
        spacing: 10.w,
        children: List.generate(
          cubit.chipNames.length,
          (index) => _buildChip(cubit, index, pageController),
        ),
      ),
    );
  }

  // Method to build individual chip
  Widget _buildChip(EditQuestPointScreenCubit cubit, int index,
      PageController pageController) {
    return GestureDetector(
      onTap: () {
        pageController.animateToPage(index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn);
      },
      child: Container(
        padding: getMarginOrPadding(left: 20, right: 20, bottom: 10, top: 10),
        decoration: BoxDecoration(
          color: cubit.chipNames
                      .indexWhere((name) => name == cubit.typeChip.name) ==
                  index
              ? UiConstants.lightOrangeColor
              : UiConstants.purpleColor,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Text(
          cubit.chipNames[index],
          style: UiConstants.rememberTheUser
              .copyWith(color: UiConstants.whiteColor),
        ),
      ),
    );
  }

  // Method to build the page view
  Widget _buildPageView(
      EditQuestPointScreenCubit cubit, PageController pageController) {
    return ExpandablePageView.builder(
      controller: pageController,
      itemCount: cubit.chipNames.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: getMarginOrPadding(left: 16, right: 16),
          child: FractionallySizedBox(
            widthFactor: 1 / pageController.viewportFraction,
            child: _buildPageContent(cubit, index),
          ),
        );
      },
      onPageChanged: (value) async {
        await cubit.onTapChip(value);
      },
    );
  }

  // Method to build content for each page
  Widget _buildPageContent(EditQuestPointScreenCubit cubit, int index) {
    TypeChip typeChip = TypeChip.values.firstWhere(
        (value) => value.name == cubit.chipNames[index],
        orElse: () => TypeChip.Type);
    if ([TypeChip.Type, TypeChip.Tools].contains(typeChip)) {
      var title = typeChip == TypeChip.Type
          ? LocaleKeys.kTextActivityType.tr()
          : LocaleKeys.kTextToolType.tr();
      var items = typeChip == TypeChip.Type
          ? cubit.typeData[0].items
          : cubit.toolsData[0].items;
      var indexes = typeChip == TypeChip.Type
          ? cubit.selectedTypeIndexes
          : cubit.selectedToolsIndexes;
      return EditQuestPointTypeOrToolsChipBody(
        title: title,
        items: items,
        selectedIndexes: indexes,
        onTap: (preferencesIndex, preferencesItemIndex,
                {bool preferencesItemHasSubitems = false,
                preferencesSubItemIndex}) =>
            cubit.onChangePreferences(
                indexes, preferencesIndex, preferencesItemIndex,
                preferencesItemHasSubitems: preferencesItemHasSubitems,
                preferencesSubItemIndex: preferencesSubItemIndex),
      );
    } else if (typeChip == TypeChip.Place) {
      return EditQuestPointPlaceChipBody(
        coordinate1Controller: cubit.coordinate1Controller,
        coordinate2Controller: cubit.coordinate2Controller,
        onTapCoordinateField: cubit.onTapCoordinateField,
        radiusOfRandomOccurrenceIndex: cubit.radiusOrRandomOccurrenceValue,
        onChangeRadiusOfRandomOccurrenceValue:
            cubit.onChangeRadiusOrRandomOccurrenceValue,
      );
    } else if (typeChip == TypeChip.Files) {
      return cubit.typeArtefact == TypeArtefact.GHOST
          ? EditQuestPointFilesChipByGhostBody(
              onDelete: () => cubit.onChangeGhostFiles(false),
              countFiles: cubit.ghostFiles)
          : cubit.typeArtefact == TypeArtefact.PHOTO
              ? EditQuestPointFilesChipByPhotoBody(photo: cubit.photoImage)
              : cubit.typeArtefact == TypeArtefact.DOWNLOAD_FILE
                  ? EditQuestPointFilesChipByDownloadFilesBody(
                      onDelete: () => cubit.onChangeDownloadFile(false),
                      countFiles: cubit.downloadFilesCount)
                  : EditQuestPointFilesChipByArtefactBody(
                      onTap: (preferencesIndex, preferencesItemIndex,
                              {bool preferencesItemHasSubitems = false,
                              preferencesSubItemIndex}) =>
                          cubit.onChangePreferences(cubit.selectedFilesIndexes,
                              preferencesIndex, preferencesItemIndex,
                              preferencesItemHasSubitems:
                                  preferencesItemHasSubitems,
                              preferencesSubItemIndex: preferencesSubItemIndex),
                      items: cubit.filesData.isNotEmpty
                          ? cubit.filesData.first.items
                          : [],
                      selectedIndexes: cubit.selectedFilesIndexes);
    }
    return Center(
      child: Container(height: 50, width: 50, color: Colors.red),
    );
  }
}
