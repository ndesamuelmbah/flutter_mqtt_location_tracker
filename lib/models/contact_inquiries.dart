class ContactInquiry {
  String uid;
  String userName;
  String phoneNumber;
  String contactMessage;
  String email;
  int timestamp;
  bool hasResponse;
  String inquiryId;
  InquiryResponse? response;

  ContactInquiry({
    required this.uid,
    required this.userName,
    required this.phoneNumber,
    required this.contactMessage,
    required this.email,
    required this.timestamp,
    required this.hasResponse,
    required this.inquiryId,
    this.response,
  });

  // Factory method to create ContactInquiry object from a Map
  factory ContactInquiry.fromJson(Map<String, dynamic> json) {
    return ContactInquiry(
      uid: json['uid'],
      userName: json['userName'],
      phoneNumber: json['phoneNumber'],
      contactMessage: json['contactMessage'],
      email: json['email'],
      timestamp: json['timestamp'],
      hasResponse: json['hasResponse'],
      inquiryId: json['inquiryId'],
      response: json['response'] != null
          ? InquiryResponse.fromJson(json['response'] as Map<String, dynamic>)
          : null,
    );
  }
  bool hasBeenRespondedTo() => response != null;

  // Convert ContactInquiry object to a Map
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'userName': userName,
      'phoneNumber': phoneNumber,
      'contactMessage': contactMessage,
      'email': email,
      'timestamp': timestamp,
      'hasResponse': hasResponse,
      'inquiryId': inquiryId,
      'response': response != null ? response!.toJson() : null,
    };
  }
}

class InquiryResponse {
  final String adminName;
  final String adminPhone;
  final int timestamp;
  final String contactMessage;
  final String responseText;

  InquiryResponse({
    required this.adminName,
    required this.adminPhone,
    required this.timestamp,
    required this.contactMessage,
    required this.responseText,
  });

  // Factory method to create InquiryResponse object from a Map
  factory InquiryResponse.fromJson(Map<String, dynamic> json) {
    return InquiryResponse(
        adminName: json['adminName'],
        adminPhone: json['adminPhone'],
        timestamp: json['timestamp'],
        contactMessage: json['contactMessage'],
        responseText: json['responseText']);
  }

  // Convert InquiryResponse object to a Map
  Map<String, dynamic> toJson() {
    return {
      'adminName': adminName,
      'adminPhone': adminPhone,
      'timestamp': timestamp,
      'contactMessage': contactMessage,
      'responseText': responseText
    };
  }
}
