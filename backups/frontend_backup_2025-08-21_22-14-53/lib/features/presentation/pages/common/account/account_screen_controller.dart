// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:los_angeles_quest/features/presentation/pages/common/account/components/buttons/block_user_button.dart';
// import 'package:los_angeles_quest/features/presentation/pages/common/account/components/buttons/create_user_button.dart';
// import 'package:los_angeles_quest/features/presentation/pages/common/account/components/buttons/delete_button.dart';
// import 'package:los_angeles_quest/features/presentation/pages/common/account/components/buttons/logout_button.dart';
// import 'package:los_angeles_quest/features/presentation/pages/common/account/components/buttons/save_changes_button.dart';
// import 'package:los_angeles_quest/features/presentation/pages/common/account/components/edit_button.dart';
// import 'package:los_angeles_quest/features/presentation/pages/common/account/cubit/account_screen_cubit.dart';
// import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';

// class AccountScreenController {
//   static Future<XFile?> pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//     return image;
//   }

//   static getButton(AccountScreenCubit cubit, BuildContext context) {
//     if (cubit.isCreateAccount) {
//       return CreateUserButton(onTap: () {
//         cubit.createAccount(context);
//       });
//     } else {
//       if (cubit.ownerRole == cubit.role) {
//         if (cubit.isEdit) {
//           return SaveChangesButton(onTap: () => cubit.updateMeData(context));
//         } else {
//           return LogoutButton(onTap: () => cubit.logout(context));
//         }
//       } else if (cubit.role == Role.ADMIN) {
//         // return EditButton(onTap: () => showBottomSheet(context: context, builder: (context) => EditUserBottomSheet()));
//       } else {
//         return BlockUserButton(onTap: () {});
//       }
//     }
//   }
// }
