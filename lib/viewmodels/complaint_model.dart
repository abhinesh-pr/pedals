// complaint_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  final String category;
  final String service;
  final String complaintNumber;
  final String complaintDate;
  final String description;
  final String complaintStatus;
  //final List<String> supportingDocuments;
  final String userId;

  Complaint({
    required this.category,
    required this.service,
    required this.complaintNumber,
    required this.complaintDate,
    required this.description,
    required this.complaintStatus,
    required this.userId,

  });


  // Convert Complaint object to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'service': service,
      'complaintDate': complaintDate,
      'description': description,
      'complaint_status':complaintStatus,
      //'supportingDocuments': supportingDocuments,
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
      complaintDate: data['complaintDate'] ?? '',
      description: data['description'] ?? '',
      complaintStatus: doc['complaint_status'] ?? '',
     // supportingDocuments: List<String>.from(data['supportingDocuments'] ?? []),
      userId: data['userId'] ?? '',
    );
  }
}
