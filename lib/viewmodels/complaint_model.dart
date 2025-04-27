// complaint_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  final String category;
  final String service;
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
    required this.complaintNumber,
    required this.amount,
    required this.complaintDate,
    required this.complaintOffice,
    required this.description,
    required this.supportingDocuments,
    required this.userId,
  });

  // Convert Complaint object to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'service': service,
      'complaintNumber': complaintNumber,
      'amount': amount,
      'complaintDate': complaintDate,
      'complaintOffice': complaintOffice,
      'description': description,
      'supportingDocuments': supportingDocuments,
      'userId': userId,
    };
  }

  // Create Complaint object from Firestore document
  factory Complaint.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Complaint(
      category: data['category'] ?? '',
      service: data['service'] ?? '',
      complaintNumber: data['complaintNumber'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      complaintDate: data['complaintDate'] ?? '',
      complaintOffice: data['complaintOffice'] ?? '',
      description: data['description'] ?? '',
      supportingDocuments: List<String>.from(data['supportingDocuments'] ?? []),
      userId: data['userId'] ?? '',
    );
  }
}
