import 'package:flutter/services.dart';

class PhoneNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      // Если текст пуст, возвращаем пустое значение
      return newValue.copyWith(
          text: '', selection: const TextSelection.collapsed(offset: 0));
    }

    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = StringBuffer();

    // Add '+' at the beginning if not already present
    if (!newValue.text.startsWith('+')) {
      newText.write('+');
      if (newValue.selection.end >= 1) selectionIndex++;
    }

    // Add country code and format
    if (newTextLength >= 2) {
      newText.write(newValue.text.substring(0, usedSubstringIndex = 1));
      newText.write(' (');
      if (newValue.selection.end >= 2) selectionIndex += 2;
    }
    if (newTextLength >= 5) {
      newText.write('${newValue.text.substring(1, usedSubstringIndex = 4)}) ');
      if (newValue.selection.end >= 5) selectionIndex += 2;
    }
    if (newTextLength >= 8) {
      newText.write('${newValue.text.substring(4, usedSubstringIndex = 7)} - ');
      if (newValue.selection.end >= 8) selectionIndex += 3;
    }
    if (newTextLength >= 11) {
      newText.write('${newValue.text.substring(7, usedSubstringIndex = 9)} - ');
      if (newValue.selection.end >= 11) selectionIndex += 3;
    }
    if (newTextLength >= 13) {
      newText.write(newValue.text.substring(9, usedSubstringIndex = 11));
      if (newValue.selection.end >= 13) selectionIndex += 2;
    }

    // Dump the rest.
    if (newTextLength >= usedSubstringIndex) {
      newText.write(newValue.text.substring(usedSubstringIndex));
    }

    // Limit length to 12 digits (maximum phone number length without formatting characters)
    final formattedLength = newText.toString().length;
    if (formattedLength > 22) {
      return oldValue;
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
