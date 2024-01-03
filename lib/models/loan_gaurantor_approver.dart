import 'package:hive/hive.dart';

part 'loan_gaurantor_approver.g.dart';

@HiveType(typeId: 5)
class LoanGuarantorApprover extends HiveObject {
  @HiveField(0)
  DateTime gaurantorApprovalDate;

  @HiveField(1)
  String gaurantorSignature;

  @HiveField(2)
  String gaurantorUid;

  @HiveField(3)
  String gaurantorName;

  @HiveField(4)
  String loanId;

  LoanGuarantorApprover({
    required this.gaurantorApprovalDate,
    required this.gaurantorSignature,
    required this.gaurantorUid,
    required this.gaurantorName,
    required this.loanId,
  });

  factory LoanGuarantorApprover.fromJson(Map<String, dynamic> json) =>
      LoanGuarantorApprover(
        gaurantorApprovalDate: DateTime.parse(json['gaurantorApprovalDate']),
        gaurantorSignature: json['gaurantorSignature'],
        gaurantorUid: json['gaurantorUid'],
        gaurantorName: json['gaurantorName'],
        loanId: json['loanId'],
      );

  Map<String, dynamic> toJson() => {
        'gaurantorApprovalDate': gaurantorApprovalDate.toIso8601String(),
        'gaurantorSignature': gaurantorSignature,
        'gaurantorUid': gaurantorUid,
        'gaurantorName': gaurantorName,
        'loanId': loanId,
      };
}
