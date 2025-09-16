import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

import 'package:los_angeles_quest/l10n/locale_keys.dart';

class RememberUser extends StatefulWidget {
  final bool isRemembered;
  final Function() onChangeRememberedCheckbox;
  const RememberUser(
      {super.key,
      required this.onChangeRememberedCheckbox,
      required this.isRemembered});

  @override
  State<RememberUser> createState() => _RememberUserState();
}

class _RememberUserState extends State<RememberUser> {
  bool _isRemembered = false;

  @override
  void initState() {
    _isRemembered = widget.isRemembered;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        _isRemembered = !_isRemembered;
        widget.onChangeRememberedCheckbox();
      }),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(4.r),
                ),
              ),
              value: _isRemembered,
              activeColor: UiConstants.purpleColor,
              onChanged: (bool? newValue) => setState(() {
                _isRemembered = !_isRemembered;
                widget.onChangeRememberedCheckbox();
              }),
              side: WidgetStateBorderSide.resolveWith(
                (states) => const BorderSide(
                  color: Colors.transparent,
                ),
              ),
              fillColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return UiConstants.purpleColor;
                  }
                  return UiConstants.lightPinkColor;
                },
              ),
            ),
          ),
          Padding(
            padding: getMarginOrPadding(top: 3),
            child: Text(
              LocaleKeys.kTextRememberTheUserOnThisDevice.tr(),
              style: UiConstants.rememberTheUser
                  .copyWith(color: UiConstants.whiteColor),
            ),
          ),
        ],
      ),
    );
  }
}

