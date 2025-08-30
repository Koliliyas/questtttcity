

// class OrbitalRadarScreen extends StatelessWidget {
//   const OrbitalRadarScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: MediaQuery.of(context).size.width,
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//               image: AssetImage(Paths.mockCameraBackgroundPath),
//               fit: BoxFit.cover,
//               filterQuality: FilterQuality.high),
//         ),
//         child: Column(
//           children: [
//             Padding(
//               padding: getMarginOrPadding(
//                   top: MediaQuery.of(context).padding.top + 20),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Padding(
//                     padding: getMarginOrPadding(right: 16, left: 16),
//                     child: CustomAppBar(
//                       onTapBack: () => Navigator.pop(context),
//                       title: LocaleKeys.kTextOrbitalRadar.tr(),
//                       action: HintButton(onTap: () {}),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 60.h),
//             Expanded(
//               child: CustomSnappingBottomSheet(
//                 body: Align(
//                     alignment: Alignment.topCenter,
//                     child: Image.asset(Paths.bigOrbitalRadar)),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

