import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/adapters.dart';
part 'daily_business_hours.g.dart';

@HiveType(typeId: 13)
class DailyBusinessHours {
  @HiveField(0)
  final String day;
  @HiveField(1)
  bool isOPenOnDay;
  @HiveField(2)
  String openingTime;
  @HiveField(3)
  String closingTime;

  DailyBusinessHours(
      {required this.day,
      this.isOPenOnDay = true,
      this.closingTime = '',
      this.openingTime = ''});

  String toStringRepresentation() {
    return '$day $openingTime - $closingTime | $isOPenOnDay';
  }

  factory DailyBusinessHours.fromJson(Map<String, dynamic> json) {
    return DailyBusinessHours(
      day: json['day'] as String,
      isOPenOnDay: json['isOPenOnDay'] ?? true,
      closingTime: json['closingTime'] ?? '',
      openingTime: json['openingTime'] ?? '',
    );
  }

  factory DailyBusinessHours.fromString(String stringHours) {
    List<String> hoursParts = stringHours.trim().split(' ');
    return DailyBusinessHours(
      day: hoursParts[0],
      isOPenOnDay: hoursParts.last.toLowerCase() == 'true',
      openingTime: '${hoursParts[1]} ${hoursParts[2]}',
      closingTime: '${hoursParts[4]} ${hoursParts[5]}',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'isOPenOnDay': isOPenOnDay,
      'closingTime': closingTime,
      'openingTime': openingTime,
    };
  }

  static List<DailyBusinessHours> getListOfHours(String? hours) {
    try {
      List<DailyBusinessHours> hoursList = (hours ?? '')
          .trim()
          .split('\n')
          .map((stringHours) => DailyBusinessHours.fromString(stringHours))
          .toList();
      return hoursList;
    } catch (e) {
      return [];
    }
  }

  @override
  String toString() => toJson().toString();

  static int getIntergerTimeOfDay(TimeOfDay time) {
    return int.parse(
        "${time.hour.toString().padLeft(2, '0')}${time.minute.toString().padLeft(2, '0')}");
  }

  bool hasValidHours() => closingTime != '' && openingTime != '';
  TimeOfDay closingTimeOfDay() => fromStringHours(closingTime);
  TimeOfDay openingTimeOfDay() => fromStringHours(openingTime);
  int integerOpeningTime() => getIntergerTimeOfDay(openingTimeOfDay());
  int integerClosingingTime() => getIntergerTimeOfDay(closingTimeOfDay());

  bool isOpenNow() {
    DateTime now = DateTime.now().toLocal();
    String today = DateFormat('EEEE', 'en_US').format(now);
    if (today.startsWith(day)) {
      TimeOfDay timeNow = TimeOfDay(hour: now.hour, minute: now.minute);
      int integerTimeNow = getIntergerTimeOfDay(timeNow);
      if (integerTimeNow < integerClosingingTime() &&
          integerTimeNow > integerOpeningTime()) {
        return true;
      } else if (integerClosingingTime() < integerOpeningTime() &&
          (integerTimeNow < integerClosingingTime() ||
              integerTimeNow > integerOpeningTime())) {
        return true;
      }
      return false;
    }
    return false;
  }

  bool isToday() {
    DateTime now = DateTime.now().toLocal();
    String today = DateFormat('EEEE', 'en_US').format(now);
    return today.startsWith(day);
  }

  static const daysOfWeek = 'Mon Tue Wed Thu Fri Sat Sun';

  static TimeOfDay fromStringHours(String hours) {
    if (hours.length > 4) {
      var reg = RegExp(r'\d+');
      var ex =
          reg.allMatches(hours).map((m) => int.parse(m[0] ?? '0')).toList();
      if (ex.length == 2) {
        int hour = ex[0];
        if (hours.toLowerCase().contains('pm') && hour < 12) {
          hour += 12;
        }
        return TimeOfDay(hour: hour, minute: ex[1]);
      }
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }
}
