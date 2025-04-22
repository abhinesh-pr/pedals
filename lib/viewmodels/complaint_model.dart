// lib/models/complaint.dart
class Complaint {
  final String category;
  final String service;
  final String type;
  final String complaintNumber;
  final double amount;
  final String complaintDate;
  final String complaintOffice;
  final String description;
  final List<String> supportingDocuments;
  final String userId;

  Complaint({
    required this.category,
    required this.service,
    required this.type,
    required this.complaintNumber,
    required this.amount,
    required this.complaintDate,
    required this.complaintOffice,
    required this.description,
    required this.supportingDocuments,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
    "category": category,
    "service": service,
    "type": type,
    "complaintNumber": complaintNumber,
    "amount": amount,
    "complaintDate": complaintDate,
    "complaintOffice": complaintOffice,
    "description": description,
    "supportingDocuments": supportingDocuments,
    "userId": userId,
  };
}

class ComplaintResponse {
  final String message;
  final String complaintId;

  ComplaintResponse({
    required this.message,
    required this.complaintId,
  });

  factory ComplaintResponse.fromJson(Map<String, dynamic> json) {
    return ComplaintResponse(
      message: json['message'],
      complaintId: json['complaintId'],
    );
  }
}