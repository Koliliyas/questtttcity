import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/core/fade_in_route.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/core/shared_preferences_keys.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/settings_screen/components/settings_item.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/home_screen.dart';
import 'package:los_angeles_quest/locator_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeRoleWidget extends StatelessWidget {
  const ChangeRoleWidget({super.key, required this.roles});

  final List<int> roles;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        Role currentRole = context.read<HomeScreenCubit>().role!;
        List<Role> availableRoles = roles
            .map((role) => Utils.convertServerRoleToEnumItem(role))
            .toList()
            .where((role) => role != currentRole)
            .toList();
        return ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              Role availableRole = availableRoles[index];
              return SettingsItem(
                title: 'Continue as a ${availableRoles[index]}',
                onTap: () async {
                  final currentContext = context;
                  SharedPreferences sharedPreferences = sl();
                  await sharedPreferences.setString(
                      SharedPreferencesKeys.role, availableRole.name);
                  Navigator.pushAndRemoveUntil(
                      currentContext,
                      FadeInRoute(
                        const HomeScreen(),
                        Routes.homeScreen,
                        arguments: {'role': availableRole},
                      ),
                      (route) => false);
                },
              );
            },
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemCount: roles.isNotEmpty ? roles.length - 1 : 0);
      },
    );
  }
}
