import 'package:easy_localization/easy_localization.dart';
import 'package:los_angeles_quest/l10n/locale_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/custom_text_field.dart';

class CustomSearchView extends StatefulWidget {
  const CustomSearchView(
      {super.key,
      required this.controller,
      this.suffixWidget,
      this.onKeyboardChangedVisible,
      this.isExpanded = false,
      this.options,
      this.focusNode,
      this.onTapOption,
      this.widthOverlay,
      this.fillColor});

  final TextEditingController controller;
  final Widget? suffixWidget;
  final Function(bool)? onKeyboardChangedVisible;
  final bool isExpanded;
  final List<String>? options;
  final FocusNode? focusNode;
  final Function(String option)? onTapOption;
  final double? widthOverlay;
  final Color? fillColor;

  @override
  State<CustomSearchView> createState() => _CustomSearchViewState();
}

class _CustomSearchViewState extends State<CustomSearchView> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode ??= widget.focusNode ?? FocusNode();

    if (widget.options != null) widget.controller.addListener(_onTextChanged);
    _focusNode?.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode?.removeListener(_onFocusChanged);
    super.dispose();
  }

  Future _onTextChanged() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final text = widget.controller.text;
    if (text.isNotEmpty && _focusNode?.hasFocus == true) {
      await _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  Future _onFocusChanged() async {
    if (_focusNode?.hasFocus == true && widget.controller.text.isNotEmpty) {
      await _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  Future _showOverlay() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final filteredOptions = widget.options!
        .where(
          (option) => option.toLowerCase().contains(
                widget.controller.text.toLowerCase(),
              ),
        )
        .toList();

    if (filteredOptions.isEmpty) {
      _removeOverlay();
      return;
    }

    _removeOverlay();

    _overlayEntry = _createOverlayEntry(filteredOptions);
    if (mounted) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry(List<String> filteredOptions) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = Size(
        widget.widthOverlay ?? renderBox.size.width, renderBox.size.height);

    final heightForListLength3 = 183.h;
    final heightList = filteredOptions.length == 1
        ? heightForListLength3 * 0.32
        : filteredOptions.length == 2
            ? heightForListLength3 * 0.66
            : heightForListLength3;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: widget.widthOverlay ?? size.width,
        height: 500,
        child: Stack(
          children: [
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height),
              child: Material(
                color: UiConstants.whiteColor,
                borderRadius: BorderRadiusDirectional.vertical(
                  bottom: Radius.circular(16.r),
                ),
                child: SizedBox(
                  height: heightList,
                  child: ListView.separated(
                      itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              _removeOverlay();
                              if (index < filteredOptions.length) {
                                String tapOption = filteredOptions[index];
                                widget.controller.text = filteredOptions[index];
                                if (widget.onTapOption != null) {
                                  widget.onTapOption!(tapOption);
                                }
                              }
                              _focusNode?.unfocus();
                              //FocusScope.of(context).requestFocus(FocusNode());
                            },
                            child: Padding(
                              padding: getMarginOrPadding(left: 20, right: 20),
                              child: Text(
                                index < filteredOptions.length
                                    ? filteredOptions[index]
                                    : '',
                                style: UiConstants.textStyle2
                                    .copyWith(color: UiConstants.blackColor),
                              ),
                            ),
                          ),
                      separatorBuilder: (context, index) => Padding(
                            padding: getMarginOrPadding(top: 10, bottom: 10),
                            child: Divider(
                              color: UiConstants.lightViolet2Color
                                  .withValues(alpha: .1),
                            ),
                          ),
                      itemCount: filteredOptions.length,
                      padding: getMarginOrPadding(
                          left: 20, right: 20, bottom: 15, top: 15),
                      shrinkWrap: true),
                ),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height.h / 2),
              child: CustomPaint(
                painter: TrianglePainter(color: UiConstants.whiteColor),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(size.width, size.height.h / 2),
              child: Transform.flip(
                flipX: true,
                child: CustomPaint(
                  painter: TrianglePainter(color: UiConstants.whiteColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: CustomTextField(
          fillColor: widget.fillColor,
          focusNode: _focusNode,
          isExpanded: true,
          hintText: LocaleKeys.kTextSearch.tr(),
          controller: widget.controller,
          prefixWidget: SvgPicture.asset(Paths.searchIconPath,
              width: 24.w,
              height: 24.w,
              colorFilter: ColorFilter.mode(
                  widget.fillColor != null
                      ? UiConstants.grayColor
                      : UiConstants.whiteColor,
                  BlendMode.srcIn)),
          suffixWidget: widget.suffixWidget,
          onKeyboardChangedVisible: widget.onKeyboardChangedVisible,
          textStyle: UiConstants.textStyle2.copyWith(
            fontFamily: 'Inter',
            color: UiConstants.whiteColor,
          ),
          onTapOutsideAvailable: true),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color;

    Path path = Path();
    path.lineTo(0, 59 / 2); // РџРµСЂРІР°СЏ С‚РѕС‡РєР° p1
    path.lineTo(63.r / 2, 59 / 2); // Р’С‚РѕСЂР°СЏ С‚РѕС‡РєР° p2

    // Р”РѕР±Р°РІР»СЏРµРј РґСѓРіСѓ РІРјРµСЃС‚Рѕ РїСЂСЏРјРѕР№ Р»РёРЅРёРё РЅР° РіРёРїРѕС‚РµРЅСѓР·Рµ
    path.arcToPoint(
      const Offset(0, 0), // РљРѕРЅРµС‡РЅР°СЏ С‚РѕС‡РєР° РґСѓРіРё
      radius: Radius.circular(58.r / 2), // Р Р°РґРёСѓСЃ РґСѓРіРё
      clockwise: true,
    );

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

