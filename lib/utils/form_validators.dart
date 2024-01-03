import 'package:flutter_mqtt_location_tracker/utils/general_utils.dart';

String? validateEmail(String? value,
    {bool isRequired = true, String? rejectEmail}) {
  String pattern =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?)*$";
  value = (value ?? '').trim();
  if (value.isEmpty) {
    return isRequired ? 'Email Address is Required' : null;
  }
  // if (value == rejectEmail){
  //   return 'You are already linked with this email'
  // }
  RegExp regex = RegExp(pattern);
  bool hasMatch = regex.hasMatch(value) && value.contains('.');
  return hasMatch ? null : 'Enter a valid email address';
}

String removeDiacritics(String str) {
  var withDia =
      'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
  var withoutDia =
      'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

  for (int i = 0; i < withDia.length; i++) {
    str = str.replaceAll(withDia[i], withoutDia[i]);
  }
  return str;
}

String? validateName(String? rawName) {
  rawName = rawName?.trim() ?? '';
  if (rawName.isEmpty) {
    return 'Tell us Your Name';
  }
  final name = removeDiacritics(rawName).replaceAll(RegExp(r'\s+'), ' ');

  if (RegExp(r'^[a-zA-Z]{2,}( [a-zA-Z]{2,}){1,3}$').hasMatch(name)) {
    return null;
  }
  return 'Enter at least 2 names';
}

String? validateAmountInWords(String? amount) {
  amount = amount?.trim() ?? '';
  if (amount.isEmpty) {
    return 'Required';
  }
  amount = removeDiacritics(amount).replaceAll(RegExp(r'\s+'), ' ');
  if (RegExp(r'\d+').hasMatch(amount)) {
    return 'Letters and commars only';
  }

  if (amount.split(' ').length >= 2) {
    return null;
  }
  return 'Too Short';
}

String? validateIDCard(String? cardNo) {
  cardNo = cardNo?.trim() ?? '';
  if (cardNo.isEmpty) {
    return 'Required';
  }
  final name = removeDiacritics(cardNo).replaceAll(RegExp(r'\s+'), ' ');
  if (name.length < 10) {
    return 'Too Short';
  }
  return null;
}

String? validateStringLength(String? value, {int minLength = 10}) {
  value = value?.trim() ?? '';
  if (value.isEmpty) {
    return 'Required';
  }
  if (value.length < minLength) {
    return 'Too Short';
  }
  return null;
}

String? validateDate(String? val) {
  if (val == null) {
    return 'Required';
  }
  var date = DateTime.tryParse(val);
  if (date == null) {
    return 'Use Calendar';
  }
  return null;
}

String bautifyName(String rawName) {
  final names = removeDiacritics(rawName.trim())
      .replaceAll(RegExp(r'\s+'), ' ')
      .split(' ')
      .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase());

  return names.join(' ');
}

String? validatePassword(String? value) {
  value = (value ?? '').trim();
  if (value.isEmpty) {
    return 'Please enter your password';
  }
  if (value.length < 6) {
    return 'Too Short';
  }
  if (value.replaceAll(RegExp(r'\s+'), '') != value) {
    return 'No White Spaces Allowed';
  }
  return null;
}

String? validatePinCode(String? v, {int expectedLength = 6}) {
  v = (v ?? '').trim();
  if (v.isEmpty) {
    return 'Enter the 6 digit Code';
  }
  if (!v.isNumericOnly) {
    return 'Enter only Numbers';
  }
  int length = v.length;
  if (length < expectedLength) {
    return "Remaining ${expectedLength - length} Numbers";
  }
  if (length > expectedLength) {
    return 'Too Long, Enter $expectedLength numbers';
  } else {
    return null;
  }
}

String? validateAmount(String? value) {
  value = (value ?? '').replaceAll(',', '').trim();
  if (value.isEmpty) {
    return 'Required';
  }
  double? amount = double.tryParse(value);
  if (amount == null) {
    return 'numbers, and/or commars';
  }
  if (amount < 20000) {
    return 'At least 20,000.00';
  }
  if (amount > 2000000) {
    return 'Max XAF 2000,000.00';
  }
  return null;
}

String? validateMonth(String? value, {minValue = 3, maxValue = 24}) {
  value = (value ?? '').trim();
  double? amount = double.tryParse(value);
  if (amount == null) {
    return 'Required';
  }
  final months = amount.toInt();
  if (months < minValue || months > maxValue) {
    return 'From $minValue to $maxValue';
  }
  return null;
}
