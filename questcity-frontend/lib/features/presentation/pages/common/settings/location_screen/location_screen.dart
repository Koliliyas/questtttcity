import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/settings/location_screen/cubit/location_screen_cubit.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationScreenCubit()..getLocation(),
      child: BlocBuilder<LocationScreenCubit, LocationScreenState>(
        builder: (context, state) {
          if (state is LocationScreenLoaded) {
            _locationController.text = state.textLocation;
            return Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(Paths.backgroundGradient1Path),
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high),
                ),
                child: Padding(
                  padding: getMarginOrPadding(
                      top: MediaQuery.of(context).padding.top + 20,
                      left: 16,
                      right: 16,
                      bottom: 24),
                  child: Column(
                    children: [
                      CustomAppBar(
                          onTapBack: () => Navigator.pop(context),
                          title: LocaleKeys.kTextLocation.tr()),
                      SizedBox(height: 27.h),
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(height: 27.h),
                            Text(
                              "Here you can see your location and copy it to clipboard",
                              style: UiConstants.textStyle2
                                  .copyWith(color: UiConstants.whiteColor),
                            ),
                            SizedBox(height: 14.h),
                            Expanded(
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                    target: state.coordinates, zoom: 16),
                                markers: {
                                  Marker(
                                      markerId: const MarkerId('0'),
                                      position: state.coordinates)
                                },
                              ),
                            ),
                            SizedBox(height: 31.h),
                            CustomTextField(
                              hintText: LocaleKeys.kTextLocation.tr(),
                              controller: _locationController,
                              isExpanded: true,
                              textStyle: UiConstants.textStyle12
                                  .copyWith(color: UiConstants.blackColor),
                              fillColor: UiConstants.whiteColor,
                              contentPadding: getMarginOrPadding(
                                  left: 20, right: 20, top: 16, bottom: 16),
                              suffixWidget: GestureDetector(
                                onTap: () async {
                                  await Clipboard.setData(ClipboardData(
                                      text: _locationController.text));
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(LocaleKeys
                                            .kTextLocationCopied
                                            .tr()),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding:
                                      getMarginOrPadding(top: 5, bottom: 5),
                                  child: SvgPicture.asset(Paths.copyIconPath),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        },
      ),
    );
  }
}

