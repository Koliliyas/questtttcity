import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:los_angeles_quest/constants/paths.dart';
import 'package:los_angeles_quest/constants/size_utils.dart';
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/cubit/custom_text_field_cubit.dart';
import 'package:los_angeles_quest/features/presentation/widgets/custom_text_field/cubit/custom_text_field_state.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField(
      {super.key,
      this.hintText,
      required this.controller,
      this.suffixWidget,
      this.contentPadding,
      this.keyboardType = TextInputType.text,
      this.isObscuredText = false,
      this.isNeedShowHiddenTextIcon = false,
      this.prefixWidget,
      this.onTap,
      this.readOnly = false,
      this.suffixText,
      this.prefixText,
      this.isNeedLabel = false,
      this.isExpanded = false,
      this.minLines = 1,
      this.validator,
      this.textInputAction,
      this.errorText,
      this.regExp,
      this.isEnabled = true,
      this.inputFormatters,
      this.textStyle,
      this.maxLength,
      this.isShowError = false,
      this.onChangedField,
      this.isTextFieldInBottomSheet = false,
      this.onKeyboardChangedVisible,
      this.fillColor = Colors.white,
      this.textColor = Colors.black,
      this.textAlign = TextAlign.start,
      this.height = 57,
      this.borderRadius,
      this.focusNode,
      this.onTapOutsideAvailable = true});

  final String? hintText;
  final TextEditingController controller;
  final Widget? suffixWidget;
  final Widget? prefixWidget;
  final EdgeInsets? contentPadding;
  final TextInputType keyboardType;
  final bool isObscuredText;
  final Function? onTap;
  final bool readOnly;
  final bool isEnabled;
  final String? suffixText;
  final String? prefixText;
  final bool isNeedLabel;
  final bool isExpanded;
  final int minLines;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final String? errorText;
  final RegExp? regExp;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? textStyle;
  final int? maxLength;
  final bool isShowError;
  final Function(String)? onChangedField;
  final bool isNeedShowHiddenTextIcon;
  final bool isTextFieldInBottomSheet;
  final Function(bool isKeyboardVisible)? onKeyboardChangedVisible;
  final Color? fillColor;
  final Color? textColor;
  final TextAlign textAlign;
  final double? height;
  final double? borderRadius;
  final FocusNode? focusNode;
  final bool onTapOutsideAvailable;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with WidgetsBindingObserver {
  bool isShowPassword = false;
  bool noChangedAnyway = true;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    isShowPassword = widget.isObscuredText;
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _checkKeyboardVisibilityWithDelay();
  }

  void _checkKeyboardVisibilityWithDelay() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0.0;
    if (widget.onKeyboardChangedVisible != null) {
      widget.onKeyboardChangedVisible!(isKeyboardVisible);
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus && bottomInset == 0.0) {
        currentFocus.unfocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomTextFieldCubit(),
      child: BlocBuilder<CustomTextFieldCubit, CustomTextFieldState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: widget.height,
                child: TextFormField(
                  focusNode: widget.focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: widget.textInputAction,
                  maxLength: widget.maxLength,
                  inputFormatters: widget.inputFormatters,
                  enabled: widget.isEnabled,
                  expands: !widget.isObscuredText && widget.isExpanded,
                  maxLines: !widget.isObscuredText && widget.isExpanded
                      ? null
                      : widget.minLines,
                  minLines: null,
                  onTap: () => widget.onTap != null ? widget.onTap!() : null,
                  readOnly: widget.readOnly,
                  obscureText: isShowPassword,
                  obscuringCharacter: '*',
                  keyboardType: widget.keyboardType,
                  controller: widget.controller,
                  style: widget.textStyle?.copyWith(decorationThickness: 0) ??
                      UiConstants.textStyle2.copyWith(
                        color: UiConstants.black2Color,
                        decorationThickness: 0,
                      ),
                  cursorColor:
                      widget.textStyle?.color ?? UiConstants.black2Color,
                  decoration: InputDecoration(
                    counterText: "",
                    label: widget.isNeedLabel && widget.hintText != null
                        ? Text(
                            widget.hintText ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: widget.textStyle ??
                                UiConstants.textStyle2.copyWith(
                                    color: UiConstants.black2Color,
                                    height: 1,
                                    fontWeight: FontWeight.w400),
                          )
                        : null,
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(widget.borderRadius ?? 63.r),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(widget.borderRadius ?? 63.r),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(widget.borderRadius ?? 63.r),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(widget.borderRadius ?? 63.r),
                      borderSide: BorderSide(
                          color: widget.isShowError
                              ? UiConstants.redColor
                              : Colors.transparent),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(widget.borderRadius ?? 63.r),
                      borderSide: BorderSide(
                          color: widget.isShowError
                              ? UiConstants.redColor
                              : Colors.transparent),
                    ),
                    filled: true,
                    fillColor: widget.fillColor ?? UiConstants.greyVioletColor,
                    hintText: widget.hintText,
                    contentPadding: widget.contentPadding ??
                        getMarginOrPadding(
                            left: 20, right: 20, top: 10, bottom: 10),
                    hintStyle: widget.textStyle
                            ?.copyWith(color: UiConstants.greyColor) ??
                        UiConstants.textStyle2
                            .copyWith(color: UiConstants.black2Color),
                    suffixIcon: widget.isNeedShowHiddenTextIcon ||
                            widget.suffixWidget != null
                        ? InkWell(
                            onTap: () => widget.isObscuredText
                                ? setState(
                                    () => isShowPassword = !isShowPassword,
                                  )
                                : widget.controller.clear(),
                            child: Padding(
                              padding: getMarginOrPadding(
                                  right: 20, top: 10, bottom: 10),
                              child: widget.isObscuredText &&
                                      widget.isNeedShowHiddenTextIcon
                                  ? (isShowPassword
                                      ? SvgPicture.asset(
                                          Paths.passwordShowIconPath)
                                      : SvgPicture.asset(
                                          Paths.passwordHideIconPath))
                                  : widget.suffixWidget,
                            ),
                          )
                        : null,
                    suffixText: widget.controller.text.isNotEmpty
                        ? widget.suffixText
                        : null,
                    prefixStyle: (widget.textStyle ?? UiConstants.textStyle8),
                    prefixText: widget.controller.text.isNotEmpty
                        ? widget.prefixText
                        : null,
                    prefixIcon: widget.prefixWidget != null
                        ? Padding(
                            padding: getMarginOrPadding(left: 20, right: 10),
                            child: widget.prefixWidget,
                          )
                        : null,
                    errorText: widget.isShowError ? state.errorText : null,
                    errorStyle: (widget.textStyle ?? UiConstants.textStyle8)
                        .copyWith(
                            color: UiConstants.redColor,
                            height: 0,
                            fontSize: 0.1,
                            fontWeight: FontWeight.w400),
                  ),
                  textAlign: widget.textAlign,
                  validator: (value) {
                    if (noChangedAnyway) {
                      setState(() {
                        noChangedAnyway = false;
                      });
                    }

                    return widget.validator != null
                        ? widget.validator!(value)
                        : null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (value) {
                    setState(() {
                      noChangedAnyway = false;
                    });
                    widget.onChangedField != null
                        ? widget.onChangedField!(value)
                        : null;
                    widget.isShowError
                        ? context
                            .read<CustomTextFieldCubit>()
                            .onEditingComplete(
                                widget.controller.text,
                                widget.isTextFieldInBottomSheet,
                                context,
                                widget.key,
                                regExp: widget.regExp,
                                customErrorText: widget.errorText)
                        : null;
                  },
                  onTapOutside: widget.onTapOutsideAvailable
                      ? (event) =>
                          FocusScope.of(context).requestFocus(FocusNode())
                      : null,
                ),
              ),
              if (widget.validator != null
                  ? widget.validator!(widget.controller.text) != null &&
                      !noChangedAnyway &&
                      widget.errorText != null
                  : false)
                Padding(
                  padding: getMarginOrPadding(top: 2),
                  child: Container(
                    padding: getMarginOrPadding(
                        left: 8, right: 8, top: 2, bottom: 2),
                    decoration: BoxDecoration(
                      color: UiConstants.redColor,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Text(
                      widget.errorText ?? 'The field must not be empty',
                      style: UiConstants.textStyle26
                          .copyWith(color: UiConstants.whiteColor),
                    ),
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}
