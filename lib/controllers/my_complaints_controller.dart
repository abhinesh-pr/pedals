// import 'package:flutter/material.dart';
// import 'package:pedals/viewmodels/complaint_model.dart';
// import 'package:pedals/viewmodels/my_complaint.dart';
//
// class MyComplaintViewModel extends ChangeNotifier {
//   final MyComplaintServices _myComplaintServices = MyComplaintServices();
//
//   List<MyComplaint> _complaints = [];
//   bool _isLoading = false;
//   String? _errorMessage; // Make it nullable for better control
//
//   List<MyComplaint> get complaints => _complaints;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//
//   Future<void> fetchComplaints(String userId) async {
//     _setLoading(true);
//
//     try {
//       final fetchedComplaints = await _myComplaintServices.fetchComplaints(userId);
//       _complaints = fetchedComplaints;
//       _errorMessage = null;
//       debugPrint("Fetched Complaints: $_complaints");
//     } catch (e) {
//       _errorMessage = "Failed to fetch complaints: ${e.toString()}";
//       _complaints = [];
//       debugPrint("Error fetching complaints: $_errorMessage");
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }
// }
//
//
// class MyComplaintServices {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Fetch complaints for a specific user
//   Future<List<Complaint>> fetchComplaints(String userId) async {
//     try {
//       // Fetch complaints from Firestore for the specific user
//       QuerySnapshot snapshot = await _firestore
//           .collection('complaints')
//           .where('userId', isEqualTo: userId)
//           .get();
//
//       // Convert each document snapshot into a Complaint object
//       List<Complaint> complaints = snapshot.docs.map((doc) {
//         return Complaint(
//           category: doc['category'],
//           service: doc['service'],
//           type: doc['type'],
//           complaintNumber: doc['complaintNumber'],
//           amount: doc['amount'],
//           complaintDate: doc['complaintDate'],
//           complaintOffice: doc['complaintOffice'],
//           description: doc['description'],
//           supportingDocuments: List<String>.from(doc['supportingDocuments']),
//           userId: doc['userId'],
//         );
//       }).toList();
//
//       return complaints;
//     } catch (e) {
//       throw Exception('Failed to fetch complaints: $e');
//     }
//   }
//
//   // Example: Add a new complaint (this can be used to submit complaints)
//   Future<ComplaintResponse> addComplaint(Complaint complaint) async {
//     try {
//       // Add the complaint to Firestore
//       DocumentReference docRef = await _firestore.collection('complaints').add(complaint.toJson());
//
//       return ComplaintResponse(
//         message: 'Complaint added successfully',
//         complaintId: docRef.id,
//       );
//     } catch (e) {
//       throw Exception('Failed to add complaint: $e');
//     }
//   }
// }