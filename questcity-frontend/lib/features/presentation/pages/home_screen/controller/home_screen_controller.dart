import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/users_screen/users_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/quests_list_screen/quests_list_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/admin_dashboard_screen/admin_dashboard_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/chat/chat_screen/chat_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/user/friends/friends_screen/friends_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quests/quests_screen/quests_screen.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/settings_screen.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class HomeScreenController {
  static String _getLocalizedText(String key, String fallback) {
    try {
      final result = key.tr();
      // РџСЂРѕРІРµСЂСЏРµРј, С‡С‚Рѕ СЂРµР·СѓР»СЊС‚Р°С‚ РЅРµ РїСѓСЃС‚РѕР№ Рё РЅРµ СЃРѕРґРµСЂР¶РёС‚ С‚РѕР»СЊРєРѕ РєР»СЋС‡
      if (result.isNotEmpty && result != key) {
        return result;
      } else {
        return fallback;
      }
    } catch (e) {
      return fallback;
    }
  }

  static List<List<Widget>> getNavigationScreensList(Role? role) {
    switch (role) {
      case Role.USER:
        return [
          [
            const QuestsScreen(),
          ],
          [
            const FriendsScreen(),
          ],
          [
            const ChatScreen(),
          ],
          [
            const SettingsScreen(),
          ],
        ];
      case Role.MANAGER:
        return [
          [
            const QuestsScreen(),
          ],
          [
            const ChatScreen(),
          ],
        ];

      case Role.ADMIN:
        return [
          [
            const QuestsListScreen(),
          ],
          [
            const ChatScreen(),
          ],
          [
            const UsersScreen(),
          ],
          [
            const SettingsScreen(),
          ],
        ];
      default:
        return [
          [
            Container(color: Colors.red),
          ],
          [
            Container(color: Colors.blue),
          ],
          [
            Container(color: Colors.green),
          ],
          [
            Container(color: Colors.yellow),
          ],
        ];
    }
  }

  static List<String> getNavigationIcons(Role? role) {
    switch (role) {
      case Role.USER:
        return [
          Paths.runHumanIconPath,
          Paths.friendsIconPath,
          Paths.chatIconPath,
          Paths.settingsIconPath
        ];
      case Role.MANAGER:
        return [
          Paths.runHumanIconPath,
          Paths.chatIconPath,
        ];
      case Role.ADMIN:
        return [
          Paths.runHumanIconPath,
          Paths.chatIconPath,
          Paths.friendsIconPath,
          Paths.settingsIconPath
        ];
      default:
        return [
          Paths.runHumanIconPath,
          Paths.friendsIconPath,
          Paths.chatIconPath,
          Paths.settingsIconPath
        ];
    }
  }

  static List<String> getNavigationNames(Role? role) {
    switch (role) {
      case Role.USER:
        return [
          _getLocalizedText(LocaleKeys.kTextQuests, 'Quests'),
          _getLocalizedText(LocaleKeys.kTextFriends, 'Friends'),
          _getLocalizedText(LocaleKeys.kTextChat, 'Chat'),
          _getLocalizedText(LocaleKeys.kTextSettings, 'Settings')
        ];
      case Role.MANAGER:
        return [
          _getLocalizedText(LocaleKeys.kTextQuests, 'Quests'),
          _getLocalizedText(LocaleKeys.kTextChat, 'Chat'),
        ];
      case Role.ADMIN:
        return [
          _getLocalizedText(LocaleKeys.kTextQuests, 'Quests'),
          _getLocalizedText(LocaleKeys.kTextChat, 'Chat'),
          _getLocalizedText(LocaleKeys.kTextUsers, 'Users'),
          _getLocalizedText(LocaleKeys.kTextSettings, 'Settings')
        ];
      default:
        return [
          _getLocalizedText(LocaleKeys.kTextQuests, 'Quests'),
          _getLocalizedText(LocaleKeys.kTextFriends, 'Friends'),
          _getLocalizedText(LocaleKeys.kTextChat, 'Chat'),
          _getLocalizedText(LocaleKeys.kTextSettings, 'Settings')
        ];
    }
  }

  // static showCloseAppSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     isDismissible: true,
  //     builder: (newContext) => CustomBottomSheetTemplate(
  //       height: 239,
  //       isBack: false,
  //       body: Align(
  //         alignment: Alignment.topLeft,
  //         child: Text(
  //           'Are you sure you want to close the application?',
  //           style:
  //              UiConstants.textStyle12.copyWith(color: UiConstants.darkColor),
  //         ),
  //       ),
  //       titleText: 'Close app',
  //       buttonText: 'Cancel',
  //       onTapButton: () {
  //         Navigator.pop(context);
  //       },
  //       button2Text: 'Close app',
  //       onTapButton2: () {
  //         Navigator.pop(context);
  //         SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  //       },
  //     ),
  //  );
  // }
}
