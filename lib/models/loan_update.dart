import 'package:hive/hive.dart';

part 'loan_update.g.dart';

@HiveType(typeId: 2)
class LoanUpdate {
  @HiveField(0)
  int updateDate;

  @HiveField(1)
  double outstandingBalance;

  @HiveField(2)
  String updatedByDisplayName;

  @HiveField(3)
  String updatedByUserId;

  @HiveField(4)
  String updateMessage;

  @HiveField(5)
  String? other;

  LoanUpdate({
    required this.updateDate,
    required this.outstandingBalance,
    required this.updatedByDisplayName,
    required this.updatedByUserId,
    required this.updateMessage,
    this.other,
  });

  factory LoanUpdate.fromJson(Map<String, dynamic> json) {
    return LoanUpdate(
      updateDate: json['updateDate'],
      outstandingBalance: json['outstandingBalance'],
      updatedByDisplayName: json['updatedByDisplayName'],
      updatedByUserId: json['updatedByUserId'],
      updateMessage: json['updateMessage'],
      other: json['other'],
    );
  }

  Map<String, dynamic> toJson() => {
        'updateDate': updateDate,
        'outstandingBalance': outstandingBalance,
        'updatedByDisplayName': updatedByDisplayName,
        'updatedByUserId': updatedByUserId,
        'updateMessage': updateMessage,
        'other': other,
      };
}
