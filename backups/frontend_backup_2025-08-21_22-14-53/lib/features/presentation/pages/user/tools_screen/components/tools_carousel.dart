

// class ToolsCarousel extends StatelessWidget {
//   const ToolsCarousel({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         CarouselSlider.builder(
//           options: CarouselOptions(
//             height: 325.h,
//             viewportFraction: 0.5,
//             initialPage: 0,
//             enableInfiniteScroll: true,
//             enlargeCenterPage: true,
//             enlargeFactor: 0.4,
//             scrollDirection: Axis.horizontal,
//           ),
//           itemCount: 3,
//           itemBuilder: (context, index, realIndex) {
//             return const ToolsCarouselItem();
//           },
//         ),
//         SizedBox(height: 40.h),
//         Padding(
//           padding: getMarginOrPadding(left: 16, right: 16),
//           child: CustomButton(
//             title: LocaleKeys.kTextUseThisTool.tr(),
//             onTap: () => Navigator.pushReplacement(
//               context,
//               FadeInRoute(
//                   const OrbitalRadarScreen(), Routes.orbitalRadarScreen),
//             ),
//           ),
//         ),
//         SizedBox(height: 60.h)
//       ],
//     );
//   }
// }

