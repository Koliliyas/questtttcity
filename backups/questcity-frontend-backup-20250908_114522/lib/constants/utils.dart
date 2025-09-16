import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:los_angeles_quest/constants/ui_constants.dart';
import 'package:los_angeles_quest/features/presentation/pages/admin/statistics_screen/components/statistics_screen_filter_body/statistics_screen_filter_body.dart';
import 'package:los_angeles_quest/features/presentation/pages/home_screen/cubit/home_screen_cubit.dart';
import 'dart:io';

class Utils {
  static RegExp emailRegex = RegExp(r'^[^@]+@[a-zA-Z]+\.[a-zA-Z]+$');
  static final RegExp _passwordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{8,}$');

  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field cannot be empty';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    String? result = validate(value);
    if (result == null) {
      bool isEmail = _passwordRegex.hasMatch(value!);
      if (isEmail) {
        return null;
      } else {
        return 'password should contain at least 8 characters, 1 uppercase letter, 1 lowercase letter, 1 number and 1 special character';
      }
    }
    return result;
  }

  static String? validateEmail(String? value) {
    String? result = validate(value);
    if (result == null) {
      bool isEmail = emailRegex.hasMatch(value!);
      if (isEmail) {
        return null;
      } else {
        return 'email should be ____@domen.__';
      }
    }
    return result;
  }

  static Future<XFile?> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // Проверяем, что файл существует и доступен
        final file = File(image.path);
        if (await file.exists()) {
          return image;
        } else {
          print('❌ ERROR: Selected image file does not exist: ${image.path}');
          return null;
        }
      }

      return null;
    } catch (e) {
      print('❌ ERROR: Failed to pick image: $e');
      return null;
    }
  }

  static Future<DateTime?> showTimePicker(BuildContext context) async {
    DateTime? date = await picker.DatePicker.showTimePicker(context,
        showTitleActions: true,
        theme: Utils.getDatePickerTheme(),
        showSecondsColumn: false,
        currentTime: DateTime.now());
    return date;
  }

  static Future<DateTime?> showDatePicker(BuildContext context) async {
    DateTime? date = await DatePicker.showPicker(
      context,
      pickerModel: CustomMonthPicker(
          minTime: DateTime(2024, 1, 1),
          maxTime: DateTime.now(),
          currentTime: DateTime.now(),
          locale: picker.LocaleType.en),
    );
    return date;
  }

  static picker.DatePickerTheme getDatePickerTheme() {
    TextStyle mainStyle = UiConstants.textStyle12.copyWith(
      color: UiConstants.blackColor,
    );
    return picker.DatePickerTheme(
      headerColor: UiConstants.whiteColor,
      backgroundColor: UiConstants.whiteColor,
      itemStyle: mainStyle,
      doneStyle: mainStyle.copyWith(fontWeight: FontWeight.bold),
      cancelStyle: mainStyle.copyWith(color: UiConstants.redColor),
    );
  }

  static Role convertServerRoleToEnumItem(int role) {
    switch (role) {
      case 0:
        return Role.USER;
      case 1:
        return Role.MANAGER;
      case 2:
        return Role.ADMIN;
      default:
        return Role.USER;
    }
  }

  static String? fixEncoding(String? input) {
    if (input == null) return null;

    // Decode the incorrectly decoded string back to bytes
    List<int> bytes = input.codeUnits;

    // Re-encode the bytes to a correct string using the desired encoding (e.g., Windows-1251)
    return utf8.decode(bytes);
  }

  /// Исправляет проблемы с кодировкой для русского текста
  static String fixRussianEncoding(String input) {
    try {
      // Если строка содержит непонятные символы, пытаемся исправить
      if (input.contains('РІРІРµСЂРІРІРµСЂР°') ||
          input.contains('РІРІРµСЂРІРІРµСЂР°') ||
          input.contains('РІРІРµСЂРІРІРµСЂР°')) {
        // Пытаемся исправить кодировку Windows-1251 -> UTF-8
        final bytes = input.codeUnits;
        return utf8.decode(bytes, allowMalformed: true);
      }

      return input;
    } catch (e) {
      // Если не удалось исправить, возвращаем как есть
      return input;
    }
  }

  static String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  static String formatTimestamp(int timestamp) {
    // Создаем объект DateTime из метки времени Unix
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    // Форматируем время в формате 'h:mm a' (например, 03:25 PM)
    String formattedTime = DateFormat('h:mm a').format(dateTime);

    return formattedTime;
  }

  static String formatDateMMMMd(DateTime dateTime) {
    final now = DateTime.now();

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'Today';
    } else {
      return DateFormat('MMMM, d', 'en').format(dateTime);
    }
  }

  static Map<String, dynamic> getNotNullFields(Map<String, dynamic> map) {
    return Map.from(map)
      ..removeWhere((key, value) =>
          value == null ||
          (value is String && value.trim().isEmpty && _isRequiredField(key)));
  }

  /// Проверяет, является ли поле обязательным для квеста
  static bool _isRequiredField(String fieldName) {
    const requiredFields = [
      'name',
      'description',
      'image',
    ];
    return requiredFields.contains(fieldName);
  }

  /// Специальная функция для квестов - не удаляет важные поля
  static Map<String, dynamic> getQuestFields(Map<String, dynamic> map) {
    final result = Map<String, dynamic>.from(map);

    // Удаляем только null значения, но сохраняем пустые строки и массивы
    result.removeWhere((key, value) => value == null);

    // Для квестов важно сохранить все поля, даже если они пустые
    return result;
  }

  /// Исправляет кодировку русского текста в JSON перед отправкой
  static Map<String, dynamic> fixJsonEncoding(Map<String, dynamic> json) {
    final result = Map<String, dynamic>.from(json);

    // Рекурсивно исправляем кодировку во всех строковых полях
    _fixEncodingRecursive(result);

    return result;
  }

  /// Рекурсивно исправляет кодировку в JSON
  static void _fixEncodingRecursive(dynamic data) {
    if (data is Map<String, dynamic>) {
      for (var entry in data.entries) {
        if (entry.value is String) {
          data[entry.key] = fixRussianEncoding(entry.value);
        } else if (entry.value is Map || entry.value is List) {
          _fixEncodingRecursive(entry.value);
        }
      }
    } else if (data is List) {
      for (var i = 0; i < data.length; i++) {
        if (data[i] is String) {
          data[i] = fixRussianEncoding(data[i]);
        } else if (data[i] is Map || data[i] is List) {
          _fixEncodingRecursive(data[i]);
        }
      }
    }
  }
}

extension NonNull on Map<String, dynamic> {
  Map<String, dynamic> get nonNullValues {
    return this..removeWhere((key, value) => value == null);
  }
}

extension Divided on List<Widget> {
  List<Widget> divided(Widget divider) {
    if (isEmpty) return [];
    final iterator = this.iterator;
    final result = <Widget>[iterator.current];
    while (iterator.moveNext()) {
      result.add(divider);
      result.add(iterator.current);
    }
    return result;
  }
}
