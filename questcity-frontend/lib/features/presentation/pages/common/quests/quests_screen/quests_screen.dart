import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/edit_quest_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/my_quests_screen/my_quests_screen.dart';
import 'package:los_angeles_quest/features/presentation/widgets/blur_rectangle_view.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/components/categories_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/components/favorite_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/components/filter_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/components/quests_small_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/components/quests_view.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_loading_indicator.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_search_view.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/cubit/quests_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_error_widget.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        HomeScreenCubit homeCubit = context.read<HomeScreenCubit>();
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
            child: BlocBuilder<QuestsScreenCubit, QuestsScreenState>(
              builder: (context, state) {
                QuestsScreenCubit cubit = context.read<QuestsScreenCubit>();

                if (state is QuestsScreenLoading) {
                  return const CustomLoadingIndicator();
                } else if (state is QuestsScreenError) {
                  return CustomTextErrorWidget(textError: state.message);
                }

                QuestsScreenLoaded loadedState = state as QuestsScreenLoaded;
                print('🔍 DEBUG: QuestsScreen.build() - State updated:');
                print(
                    '  - Quests count: ${loadedState.questsList.items.length}');
                print(
                    '  - Categories count: ${loadedState.categoriesList.length}');
                print('  - State type: ${state.runtimeType}');

                return Stack(
                  children: [
                    ListView(
                      padding: getMarginOrPadding(
                          top: MediaQuery.of(context).padding.top + 24,
                          bottom: 156),
                      children: [
                        Padding(
                          padding: getMarginOrPadding(left: 16, right: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomSearchView(
                                    controller: cubit.searchController,
                                    suffixWidget: FilterView(
                                        onTap: () {},
                                        isVisible:
                                            !loadedState.isSearchFieldEditing,
                                        countSelectedFilters:
                                            loadedState.countFilters),
                                    onKeyboardChangedVisible:
                                        cubit.onChangeSearchFieldEditingStatus,
                                    isExpanded: true,
                                    //options: const [
                                    //  'Los Angeles',
                                    //  'San Francisco',
                                    //  'New York',
                                    //  'Chicago'
                                    //],
                                    widthOverlay:
                                        MediaQuery.of(context).size.width -
                                            32.w),
                              ),
                              Visibility(
                                visible: !loadedState.isSearchFieldEditing &&
                                    homeCubit.role == Role.USER,
                                child: Row(
                                  children: [
                                    SizedBox(width: 10.w),
                                    FavoriteView(
                                      onTap: () => Navigator.push(
                                        context,
                                        FadeInRoute(const MyQuestsScreen(),
                                            Routes.myQuestScreen),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Visibility(
                          visible: loadedState.countFilters == 0 &&
                                  loadedState.categoriesList.isNotEmpty ||
                              homeCubit.role == Role.ADMIN,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CategoriesView(
                                  categoriesList: loadedState.categoriesList,
                                  onTap: (category) {
                                    context
                                        .read<QuestsScreenCubit>()
                                        .onTapCategory(category);
                                  }),
                              SizedBox(height: 32.h),
                            ],
                          ),
                        ),
                        cubit.searchController.text.isNotEmpty ||
                                loadedState.countFilters != 0
                            ? QuestsSmallView(
                                canEdit: [Role.ADMIN, Role.MANAGER]
                                    .contains(homeCubit.role),
                                questItems: loadedState.questsList,
                              )
                            : QuestsView(
                                canEdit: [Role.ADMIN, Role.MANAGER]
                                    .contains(homeCubit.role),
                                questItems: loadedState.questsList,
                              ),
                      ],
                    ),
                    const BlurRectangleView(),
                    if (homeCubit.role == Role.ADMIN &&
                        !(cubit.searchController.text.isNotEmpty ||
                            loadedState.countFilters != 0))
                      Positioned(
                        bottom: 148.h,
                        right: 16.w,
                        left: 16.w,
                        child: CustomButton(
                            title: LocaleKeys.kTextAddNewQuest.tr(),
                            onTap: () => Navigator.push(
                                  context,
                                  FadeInRoute(
                                      EditQuestScreen(
                                        isCreateQuest: true,
                                        onQuestCreated: () {
                                          // Обновляем список квестов после создания
                                          context
                                              .read<QuestsScreenCubit>()
                                              .loadData();
                                        },
                                      ),
                                      Routes.editQuestScreen),
                                ),
                            iconLeft: Icon(Icons.add_rounded,
                                size: 25.w, color: UiConstants.whiteColor),
                            buttonColor: UiConstants.greenColor),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
