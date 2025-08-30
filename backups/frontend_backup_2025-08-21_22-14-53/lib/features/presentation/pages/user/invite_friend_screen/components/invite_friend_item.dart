import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';

class InviteFriendItem extends StatefulWidget {
  const InviteFriendItem(
      {super.key,
      required this.onTap,
      required this.index,
      required this.isChecked});

  final int index;
  final Function(int index) onTap;
  final bool isChecked;

  @override
  State<InviteFriendItem> createState() => _InviteFriendItemState();
}

class _InviteFriendItemState extends State<InviteFriendItem> {
  bool _isChecked = false;

  @override
  void initState() {
    _isChecked = widget.isChecked;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        _isChecked = !_isChecked;
        widget.onTap(widget.index);
      }),
      child: Row(
        children: [
          CircleAvatar(
            radius: 48.w / 2,
            child: ClipOval(
              child: Image.asset(
                Paths.avatarPath,
                fit: BoxFit.cover,
                width: 48.w,
                height: 48.w,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Tomas Andersen',
              style: UiConstants.textStyle5
                  .copyWith(color: UiConstants.whiteColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 10.w),
          if (_isChecked)
            SvgPicture.asset(Paths.checkInCircleIconPath,
                height: 24.w, width: 24.w)
        ],
      ),
    );
  }
}
