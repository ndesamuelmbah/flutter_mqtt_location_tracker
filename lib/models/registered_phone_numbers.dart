import 'package:hive/hive.dart';

part 'registered_phone_numbers.g.dart';

@HiveType(typeId: 11)
class RegisteredPhoneNumbers extends HiveObject {
  @HiveField(0)
  List<String> registeredPhonesNumbers;

  RegisteredPhoneNumbers({
    required this.registeredPhonesNumbers,
  });

  factory RegisteredPhoneNumbers.fromJson(Map<String, dynamic> json) {
    return RegisteredPhoneNumbers(
      registeredPhonesNumbers: (json['registeredPhonesNumbers'] as List)
          .map((e) => e.toString())
          .toList(),
    );
  }

  bool hastThePhoneNumber(String phoneNumber) =>
      registeredPhonesNumbers.contains(phoneNumber);

  Map<String, dynamic> toJson() {
    return {
      'registeredPhonesNumbers': registeredPhonesNumbers,
    };
  }
}
