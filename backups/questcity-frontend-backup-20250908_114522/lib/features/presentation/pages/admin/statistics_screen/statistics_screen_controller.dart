import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/statistics_screen/components/statistics_screen_filter_body/statistics_screen_filter_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/statistics_screen/cubit/statistics_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_bottom_sheet_template/custom_bottom_sheet_template.dart';

class StatisticsScreenController {
  static showFilterSheet(BuildContext context, StatisticsScreenCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (newContext) => CustomBottomSheetTemplate(
        // РІС‹С‡РёС‚Р°РµРј РІС‹СЃРѕС‚Сѓ toolbar, С‚РµРєСЃС‚РѕРІРѕРіРѕ РїРѕР»СЏ (57.h),
        // РѕС‚СЃС‚СѓРїР° РѕС‚ toolbar (24.h) Рё РѕС‚СЃС‚СѓРїР° РѕС‚
        // С‚РµРєСЃС‚РѕРІРѕРіРѕ РїРѕР»СЏ (11.h)
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            92.h,
        isBack: false,
        buttonText: LocaleKeys.kTextShowStatistics.tr(),
        onTapButton: () => Navigator.pop(context),
        buttonHasGradient: false,
        body: StatisticsScreenFilterBody(
            selectedIndexes: cubit.selectedIndexes,
            onTap: cubit.onTapSubcategory,
            onResetFilter: cubit.onResetFilter,
            dateController: cubit.dateController,
            isExpandedQuestsInFilter: cubit.isExpandedQuestsInFilter,
            onExpandedOrCollapsedQuestsFilter:
                cubit.onExpandedOrCollapsedQuestsFilter),
      ),
    );
  }
}

