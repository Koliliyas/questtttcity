

// class AccountInformationPageView extends StatefulWidget {
//   const AccountInformationPageView(
//       {super.key,
//       required this.canEdit,
//       required this.role,
//       required this.nicknameController,
//       required this.fNameController,
//       required this.sNameController,
//       required this.emailController,
//       required this.instController,
//       required this.currentPasswordController,
//       required this.newPasswordController,
//       required this.owner,
//       this.button,
//       this.isCreateAccount = false,
//       required this.changeAccountCreateRole,
//       required this.onChangeManagerAccessRights,
//       required this.managerAccesses,
//       required this.accountRoleCreate});

//   final bool isCreateAccount;
//   final Role accountRoleCreate;
//   final Function(Role role) changeAccountCreateRole;
//   final Function(ManagerAccessRights managerAccessRights)
//       onChangeManagerAccessRights;
//   final List<ManagerAccessRights> managerAccesses;

//   final bool canEdit;
//   final Role role;
//   final Role owner;
//   final TextEditingController nicknameController;
//   final TextEditingController fNameController;
//   final TextEditingController sNameController;
//   final TextEditingController emailController;
//   final TextEditingController instController;
//   final TextEditingController currentPasswordController;
//   final TextEditingController newPasswordController;
//   final Widget? button;

//   @override
//   State<AccountInformationPageView> createState() =>
//       _AccountInformationPageViewState();
// }

// class _AccountInformationPageViewState
//     extends State<AccountInformationPageView> {
//   List<QuestPreference> createAccountPreferencesData = [
//     QuestPreference(
//       title: LocaleKeys.kTextRole.tr(),
//       [
//         QuestPreferenceItem(LocaleKeys.kTextNewUser.tr()),
//         QuestPreferenceItem(LocaleKeys.kTextManager.tr()),
//       ],
//     ),
//     QuestPreference(
//       title: 'Access rights',
//       [
//         QuestPreferenceItem('Can reply to comments'),
//         QuestPreferenceItem('Can lock users out'),
//       ],
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         if (widget.isCreateAccount)
//           Padding(
//             padding: getMarginOrPadding(bottom: 32),
//             child: QuestPreferenceView(
//                 title: createAccountPreferencesData[0].title,
//                 preferencesItems: createAccountPreferencesData[0].items,
//                 checkedItemIndex: widget.accountRoleCreate == Role.USER ? 0 : 1,
//                 onTap: (preferencesIndex, preferencesItemIndex,
//                         {bool? preferencesItemHasSubitems,
//                         preferencesSubItemIndex}) =>
//                     widget.changeAccountCreateRole(
//                         preferencesItemIndex == 0 ? Role.USER : Role.MANAGER),
//                 preferenceIndex: 0),
//           ),
//         if (!(widget.isCreateAccount &&
//                 widget.accountRoleCreate == Role.MANAGER ||
//             widget.owner == Role.MANAGER))
//           Padding(
//             padding: getMarginOrPadding(bottom: 12),
//             child: CustomTextField(
//               hintText: LocaleKeys.kTextNickname.tr(),
//               controller: widget.nicknameController,
//               textInputAction: TextInputAction.next,
//               isExpanded: true,
//               textStyle: UiConstants.textStyle12
//                   .copyWith(color: UiConstants.blackColor),
//               fillColor: UiConstants.whiteColor,
//               validator: (value) => Utils.validate(value),
//               isEnabled: widget.canEdit,
//             ),
//           ),
//         CustomTextField(
//           hintText: LocaleKeys.kTextFirstName.tr(),
//           controller: widget.fNameController,
//           textInputAction: TextInputAction.next,
//           isExpanded: true,
//           textStyle:
//               UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
//           fillColor: UiConstants.whiteColor,
//           validator: (value) => Utils.validate(value),
//           isEnabled: widget.canEdit,
//         ),
//         SizedBox(height: 12.h),
//         CustomTextField(
//           hintText: LocaleKeys.kTextSecondName.tr(),
//           controller: widget.sNameController,
//           textInputAction: TextInputAction.next,
//           isExpanded: true,
//           textStyle:
//               UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
//           fillColor: UiConstants.whiteColor,
//           validator: (value) => Utils.validate(value),
//           isEnabled: widget.canEdit,
//         ),
//         SizedBox(height: 12.h),
//         CustomTextField(
//           hintText: LocaleKeys.kTextEmail.tr(),
//           controller: widget.emailController,
//           keyboardType: TextInputType.emailAddress,
//           textInputAction: TextInputAction.next,
//           isExpanded: true,
//           textStyle:
//               UiConstants.textStyle12.copyWith(color: UiConstants.blackColor),
//           fillColor: UiConstants.whiteColor,
//           validator: (value) => Utils.validate(value),
//           inputFormatters: [
//             FilteringTextInputFormatter.deny(
//               RegExp(r'\s'),
//             ),
//           ],
//           isEnabled: widget.canEdit,
//         ),
//         if ((widget.isCreateAccount && widget.accountRoleCreate == Role.USER ||
//             widget.owner == Role.USER))
//           Padding(
//             padding: getMarginOrPadding(top: 12),
//             child: CustomTextField(
//               hintText: LocaleKeys.kTextInstagram.tr(),
//               controller: widget.instController,
//               textInputAction: TextInputAction.done,
//               isExpanded: true,
//               textStyle: UiConstants.textStyle12
//                   .copyWith(color: UiConstants.blackColor),
//               fillColor: UiConstants.whiteColor,
//               prefixWidget: SizedBox(
//                 height: 40.w,
//                 width: 40.w,
//                 child: SvgPicture.asset(Paths.instIconPath),
//               ),
//               validator: (value) => Utils.validate(value),
//               inputFormatters: [
//                 FilteringTextInputFormatter.deny(
//                   RegExp(r'\s'),
//                 ),
//               ],
//               isEnabled: widget.canEdit,
//             ),
//           ),
//         if (widget.isCreateAccount) ...[
//           Padding(
//             padding: getMarginOrPadding(top: 12),
//             child: CustomTextField(
//               hintText: LocaleKeys.kTextNewPassword.tr(),
//               controller: widget.currentPasswordController,
//               textInputAction: TextInputAction.done,
//               isExpanded: true,
//               textStyle: UiConstants.textStyle12
//                   .copyWith(color: UiConstants.blackColor),
//               fillColor: UiConstants.whiteColor,
//               validator: (value) => Utils.validate(value),
//               inputFormatters: [
//                 FilteringTextInputFormatter.deny(
//                   RegExp(r'\s'),
//                 ),
//               ],
//               isEnabled: widget.canEdit,
//             ),
//           ),
//           Padding(
//             padding: getMarginOrPadding(top: 12),
//             child: CustomTextField(
//               hintText: LocaleKeys.kTextPassword.tr(),
//               controller: widget.newPasswordController,
//               textInputAction: TextInputAction.done,
//               isExpanded: true,
//               textStyle: UiConstants.textStyle12
//                   .copyWith(color: UiConstants.blackColor),
//               fillColor: UiConstants.whiteColor,
//               validator: (value) => Utils.validate(value),
//               inputFormatters: [
//                 FilteringTextInputFormatter.deny(
//                   RegExp(r'\s'),
//                 ),
//               ],
//               isEnabled: widget.canEdit,
//             ),
//           ),
//         ],
//         if (widget.isCreateAccount && widget.accountRoleCreate == Role.MANAGER)
//           Padding(
//             padding: getMarginOrPadding(top: 32),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   createAccountPreferencesData[1].title ?? '',
//                   style: UiConstants.textStyle8
//                       .copyWith(color: UiConstants.whiteColor),
//                 ),
//                 SizedBox(height: 12.h),
//                 QuestPreferenceViewItem(
//                     preferencesItem:
//                         createAccountPreferencesData[1].items.first,
//                     isChecked: widget.managerAccesses
//                         .contains(ManagerAccessRights.reply_to_comment),
//                     onTap: (preferencesIndex, preferencesItemIndex,
//                             {bool? preferencesItemHasSubitems,
//                             preferencesSubItemIndex}) =>
//                         widget.onChangeManagerAccessRights(
//                             ManagerAccessRights.reply_to_comment),
//                     index: 0,
//                     preferenceIndex: 0),
//                 SizedBox(height: 10.h),
//                 QuestPreferenceViewItem(
//                     preferencesItem: createAccountPreferencesData[1].items.last,
//                     isChecked: widget.managerAccesses
//                         .contains(ManagerAccessRights.lock_users),
//                     onTap: (preferencesIndex, preferencesItemIndex,
//                             {bool? preferencesItemHasSubitems,
//                             preferencesSubItemIndex}) =>
//                         widget.onChangeManagerAccessRights(
//                             ManagerAccessRights.lock_users),
//                     index: 1,
//                     preferenceIndex: 0),
//               ],
//             ),
//           ),
//         SizedBox(height: 37.h),
//         Padding(
//           padding: getMarginOrPadding(right: 16, left: 16),
//           child: FilledButton(
//               onPressed: () {
//                 context.read<AccountScreenCubit>().editUserData(context);
//               },
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.edit),
//                   SizedBox(width: 10.w),
//                   Text('Edit'),
//                 ],
//               )),
//         ),
//         if (!widget.isCreateAccount && widget.role == Role.ADMIN)
//           Padding(
//             padding: getMarginOrPadding(right: 16, left: 16),
//             child: FilledButton(
//                 onPressed: () {
//                   context.read<AccountScreenCubit>().blockUser(context);
//                 },
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.delete),
//                     SizedBox(width: 10.w),
//                     Text('Delete'),
//                   ],
//                 )),
//           ),
//         widget.button ?? Container()
//       ],
//     );
//   }
// }

