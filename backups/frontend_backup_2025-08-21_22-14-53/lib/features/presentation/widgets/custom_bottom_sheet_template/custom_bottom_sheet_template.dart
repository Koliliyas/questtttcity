import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_bottom_sheet_template/cubit/custom_bottom_sheet_template_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_button.dart';

class CustomBottomSheetTemplate extends StatefulWidget {
  const CustomBottomSheetTemplate(
      {super.key,
      required this.height,
      required this.isBack,
      this.onTapBack,
      this.titleText,
      this.titleWidget,
      required this.body,
      this.buttonText,
      this.onTapButton,
      this.button2Text,
      this.onTapButton2,
      this.isBackgroundImage = false,
      this.buttonHasGradient = true});

  final double height;
  final bool isBack;
  final Function()? onTapBack;
  final String? titleText;
  final Widget? titleWidget;
  final Widget body;
  final String? buttonText;
  final Function()? onTapButton;
  final String? button2Text;
  final Function()? onTapButton2;
  final bool isBackgroundImage;
  final bool buttonHasGradient;

  @override
  State<CustomBottomSheetTemplate> createState() => _CustomBottomSheetTemplateState();
}

class _CustomBottomSheetTemplateState extends State<CustomBottomSheetTemplate>
    with WidgetsBindingObserver {
  bool _isKeyboardVisible = false;
  bool _isFirstInitial = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = View.of(context).viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0.0;
    if (isKeyboardVisible != _isKeyboardVisible) {
      _isKeyboardVisible = isKeyboardVisible;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomBottomSheetTemplateCubit, CustomBottomSheetTemplateState>(
      builder: (context, state) {
        CustomBottomSheetTemplateCubit cubit = context.read<CustomBottomSheetTemplateCubit>();
        if (_isFirstInitial) {
          cubit.reset();
          _isFirstInitial = false;
        }
        if (_isKeyboardVisible != cubit.isVisibleKeyboard) {
          cubit.keyboardVisibleChanged(_isKeyboardVisible);
        }
        return Stack(
          children: [
            Container(
              height:
                  widget.height + MediaQuery.of(context).viewInsets.bottom + cubit.heightAllowance,
              width: MediaQuery.of(context).size.width,
              padding: getMarginOrPadding(left: 16, right: 16, top: 17, bottom: 0),
              decoration: BoxDecoration(
                color: UiConstants.dark2VioletColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24.r),
                ),
                image: widget.isBackgroundImage
                    ? const DecorationImage(
                        image: AssetImage(Paths.backgroundGradient1Path),
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high)
                    : null,
              ),
              child: Column(
                children: [
                  Container(
                    height: 5.h,
                    width: 43.w,
                    decoration: BoxDecoration(
                      color: UiConstants.whiteColor,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Visibility(
                    visible: widget.titleText != null || widget.titleWidget != null,
                    child: Column(
                      children: [
                        widget.titleWidget != null
                            ? (widget.titleWidget ?? Container())
                            : widget.titleText != null
                                ? Row(
                                    mainAxisAlignment: widget.isBack
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    children: [
                                      if (widget.isBack)
                                        InkWell(
                                          onTap: widget.onTapBack,
                                          child: Padding(
                                            padding: getMarginOrPadding(right: 16),
                                            child: const Icon(Icons.arrow_back,
                                                color: UiConstants.whiteColor),
                                          ),
                                        ),
                                      Align(
                                        child: Padding(
                                          padding: getMarginOrPadding(top: widget.isBack ? 5 : 0),
                                          child: Text(
                                            widget.titleText ?? '',
                                            style: UiConstants.textStyle6
                                                .copyWith(color: UiConstants.whiteColor),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                  Expanded(child: widget.body),
                  if (cubit.isVisibleKeyboard) SizedBox(height: 23.h)
                ],
              ),
            ),
            if (widget.buttonText != null || widget.button2Text != null)
              Positioned(
                bottom: 30.h,
                right: 16.w,
                left: 16.w,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 32.w,
                  child: Row(
                    children: [
                      if (widget.buttonText != null)
                        Expanded(
                          child: CustomButton(
                              title: widget.buttonText ?? '',
                              onTap: widget.onTapButton,
                              textColor:
                                  widget.button2Text != null ? UiConstants.orangeColor : null,
                              buttonColor:
                                  widget.button2Text != null ? UiConstants.orangeColor : null,
                              hasGradient: widget.buttonHasGradient),
                        ),
                      if (widget.button2Text != null) SizedBox(width: 8.w),
                      if (widget.button2Text != null)
                        Expanded(
                          child: CustomButton(
                            title: widget.button2Text ?? '',
                            onTap: widget.onTapButton2,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
