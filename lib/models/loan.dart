import 'package:hive/hive.dart';
import 'package:flutter_mqtt_location_tracker/models/firebase_auth_user.dart';
import 'package:flutter_mqtt_location_tracker/models/loan_gaurantor_approver.dart';
import 'package:flutter_mqtt_location_tracker/models/loan_payment.dart';
import 'package:flutter_mqtt_location_tracker/models/loan_update.dart';

part 'loan.g.dart';

@HiveType(typeId: 4)
class Loan {
  @HiveField(0)
  String ownerId;
  @HiveField(1)
  String loanRequestReason;
  @HiveField(2)
  int requestedDate;
  @HiveField(3)
  int proposedRepaymentDate;
  @HiveField(4)
  double outStandingBalance;
  @HiveField(5)
  List<LoanPayment> payments;
  @HiveField(6)
  List<LoanUpdate> loanUpdates;
  @HiveField(7)
  int? approvalDate;
  @HiveField(8)
  int? loanDueDate;
  @HiveField(9)
  String ownerName;
  @HiveField(10)
  int ownerShares;
  @HiveField(11)
  List<FirebaseAuthUser> gaurantors;
  @HiveField(12)
  String requesterSignature;
  @HiveField(13)
  String loanId;
  @HiveField(14)
  double monthlyInterestRate;
  @HiveField(15)
  int submissionDate;
  @HiveField(16)
  List<LoanGuarantorApprover> approvedGaurantors;
  @HiveField(17)
  List<dynamic> supportingDocuments;

  Loan(
      {required this.ownerId,
      required this.loanRequestReason,
      required this.requestedDate,
      required this.proposedRepaymentDate,
      required this.outStandingBalance,
      required this.payments,
      required this.loanUpdates,
      this.approvalDate,
      this.loanDueDate,
      required this.ownerName,
      required this.ownerShares,
      required this.gaurantors,
      required this.requesterSignature,
      required this.loanId,
      this.monthlyInterestRate = 0.05,
      required this.submissionDate,
      required this.approvedGaurantors,
      required this.supportingDocuments});

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
      ownerId: json['ownerId'] as String,
      loanRequestReason: json['loanRequestReason'] as String,
      requestedDate: json['requestedDate'] as int,
      proposedRepaymentDate: json['proposedRepaymentDate'] as int,
      outStandingBalance: json['outStandingBalance'] as double,
      payments: List<LoanPayment>.from(
          ((json['payments'] ?? []) as List<dynamic>)
              .map((e) => LoanPayment.fromJson(e as Map<String, dynamic>))),
      loanUpdates: List<LoanUpdate>.from(
          ((json['loanUpdates'] ?? []) as List<dynamic>)
              .map((e) => LoanUpdate.fromJson(e as Map<String, dynamic>))),
      approvalDate: json['approvalDate'] as int?,
      loanDueDate: json['loanDueDate'] as int?,
      ownerName: json['ownerName'] as String,
      ownerShares: json['ownerShares'] as int,
      gaurantors: List<FirebaseAuthUser>.from(((json['gaurantors'] ?? [])
              as List<dynamic>)
          .map((e) => FirebaseAuthUser.fromJson(e as Map<String, dynamic>))),
      requesterSignature: json['requesterSignature'] as String,
      loanId: json['loanId'] as String,
      monthlyInterestRate: json['monthlyInterestRate'] ?? 0.05,
      submissionDate: json['submissionDate'],
      approvedGaurantors: List<LoanGuarantorApprover>.from(
          ((json['approvedGaurantors'] ?? []) as List<dynamic>)
              .map((e) => LoanGuarantorApprover.fromJson(e as Map<String, dynamic>))),
      // ((json['approvedGaurantors'] ?? []) as List<dynamic>)
      //     .map((e) => e.toString())
      //     .toList(),
      supportingDocuments: ((json['supportingDocuments'] ?? []) as List<dynamic>).map((e) => e.toString()).toList());

  Map<String, dynamic> toJson() => {
        'ownerId': ownerId,
        'loanRequestReason': loanRequestReason,
        'requestedDate': requestedDate,
        'proposedRepaymentDate': proposedRepaymentDate,
        'outStandingBalance': outStandingBalance,
        'payments': payments.map((e) => e.toJson()).toList(),
        'loanUpdates': loanUpdates.map((e) => e.toJson()).toList(),
        'approvalDate': approvalDate,
        'loanDueDate': loanDueDate,
        'ownerName': ownerName,
        'ownerShares': ownerShares,
        'gaurantors': gaurantors.map((e) => e.toJson()).toList(),
        'requesterSignature': requesterSignature,
        'loanId': loanId,
        'monthlyInterestRate': monthlyInterestRate,
        'submissionDate': submissionDate,
        'approvedGaurantors':
            approvedGaurantors.map((e) => e.toJson()).toList(),
        'supportingDocuments': supportingDocuments
      };
}
