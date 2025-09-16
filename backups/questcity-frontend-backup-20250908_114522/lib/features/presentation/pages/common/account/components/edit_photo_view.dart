// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:los_angeles_quest/constants/paths.dart';
// import 'package:los_angeles_quest/constants/size_utils.dart';
// import 'package:los_angeles_quest/constants/ui_constants.dart';
// import 'package:los_angeles_quest/features/presentation/pages/common/account/account_screen_controller.dart';

// class EditPhotoView extends StatelessWidget {
//   const EditPhotoView(
//       {super.key, required this.onTap, required this.isEnabled});

//   final bool isEnabled;
//   final Function(XFile image) onTap;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: isEnabled
//           ? () async {
//               XFile? image = await AccountScreenController.pickImage();
//               if (image != null) {
//                 onTap(image);
//               }
//             }
//           : null,
//       child: Container(
//         padding: getMarginOrPadding(all: 14),
//         height: 44.w,
//         width: 44.w,
//         decoration: BoxDecoration(
//             color: UiConstants.whiteColor.withValues(alpha: .5),
//             shape: BoxShape.circle),
//         child: SvgPicture.asset(Paths.plus2),
//       ),
//     );
//   }
// }
