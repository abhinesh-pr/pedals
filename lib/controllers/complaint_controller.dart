
import 'package:flutter/material.dart';

class ComplaintViewModel extends ChangeNotifier {
  final ComplaintService _complaintService = ComplaintService();

  bool isLoading = false;
  String? responseMessage;
  String? complaintId;

  Future<void> createComplaint(ComplaintViewModel complaint) async {
    isLoading = true;
    responseMessage = null;
    complaintId = null;
    notifyListeners();

    try {
      final response = await _complaintService.createComplaint(complaint);
      responseMessage = response.message;
      complaintId = response.complaintId;
    } catch (e) {
      responseMessage = "Error: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class ComplaintService {
  createComplaint(ComplaintViewModel complaint) {}
}

