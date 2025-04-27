import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pedals/views/raise_ticket/widgets/custom_input_fields.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pedals/views/raise_ticket/widgets/custom_dropdown.dart';


import '../../viewmodels/complaints_data.dart';
import '../../viewmodels/complaint_model.dart';
import 'complaints_confirmation_view.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  State<ComplaintPage> createState() => _ComplaintPage();
}

class _ComplaintPage extends State<ComplaintPage> {
  String? selectedCategory;
  String? selectedService;
  final TextEditingController descriptionController = TextEditingController();
  List<String> uploadedFiles = [];
  List<String> filteredServices = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    try {
      // Get the current user from Firebase Authentication
      User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        // Query Firestore to find the user document based on email (or any other unique field)
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: firebaseUser.email) // Use the email or another field
            .get();

        if (snapshot.docs.isNotEmpty) {
          // Get the first document (assuming there's only one matching document)
          DocumentSnapshot userDoc = snapshot.docs[0];

          // The custom document ID (e.g., "22ECA01") is what we need
          setState(() {
            userId = userDoc.id; // Set custom document ID as userId
          });
        } else {
          // Handle the case where no document is found
          print('No user document found for the given email.');
          setState(() {
            userId = null;
          });
        }
      } else {
        // Handle the case if no user is signed in
        setState(() {
          userId = null;
        });
      }
    } catch (e) {
      print('Error fetching userId from Firestore: $e');
      // Handle any errors that occur
    }
  }


  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );
    if (result != null) {
      setState(() {
        uploadedFiles = result.paths.map((e) => e!).toList();
      });
    }
  }

  void _handleSubmit() {
    if (selectedCategory == null ||
        selectedService == null ||
        descriptionController.text.trim().isEmpty ||
        userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final complaint = Complaint(
      category: selectedCategory!,
      service: selectedService!,
      complaintNumber: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: 0.0,
      complaintDate: DateTime.now().toIso8601String(),
      complaintOffice: "641042",
      description: descriptionController.text.trim(),
      supportingDocuments: uploadedFiles,
      userId: userId!,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComplaintConfirmationPage(
          complaintId: complaint.complaintNumber,
          category: selectedCategory!,
          service: selectedService!,
          description: descriptionController.text,
          uploadedFiles: uploadedFiles,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.redAccent,
        title: Text(
          'Raise a Complaint',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: userId == null ? _buildShimmer() : _buildForm(),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 6,
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDropdown(
            label: 'Category',
            value: selectedCategory,
            items: ComplaintData.categories,
            onChanged: (val) {
              setState(() {
                selectedCategory = val;
                selectedService = null; // Reset previously selected service
                filteredServices = ComplaintData.servicesByCategory[val] ?? [];
              });
            },
            hint: 'Select Category',
          ),
          const SizedBox(height: 16),
          if (filteredServices.isNotEmpty)
            CustomDropdown(
              label: 'Service',
              value: selectedService,
              items: filteredServices,
              onChanged: (val) {
                setState(() {
                  selectedService = val;
                });
              },
              hint: 'Select Service',
            ),
          const SizedBox(height: 16),
          CustomInputField(
            controller: descriptionController,
            label: 'Description',
            hintText: 'Describe your issue...',
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          Text(
            'Supporting Documents',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: pickFiles,
            child: DottedBorder(
              color: Colors.grey,
              dashPattern: [6, 4],
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              child: Container(
                height: 150,
                width: double.infinity,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload_outlined, size: 50, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to Upload',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (uploadedFiles.isNotEmpty)
            ...uploadedFiles.map((file) => ListTile(
              leading: const Icon(Icons.attach_file, color: Colors.redAccent),
              title: Text(
                file.split('/').last,
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            )),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Submit Complaint',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          hint: Text('Select $label'),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),

      ],
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
