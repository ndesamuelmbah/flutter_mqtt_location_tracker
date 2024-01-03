import 'package:hive/hive.dart';

part 'loan_payment.g.dart';

@HiveType(typeId: 3)
class LoanPayment {
  @HiveField(0)
  int paymentDate;

  @HiveField(1)
  double outStandingBalance;

  @HiveField(2)
  double newStandingBalance;

  @HiveField(3)
  double amountPaid;

  @HiveField(4)
  String recordedByDisplayName;

  @HiveField(5)
  String recordedByUserId;

  @HiveField(6)
  String paymentMessage;

  @HiveField(7)
  String? other;

  @HiveField(8)
  String paymentMethod;

  LoanPayment({
    required this.paymentDate,
    required this.outStandingBalance,
    required this.newStandingBalance,
    required this.amountPaid,
    required this.recordedByDisplayName,
    required this.recordedByUserId,
    required this.paymentMessage,
    this.other,
    required this.paymentMethod,
  });

  factory LoanPayment.fromJson(Map<String, dynamic> json) => LoanPayment(
        paymentDate: json['paymentDate'],
        outStandingBalance: json['outStandingBalance'],
        newStandingBalance: json['newStandingBalance'],
        amountPaid: json['amountPaid'],
        recordedByDisplayName: json['recordedByDisplayName'],
        recordedByUserId: json['recordedByUserId'],
        paymentMessage: json['paymentMessage'],
        other: json['other'],
        paymentMethod: json['paymentMethod'],
      );

  Map<String, dynamic> toJson() => {
        'paymentDate': paymentDate,
        'outStandingBalance': outStandingBalance,
        'newStandingBalance': newStandingBalance,
        'amountPaid': amountPaid,
        'recordedByDisplayName': recordedByDisplayName,
        'recordedByUserId': recordedByUserId,
        'paymentMessage': paymentMessage,
        'other': other,
        'paymentMethod': paymentMethod,
      };
}
