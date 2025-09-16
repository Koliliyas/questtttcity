import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quests_list_screen/cubit/quests_list_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quest_create_screen/quest_create_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quest_edit_screen/quest_edit_screen.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_loading_indicator.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_error_widget.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_search_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/components/filter_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/components/categories_view.dart';
import 'package:los_angeles_quest/features/domain/entities/category_entity.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class QuestsListScreen extends StatelessWidget {
  const QuestsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuestsListScreenCubit, QuestsListScreenState>(
      builder: (context, state) {
        QuestsListScreenCubit cubit = context.read<QuestsListScreenCubit>();

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(Paths.backgroundGradient1Path),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high),
            ),
            child: state is QuestsListScreenLoading
                ? const CustomLoadingIndicator()
                : state is QuestsListScreenError
                    ? CustomTextErrorWidget(textError: state.message)
                    : Stack(
                        children: [
                          ListView(
                            padding: getMarginOrPadding(
                                top: MediaQuery.of(context).padding.top + 24,
                                bottom: 156),
                            children: [
                              // Поиск и фильтры (как у пользователей)
                              Padding(
                                padding:
                                    getMarginOrPadding(left: 16, right: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: CustomSearchView(
                                        controller: cubit.searchController,
                                        suffixWidget: FilterView(
                                          onTap: () {},
                                          isVisible: true,
                                          countSelectedFilters: 0,
                                        ),
                                        onKeyboardChangedVisible:
                                            (isVisible) {},
                                        isExpanded: true,
                                        widthOverlay:
                                            MediaQuery.of(context).size.width -
                                                32.w,
                                      ),
                                    ),
                                    // Кнопка добавления квеста
                                    SizedBox(width: 10.w),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              QuestCreateScreen(
                                            onQuestCreated: () {
                                              // Обновляем список квестов после создания
                                              cubit.loadQuests();
                                            },
                                          ),
                                        ),
                                      ),
                                      child: Container(
                                        width: 36.w,
                                        height: 36.w,
                                        decoration: BoxDecoration(
                                          color: UiConstants.orangeColor
                                              .withValues(alpha: 0.9),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: UiConstants.orangeColor
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 8.r,
                                              offset: Offset(0, 2.h),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          color: UiConstants.whiteColor,
                                          size: 20.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24.h),
                              // Категории (как у пользователей)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CategoriesView(
                                    categoriesList: _getMockCategories(),
                                    onTap: (categoryIndex) {
                                      // Обработка нажатия на категорию
                                      print(
                                          'Выбрана категория с индексом: $categoryIndex');
                                    },
                                  ),
                                  SizedBox(height: 32.h),
                                ],
                              ),
                              // Список квестов
                              Padding(
                                padding:
                                    getMarginOrPadding(left: 16, right: 16),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: (state as QuestsListScreenLoaded)
                                      .quests
                                      .length,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(height: 14.h),
                                  itemBuilder: (context, index) {
                                    final quest =
                                        (state as QuestsListScreenLoaded)
                                            .quests[index];
                                    return _buildQuestCard(
                                        context, quest, cubit);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
          ),
        );
      },
    );
  }

  // Построение карточки квеста в стиле пользовательских квестов
  Widget _buildQuestCard(BuildContext context, Map<String, dynamic> quest,
      QuestsListScreenCubit cubit) {
    return Stack(
      children: [
        // Основная карточка с изображением (точно как у пользователей)
        GradientCard(
          onTap: () {
            // Можно добавить переход к детальному просмотру
          },
          height: 203.h,
          contentPadding: EdgeInsets.zero,
          body: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: SizedBox(
              child: Image.network(
                quest['image'] ??
                    'https://via.placeholder.com/400x200/6B46C1/FFFFFF?text=Quest+Image',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Если изображение не загружается, показываем простое изображение
                  return Image.asset(
                    'assets/images/quest_placeholder.jpg',
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Если и placeholder не загружается, показываем цветной фон
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        color: UiConstants.purpleColor,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
        // Название квеста поверх изображения (как у пользователей)
        Positioned(
          bottom: 20.h,
          left: 20.w,
          child: Text(
            quest['title'] ?? quest['name'] ?? 'Без названия',
            style: UiConstants.textStyle4.copyWith(
              color: UiConstants.whiteColor,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Кнопки действий для админа (единственное отличие от пользователей)
        Positioned(
          top: 14.h,
          right: 14.w,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Кнопка редактирования
              GestureDetector(
                onTap: () => cubit.navigateToEditQuest(context, quest['id']),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: UiConstants.orangeColor.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: UiConstants.orangeColor.withValues(alpha: 0.3),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit,
                    color: UiConstants.whiteColor,
                    size: 18.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Кнопка удаления
              GestureDetector(
                onTap: () => _showDeleteDialog(context, cubit, quest['id']),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: UiConstants.redColor.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: UiConstants.redColor.withValues(alpha: 0.3),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.delete,
                    color: UiConstants.whiteColor,
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Диалог подтверждения удаления
  void _showDeleteDialog(
      BuildContext context, QuestsListScreenCubit cubit, dynamic questId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: UiConstants.darkVioletColor,
          title: Text(
            LocaleKeys.kTextDeleteQuestConfirmation.tr(),
            style: UiConstants.textStyle16.copyWith(
              color: UiConstants.whiteColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            LocaleKeys.kTextDeleteQuestWarning.tr(),
            style: UiConstants.textStyle14.copyWith(
              color: UiConstants.whiteColor.withValues(alpha: 0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                LocaleKeys.kTextCancel.tr(),
                style: UiConstants.textStyle14.copyWith(
                  color: UiConstants.grayColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                cubit.deleteQuest(questId);
              },
              child: Text(
                LocaleKeys.kTextDelete.tr(),
                style: UiConstants.textStyle14.copyWith(
                  color: UiConstants.redColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Метод для получения тестовых категорий
  List<CategoryEntity> _getMockCategories() {
    return [
      CategoryEntity(
        id: 1,
        title: 'Городские квесты',
        photoPath: 'assets/icons/city.svg',
      ),
      CategoryEntity(
        id: 2,
        title: 'Исторические',
        photoPath: 'assets/icons/history.svg',
      ),
      CategoryEntity(
        id: 3,
        title: 'Приключения',
        photoPath: 'assets/icons/adventure.svg',
      ),
      CategoryEntity(
        id: 4,
        title: 'Детективы',
        photoPath: 'assets/icons/detective.svg',
      ),
    ];
  }
}
