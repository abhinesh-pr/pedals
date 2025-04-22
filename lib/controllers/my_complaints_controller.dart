import 'package:flutter/material.dart';
import 'package:pedals/viewmodels/complaint_model.dart';
import 'package:pedals/viewmodels/my_complaint.dart';


class MyComplaintViewModel extends ChangeNotifier {
  final MyComplaintServices _myComplaintServices = MyComplaintServices();
  List<MyComplaint> _complaints = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<MyComplaint> get complaints => _complaints;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchComplaints(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _complaints = await _myComplaintServices.fetchComplaints(userId);
      print("Fetched Complaints: $_complaints");
    } catch (e) {
      _errorMessage = e.toString();
      print("Error fetching complaints: $e");
      _complaints = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }