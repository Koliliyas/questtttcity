import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest_edit/edit_quest_screen_data.dart';

class StatisticsScreenData {
  List<QuestPreference> data = [
    QuestPreference(
      title: LocaleKeys.kTextCategory.tr(),
      [
        QuestPreferenceItem('Detective'),
        QuestPreferenceItem('Ghostbusters'),
        QuestPreferenceItem('Searching for rocks'),
      ],
    ),
    QuestPreference(
      title: LocaleKeys.kTextQuest.tr(),
      [
        QuestPreferenceItem('Name of the quest'),
        QuestPreferenceItem('Name of the quest'),
        QuestPreferenceItem('Name of the quest'),
      ],
    ),
  ];
}

