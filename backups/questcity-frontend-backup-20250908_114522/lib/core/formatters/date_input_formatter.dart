import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue previousValue,
    TextEditingValue nextValue,
  ) {
    var inputText = nextValue.text;

    if (nextValue.selection.baseOffset == 0) {
      return nextValue;
    }

    // Удаляем все, кроме цифр
    inputText = inputText.replaceAll(RegExp(r'[^0-9]'), '');

    // Ограничиваем длину ввода до 4 символов
    if (inputText.length > 4) {
      inputText = inputText.substring(0, 4);
    }

    var bufferString = StringBuffer();
    for (int i = 0; i < inputText.length; i++) {
      if (i == 2) {
        bufferString.write('/');
      }
      bufferString.write(inputText[i]);
    }

    var string = bufferString.toString();
    return nextValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(
        offset: string.length,
      ),
    );
  }
}
