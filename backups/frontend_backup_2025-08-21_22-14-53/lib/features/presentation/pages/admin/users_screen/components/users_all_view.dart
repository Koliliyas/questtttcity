import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/features/domain/entities/user_entity.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/users_screen/components/user_item.dart';

import '../../../../../data/models/user_model.dart';

class UsersAllView extends StatelessWidget {
  const UsersAllView({super.key, required this.users});

  final List<UserEntity> users;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) => UserItem(
            user: UserModel.fromEntity(users[index]),
            isBlocked: !users[index].isActive),
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemCount: users.length);
  }
}
