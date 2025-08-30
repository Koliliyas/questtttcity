import 'dart:math';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_model.dart';
import 'package:los_angeles_quest/features/presentation/bloc/purchase_cubit.dart';
import 'package:los_angeles_quest/features/presentation/pages/common/quest/components/buy_quest_panel.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_app_bar.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';

class SeeAMapScreen extends StatelessWidget {
  final List<QuestPoint> route;
  final String questName;
  final List<MerchItem> merchItem;
  final int questId;
  final String mileage;
  final String questImage;
  const SeeAMapScreen(
      {super.key,
      required this.questId,
      required this.route,
      required this.questName,
      required this.merchItem,
      required this.mileage,
      required this.questImage});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseCubit, PurchaseState>(
      builder: (context, state) {
        final isQuestPurchased = state is PurchaseLoaded && state.isQuestPurchased;
        return BlocBuilder<HomeScreenCubit, HomeScreenState>(
          builder: (context, state) {
            //HomeScreenCubit homeCubit = context.read<HomeScreenCubit>();
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
                      bottom: 60,
                      right: 16,
                      left: 16),
                  child: Column(
                    children: [
                      CustomAppBar(
                          onTapBack: () => Navigator.pop(context),
                          title: LocaleKeys.kTextEntireRoute.tr()),
                      Text(
                        questName,
                        style: UiConstants.textStyle21.copyWith(color: UiConstants.whiteColor),
                      ),
                      SizedBox(height: 20.h),
                      Expanded(
                          child: MapWidget(
                              route: route.map((e) => LatLng(e.latitude, e.longitude)).toList())),
                      Visibility(
                        child: Padding(
                          padding: getMarginOrPadding(top: 47),
                          child: BuyQuestPanel(
                            questImage: questImage,
                            questName: questName,
                            questId: questId,
                            isQuestPurchased: isQuestPurchased,
                            onBuyQuest: context.read<PurchaseCubit>().purchaseQuest,
                            merchItem: merchItem,
                            mileage: mileage,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MapWidget extends StatefulWidget {
  final List<LatLng> route;
  final Function(LatLng)? onLongTap;
  const MapWidget({super.key, required this.route, this.onLongTap});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  LatLng _calculateCenter(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(0, 0);

    double lat = 0;
    double lng = 0;

    for (var point in points) {
      lat += point.latitude;
      lng += point.longitude;
    }

    return LatLng(lat / points.length, lng / points.length);
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    if (points.isEmpty) return LatLngBounds(southwest: const LatLng(0, 0), northeast: const LatLng(0, 0));
    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  double _calculateZoom(LatLngBounds bounds) {
    const worldWidth = 256.0;
    var latRad = bounds.northeast.latitude * pi / 180;
    var latDiff = bounds.northeast.latitude - bounds.southwest.latitude;
    var lngDiff = bounds.northeast.longitude - bounds.southwest.longitude;
    var maxZoom = 21.0;

    var latZoom = log(worldWidth * 360 / (latDiff * worldWidth)) / ln2;
    var lngZoom = log(worldWidth * 360 / (lngDiff * worldWidth * cos(latRad))) / ln2;

    return min(min(latZoom, lngZoom), maxZoom) + 0.5;
  }

  Future<BitmapDescriptor> _createCustomMarker(int number) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(80, 80);
    final paint = Paint()
      ..color = UiConstants.purpleColor
      ..style = PaintingStyle.fill;

    // Draw circle background
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.height / 2, paint);

    // Add number text
    final textPainter = TextPainter(
      text: TextSpan(
        text: (number + 1).toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(80, 80);
    final bytes = await image.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  Future<List<BitmapDescriptor>> _markers() async {
    List<BitmapDescriptor> markers = [];
    for (int i = 0; i < widget.route.length; i++) {
      markers.add(await _createCustomMarker(i));
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _markers(),
        builder: (context, future) {
          if (!future.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.hardEdge,
            child: GoogleMap(
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              onLongPress: widget.onLongTap,
              initialCameraPosition: CameraPosition(
                target: _calculateCenter(widget.route),
                zoom: _calculateZoom(_getBounds(widget.route)) - 0.3,
              ),
              polylines: {
                Polyline(
                  jointType: JointType.round,
                  patterns: [PatternItem.dash(10), PatternItem.gap(5)],
                  polylineId: const PolylineId('route'),
                  points: widget.route,
                  color: UiConstants.purpleColor,
                  width: 5,
                ),
              },
              markers: Set<Marker>.of(
                widget.route.map(
                  (e) => Marker(
                    markerId: MarkerId(e.toString()),
                    position: e,
                    icon: future.data![widget.route.indexOf(e)],
                  ),
                ),
              ),
            ),
          );
        });
  }
}

