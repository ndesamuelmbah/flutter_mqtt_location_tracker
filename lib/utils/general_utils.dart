import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' show NumberFormat, DateFormat;
import 'package:path/path.dart' as path;

import 'package:universal_html/html.dart' if (dart.library.html) 'dart:html'
    as html;

final RegExp replaceWhiteSpacePattern = RegExp(r"[,\s+]");
final numberFormat = NumberFormat("#,##0.00", "en_US");
final longDateTimeFormat = DateFormat('EEEE, MMM dd, yyyy, HH:mm a');
final shortDateFormat = DateFormat('EEEE, MMM dd, yyyy');
String getFormattedTime(int time, {String? dateFormat}) {
  DateTime inquiryTime = DateTime.fromMillisecondsSinceEpoch(time);
  return DateFormat(dateFormat ?? 'EEEE, MMM dd, yyyy, HH:mm a')
      .format(inquiryTime);
}

DateTime getUtcNow() {
  return DateTime.now().toUtc().add(const Duration(hours: 1));
}

const String dGLetters =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
String fixText(String text, {String replaceWith = ' '}) {
  return text.replaceAll(replaceWhiteSpacePattern, replaceWith);
}

const int maxOrderRadiusInMiles = 10;

extension NullableStringExtension on String? {
  bool get isNotNullAndNotEmpty => this != null && this!.trim() != '';
  bool get isNullOrWhiteSpace => this == null || this!.trim() == '';

  bool get isNotNull => this != null;
  bool get isNotEmpty => isNullOrWhiteSpace;
  bool get isNumericOnly => double.tryParse(this ?? "") != null;
}

extension StringExtension on String {
  bool get isNotNullAndNotEmpty => trim() != '';
  bool get isNullOrWhiteSpace => trim() == '' || toLowerCase() == 'null';
  bool get isNotEmpty => isNullOrWhiteSpace;
  bool get isNumericOnly => double.tryParse(this) != null;
  String get toTitleCase {
    if (isNullOrWhiteSpace) return this;
    String res = this[0].toUpperCase();
    String prev = this[0].toUpperCase();
    final wordsPattern = RegExp(r'[\w]');
    for (int i = 1; i < length; i++) {
      String char = this[i];
      if (!wordsPattern.hasMatch(prev)) {
        res += char.toUpperCase();
      } else {
        res += char.toLowerCase();
      }
      prev = char;
    }

    return res;
  }

  String get toCamelCase {
    String input = replaceAll(RegExp(r'\s+'), '');
    if (input.isNullOrWhiteSpace || input.length == 1) {
      return input;
    }
    var camelCase = '';
    var prevIsUnderscore = false;
    for (var char in input.split('')) {
      if (prevIsUnderscore) {
        if (char != '_') {
          camelCase += char.toUpperCase();
          prevIsUnderscore = char == '_';
        }
      } else if (char == '_') {
        prevIsUnderscore = true;
      } else {
        camelCase += char;
        prevIsUnderscore = false;
      }
    }

    return camelCase;
  }
}

String getFormatedCurrency(String currencySymbol, num amount) =>
    '$currencySymbol${numberFormat.format(amount)}';

List<String> getListOfValidStringsFromStirng(String? inputString,
    [String splitPattern = ',']) {
  inputString = inputString?.trim();
  if (inputString == null) {
    return [];
  }
  List<String> validStrings = [];
  for (String subString
      in inputString.split(splitPattern).map((e) => e.trim())) {
    if (subString.length > 2) {
      validStrings.add(subString);
    }
  }
  return validStrings;
}

String getSupportPhone(String countryCode) {
  String cc = countryCode.toLowerCase().trim();
  if ('cm td ml sn tg cf bj bf ga fg gw cg cd ci ne tg'.contains(cc)) {
    return "+237676297472";
  } else if ('tz rw ug ke so sd mw cd za bw zm ss'.contains(cc)) {
    return "+250781976155";
  } else if ('ng' == cc) {
    return "+2348121693506";
  } else {
    return '+13016408856';
  }
}

int getConstrainedWidth(Size size, int max) {
  num use = size.width > max ? max : size.width;
  return use ~/ 350;
}

double getPadding(Size size, {bool forForm = false}) {
  double width = size.width;
  if (forForm) {
    if (width < 400) {
      return 5;
    }
    return (width - 400) / 2;
  }
  if (width < 600) {
    return 0;
  }
  if (width > 1300) {
    return (width - 1300) / 2;
  }
  return width * 0.05;
}

String getFileExtensionFromUrl(String url) {
  String fileName = path.basename(url);
  final pattern = RegExp(r'\b\w+\b');
  final matches = pattern.allMatches(path.extension(fileName));

  final words = matches.map((match) => match.group(0)).toList();
  return words.first!;
}

const imageExtentions = ['jpg', 'jpeg', 'png'];
String getChatMessageId(num time) {
  int timeId = (time) as int;
  if (timeId < 62) {
    return dGLetters[timeId];
  }
  String res = '';
  int remainder = 0;
  while (timeId > 61) {
    remainder = timeId % 62;
    timeId ~/= 62;
    res += dGLetters[remainder];
  }
  res += dGLetters[remainder];
  // set res to reverse of res
  res = res.split('').reversed.join('');
  return res;
}

bool kIsWebOnMobile({bool isMobile = false}) {
  if (isMobile) {
    return isMobile;
  }
  if (kIsWeb) {
    String userAgent = html.window.navigator.userAgent;
    userAgent = userAgent.toLowerCase();
    if (userAgent.contains('android') ||
        userAgent.contains('ios') ||
        userAgent.contains('mobile') ||
        userAgent.contains('iphone')) {
      return true;
    }
  }
  return false;
}

String getUserAgent() {
  if (kIsWeb) {
    return html.window.navigator.userAgent;
  }
  return 'No User Agent';
}

Map<String, dynamic> getCamelCaseLocationMap(Map<String, dynamic> locationMap) {
  var latLongMap = {'latitude': 'lat', 'longitude': 'lon'};
  return locationMap.map((key, value) {
    if (latLongMap.containsKey(key)) {
      return MapEntry(latLongMap[key]!, value);
    }
    return MapEntry(key.toCamelCase, value);
  });
}

// String encryptString(String plainText, String password) {
//   final key = sha256.convert(utf8.encode(password)).bytes;
//   final iv = List<int>.generate(16, (_) => 0); // Initialization Vector (IV)
//   final encrypter = AES(Key(key), AESMode.cbc);
//   final encryptedBytes = encrypter.encrypt(utf8.encode(plainText), iv: IV(iv)).bytes;
//   final encryptedText = base64.encode(encryptedBytes);
//   return encryptedText;
// }

// // Decrypt an encrypted string
// String decryptString(String encryptedText, String password) {
//   final key = sha256.convert(utf8.encode(password)).bytes;
//   final iv = List<int>.generate(16, (_) => 0); // Initialization Vector (IV)
//   final encrypter = AES(Key(key), AESMode.cbc);
//   final decryptedBytes = encrypter.decrypt(base64.decode(encryptedText), iv: IV(iv)).bytes;
//   final decryptedText = utf8.decode(decryptedBytes);
//   return decryptedText;
// }
// void main() {
//   final plainText = 'Hello, World!';
//   final password = 'mySecretPassword';

//   final encryptedText = encryptString(plainText, password);
//   print('Encrypted: $encryptedText');

//   final decryptedText = decryptString(encryptedText, password);
//   print('Decrypted: $decryptedText');
// }

List<Widget> getDocumentPreview(String url) {
  final ext = url.contains('.pdf')
      ? 'pdf'
      : url.contains('.docx')
          ? 'docx'
          : url.contains('.doc')
              ? 'doc'
              : url.contains('.xls')
                  ? 'xlsx'
                  : 'txt';
  final icon = ext == 'pdf'
      ? FontAwesomeIcons.filePdf
      : ext.contains('doc')
          ? FontAwesomeIcons.fileWord
          : ext.contains('xls')
              ? FontAwesomeIcons.fileExcel
              : FontAwesomeIcons.fileLines;
  const textStyle = TextStyle(fontSize: 18, color: Colors.blue);
  return [
    const SizedBox(
      height: 10,
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 30,
          color: Colors.blue,
        ),
        const SizedBox(
          width: 20,
        ),
        Text('Tap to Open (.$ext) file', style: textStyle),
      ],
    ),
    const SizedBox(
      height: 20,
    ),
  ];
}
