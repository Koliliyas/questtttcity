import 'dart:io';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/core/routes.dart';
import 'package:los_angeles_quest/features/data/models/user_model.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/account/components/buttons/create_user_button.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/account/cubit/account_screen_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/features/presentation/widgets/gradient_card.dart';
import 'package:los_angeles_quest/locator_service.dart';

import 'components/buttons/delete_button.dart';
import 'components/buttons/logout_button.dart';
import 'components/buttons/save_changes_button.dart';
import 'components/profile_chips_view.dart';

class AccountScreen extends StatefulWidget {
  final bool isAdminEditView;
  final bool isCreateUser;
  final UserModel? user;
  final bool isCreditView;
  const AccountScreen(
      {super.key,
      required this.isAdminEditView,
      this.user,
      this.isCreateUser = false,
      this.isCreditView = false});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int activeChipIndex = 0;

  late final PageController _pageController;

  bool _isEditing = false;

  XFile? image;

  @override
  void initState() {
    _isEditing = widget.isAdminEditView;
    activeChipIndex = widget.isCreditView ? 2 : 0;
    _pageController = PageController(initialPage: activeChipIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountScreenCubit>(
        create: (context) =>
            sl<AccountScreenCubit>()..init(user: widget.user, isCreateUser: widget.isCreateUser),
        child: BlocBuilder<AccountScreenCubit, AccountScreenState>(
          builder: (context, state) {
            if (state is AccountScreenLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AccountScreenLoaded) {
              final UserModel? userModel = state.user;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    Paths.backgroundGradient1Path,
                    fit: BoxFit.fill,
                  ),
                  Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                      centerTitle: true,
                      backgroundColor: Colors.transparent,
                      title: Text(
                        widget.isAdminEditView && !widget.isCreateUser
                            ? "${userModel?.firstName} ${userModel?.lastName}"
                            : 'Account',
                        style: UiConstants.textStyle3.copyWith(color: Colors.white),
                      ),
                      leading: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 53.w,
                            width: 53.w,
                            decoration: BoxDecoration(
                                color: UiConstants.whiteColor.withValues(alpha: .5),
                                shape: BoxShape.circle),
                            child: Icon(Icons.keyboard_backspace,
                                color: UiConstants.whiteColor, size: 30.w),
                          ),
                        ),
                      ),
                      actions: [
                        if (widget.isAdminEditView && !widget.isCreateUser)
                          IconButton(
                              onPressed: () {
                                context.read<AccountScreenCubit>().blockUser(userModel!.id);
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.block)),
                        if (!_isEditing && !widget.isAdminEditView)
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = true;
                                });
                              },
                              icon: const Icon(Icons.edit))
                      ],
                    ),
                    body: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_isEditing) {
                                final ImagePicker imagePicker = ImagePicker();
                                imagePicker.pickImage(source: ImageSource.gallery).then((value) {
                                  if (value != null) {
                                    setState(() {
                                      image = value;
                                    });
                                  }
                                });
                              }
                            },
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Container(
                                  height: 200,
                                  width: 200,
                                  decoration: const BoxDecoration(
                                    color: UiConstants.grayColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    clipBehavior: Clip.hardEdge,
                                    child: image != null
                                        ? Image.file(
                                            File(
                                              image!.path,
                                            ),
                                            fit: BoxFit.fill,
                                          )
                                        : userModel?.photoPath != null
                                            ? Image.network(
                                                userModel!.photoPath!,
                                                fit: BoxFit.fill,
                                              )
                                            : SvgPicture.asset(
                                                Paths.emptyAvatarPath,
                                              ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (widget.isAdminEditView && !widget.isCreateUser)
                            ProfileChipsView(
                              onTapChip: (chipIndex) {
                                setState(() {
                                  activeChipIndex = chipIndex;
                                  _pageController.animateToPage(
                                    chipIndex,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                });
                              },
                              activeChipIndex: activeChipIndex,
                              chipNames: const ['Information', 'Quests', 'Credits'],
                            ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (value) {
                                setState(() {
                                  activeChipIndex = value;
                                });
                              },
                              children: [
                                UserInfoComponent(
                                  image: image,
                                  isAdminEditView: widget.isAdminEditView,
                                  userModel: userModel,
                                  isEditing: _isEditing,
                                  onEdit: () {
                                    setState(() {
                                      _isEditing = false;
                                    });
                                  },
                                ),
                                if (widget.isAdminEditView && !widget.isCreateUser) ...[
                                  const UserQuestsGrid(),
                                  const UserCreditsList()
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ));
  }
}

class UserCreditsList extends StatelessWidget {
  const UserCreditsList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: 5,
      itemBuilder: (context, index) => GradientCard(
        color: UiConstants.dark2VioletColor.withAlpha(127),
        body: ListTile(
          title: Text(
            'Quest 1',
            style: UiConstants.textStyle3.copyWith(color: Colors.white),
          ),
          subtitle: Text(
            '100 points',
            style: UiConstants.textStyle2.copyWith(color: UiConstants.lightOrangeColor),
          ),
          leading: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                Paths.quest1Path,
                width: 50.w,
                height: 50.w,
                fit: BoxFit.fill,
              ),
            ),
          ),
          trailing: TextButton(
              onPressed: () {},
              child: Container(
                  decoration: BoxDecoration(
                    color: UiConstants.lightOrangeColor,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Text(
                    'Accrue',
                    style: UiConstants.textStyle2.copyWith(color: Colors.white),
                  ))),
        ),
      ),
    );
  }
}

class UserQuestsGrid extends StatelessWidget {
  const UserQuestsGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      childAspectRatio: 0.75,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      crossAxisCount: 2,
      children: List.generate(
          5,
          (index) => Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                color: UiConstants.darkViolet2Color.withAlpha(127),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10, right: 8, left: 8),
                  child: Column(
                    children: [
                      Expanded(
                        child: GradientCard(
                          contentPadding: EdgeInsets.zero,
                          contentMargin: getMarginOrPadding(top: 10),
                          body: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24.r),
                                child: Image.asset(
                                  index % 2 == 0 ? Paths.quest1Path : Paths.quest2Path,
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8.w,
                                right: 12.w,
                                left: 12.w,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        height: 36.w,
                                        width: 36.w,
                                        decoration: BoxDecoration(
                                            color: UiConstants.whiteColor.withValues(alpha: .5),
                                            shape: BoxShape.circle),
                                        child: const Icon(
                                          Icons.favorite_outlined,
                                          color: UiConstants.redColor,
                                        ),
                                      ),
                                      SizedBox(width: 8.58.w),
                                      Container(
                                        width: 36.w,
                                        height: 36.w,
                                        decoration: const BoxDecoration(
                                            color: UiConstants.greenColor, shape: BoxShape.circle),
                                        //    padding: getMarginOrPadding(all: 10),
                                        child:
                                            const Icon(Icons.check, color: UiConstants.whiteColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          borderRadius: 24.r,
                        ),
                      ),
                      SizedBox(height: 13.h),
                      Text(LocaleKeys.kTextHollywoodHills.tr(),
                          style: UiConstants.textStyle4.copyWith(color: UiConstants.whiteColor),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              )),
    );
  }
}

class UserInfoComponent extends StatefulWidget {
  final UserModel? userModel;
  final bool isAdminEditView;
  final XFile? image;
  final bool isEditing;
  final void Function()? onEdit;
  const UserInfoComponent(
      {super.key,
      this.userModel,
      this.onEdit,
      required this.isAdminEditView,
      this.image,
      required this.isEditing});

  @override
  State<UserInfoComponent> createState() => _UserInfoComponentState();
}

class _UserInfoComponentState extends State<UserInfoComponent> {
  final TextEditingController _firstNameController = TextEditingController();

  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _instagramController = TextEditingController();
  late bool _isEditing;
  late bool isCreateUser;
  String role = 'User';
  List<String> capabilities = [];
  @override
  void initState() {
    _firstNameController.text = widget.userModel?.firstName ?? '';
    _lastNameController.text = widget.userModel?.lastName ?? '';
    _emailController.text = widget.userModel?.email ?? '';
    _usernameController.text = widget.userModel?.username ?? '';
    _instagramController.text = widget.userModel?.instagram ?? '';
    isCreateUser = widget.userModel == null;
    _isEditing = widget.isEditing;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant UserInfoComponent oldWidget) {
    if (widget.isEditing != oldWidget.isEditing) {
      _isEditing = widget.isEditing;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (isCreateUser) ...[
          Text(
            'The role',
            style: UiConstants.textStyle3.copyWith(color: Colors.white),
          ),
          Row(
            children: [
              Radio<String>.adaptive(
                  value: "User",
                  groupValue: role,
                  onChanged: (value) {
                    setState(() {
                      role = value!;
                    });
                  }),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: 'User' == role ? Colors.white : Colors.purple,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("User"),
                  ),
                ),
              )
            ],
          ),
          Row(
            children: [
              Radio<String>.adaptive(
                  value: "Manager",
                  groupValue: role,
                  onChanged: (value) {
                    setState(() {
                      role = value!;
                    });
                  }),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: 'Manager' == role ? Colors.white : Colors.purple,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Manager"),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
        ],
        CustomTextField(
          controller: _usernameController,
          hintText: 'Username',
          readOnly: !_isEditing,
        ),
        CustomTextField(
          controller: _firstNameController,
          hintText: 'First Name',
          readOnly: !_isEditing,
        ),
        CustomTextField(
          controller: _lastNameController,
          hintText: 'Last Name',
          readOnly: !_isEditing,
        ),
        CustomTextField(
          controller: _emailController,
          hintText: 'Email',
          readOnly: !_isEditing,
        ),
        CustomTextField(
          controller: _instagramController,
          hintText: 'Instagram',
          prefixWidget: SvgPicture.asset(Paths.instIconPath),
          readOnly: !_isEditing,
        ),
        if (!isCreateUser && _isEditing && !widget.isAdminEditView)
          Center(
            child: SaveChangesButton(
              onTap: () {
                context.read<AccountScreenCubit>().editUserData(
                      user: widget.userModel!,
                      id: widget.userModel!.id,
                      firstName: _firstNameController.text,
                      lastName: _lastNameController.text,
                      email: _emailController.text,
                      username: _usernameController.text,
                      image: widget.image,
                      instagram: _instagramController.text,
                    );

                setState(() {
                  _isEditing = false;
                });
                widget.onEdit?.call();
                context
                    .read<AccountScreenCubit>()
                    .init(user: widget.userModel, isCreateUser: false);
              },
            ),
          ),
        const SizedBox(height: 24),
        if (!isCreateUser && !_isEditing && !widget.isAdminEditView) ...[
          LogoutButton(
            onTap: () {
              context.read<AccountScreenCubit>().logout();
              Navigator.popUntil(context, ModalRoute.withName(Routes.logInScreen));
            },
          ),
          const SizedBox(height: 24),
        ],
        if (!isCreateUser && widget.isAdminEditView)
          DeleteButton(
            onTap: () {
              context.read<AccountScreenCubit>().blockUser(
                    widget.userModel!.id,
                  );

              Navigator.pop(context);
            },
          ),
        if (isCreateUser) ...[
          if (role == 'Manager') ...[
            Text(
              'Access rights',
              style: UiConstants.textStyle3.copyWith(color: Colors.white),
            ),
            Row(
              children: [
                Radio<String>.adaptive(
                    toggleable: true,
                    value: "Can edit quests",
                    groupValue: null,
                    onChanged: (value) {
                      setState(() {
                        if (capabilities.contains(value!)) {
                          capabilities.remove(value);
                        } else {
                          capabilities.add(value);
                        }
                      });
                    }),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          capabilities.contains('Can edit quests') ? Colors.white : Colors.purple,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Can edit quests"),
                    ),
                  ),
                )
              ],
            ),
            Row(
              children: [
                Radio<String>.adaptive(
                    toggleable: true,
                    value: "Can lock users",
                    groupValue: null,
                    onChanged: (value) {
                      setState(() {
                        if (capabilities.contains(value!)) {
                          capabilities.remove(value);
                        } else {
                          capabilities.add(value);
                        }
                      });
                    }),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: capabilities.contains('Can lock users') ? Colors.white : Colors.purple,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Can lock users'),
                    ),
                  ),
                )
              ],
            ),
          ],
          const SizedBox(height: 24),
          CreateUserButton(onTap: () {
            context.read<AccountScreenCubit>().createAccount(
                  firstName: _firstNameController.text,
                  lastName: _lastNameController.text,
                  email: _emailController.text,
                  username: _usernameController.text,
                  password: 'Password1!',
                  instagram: _instagramController.text,
                  role: role == 'User' ? 0 : 1,
                  image: widget.image,
                );

            Navigator.pop(context);
          })
        ]
      ]),
    );
  }
}

