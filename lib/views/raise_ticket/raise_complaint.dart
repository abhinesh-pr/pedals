import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pedals/views/raise_ticket/widgets/custom_input_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pedals/views/raise_ticket/widgets/custom_dropdown.dart';

import '../../core/utils/constants.dart';
import '../../viewmodels/complaints_data.dart';
import '../../viewmodels/complaint_model.dart';
import 'complaint_confirmation.dart';
import 'dart:io';


class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key,});

  @override
  State<ComplaintPage> createState() => _ComplaintPage();
}

class _ComplaintPage extends State<ComplaintPage> {

  double _scale = 1.0;


  String? email;

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
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? 'No Email';
      // lastCycle = prefs.getString('lastCycle') ?? 'No Cycle'; // If you have lastCycle too
    });
  }



  // Future<String?> uploadFileToGoogleDrive(String filePath, String userId) async {
  //   final dio = Dio();
  //   dio.options.headers = {'Accept': 'application/json'};
  //
  //   // Read the file as bytes and encode it to Base64
  //   final fileBytes = await File(filePath).readAsBytes();
  //   final base64File = base64Encode(fileBytes);
  //
  //   final fileName = p.basename(filePath);
  //   final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
  //
  //   try {
  //     // Send POST request to Google Apps Script
  //     final response = await dio.post(
  //       "https://script.google.com/macros/s/AKfycby-2_Hq_0Lj4QHPaHOEE9ZdnqRQ3RrJX_lL9lcytFjvNgq9dj-Ff2qh2XaP3A8Y4dDC/exec",
  //       data: {
  //         'base64': base64File,
  //         'name': fileName,
  //         'mimeType': mimeType,
  //         'userId': userId,
  //       },
  //       options: Options(
  //         responseType: ResponseType.json,
  //         validateStatus: (status) {
  //           return status! < 500; // Accept status codes below 500
  //         },
  //         followRedirects: false, // Ignore redirection
  //       ),
  //     );
  //
  //     final jsonResponse = response.data is String
  //         ? jsonDecode(response.data)
  //         : response.data;
  //
  //     if (jsonResponse['fileId'] != null) {
  //       final fileId = jsonResponse['fileId'];
  //       print("File uploaded successfully with ID: $fileId");
  //       return fileId;
  //     }
  //     else if (response.statusCode == 200) {
  //       print(response.statusCode);
  //     }
  //     else {
  //       print("Error: ${response.statusCode}");
  //       print('Error: ${jsonResponse['message']}');
  //       return null; // Return null if error message exists
  //     }
  //
  //   } catch (e) {
  //     print("Error during upload: $e");
  //     return null; // Return null if an exception occurs
  //   }
  // }





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

  Future<void> _handleSubmit() async {
    if (selectedCategory == null ||
        selectedService == null ||
        descriptionController.text.trim().isEmpty ||
        userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final complaintNumber = DateTime.now().millisecondsSinceEpoch.toString();

    final complaint = {
      'category': selectedCategory,
      'service': selectedService,
      'complaintNumber': complaintNumber,
      'complaintDate': DateTime.now().toIso8601String(),
      'description': descriptionController.text.trim(),
      //'supportingDocuments': uploadedLinks, // Uncomment if using
      'userId': userId,
      'complaint_status': 'Submitted',

    };

    // Show Lottie loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6), // ⬅️ Higher opacity
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent, // Keep the background of the Lottie container transparent
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white, // Optional: background for animation
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Lottie.asset('assets/lotties/cycle_lottie.json'),
          ),
        ),
      ),
    );

    try {
      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintNumber)
          .set(complaint);

      Navigator.pop(context); // Close loading dialog

      // Navigate to confirmation page
      Get.off(() => ComplaintConfirmationPage(
        complaintId: complaintNumber,
        category: selectedCategory!,
        service: selectedService!,
        description: descriptionController.text,
        //uploadedFiles: uploadedLinks,
        email: email,
      ));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting complaint: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Color(0xFFECE7FB),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 1),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            //backgroundColor:Color(0xFFD3C6FA),
            backgroundColor:Color(0xFFc8b6ff),
            title: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),color: Colors.black,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: "New Complaint",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
              ],
            ),
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
          SizedBox(height: 12),
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
          // Text(
          //   'Supporting Documents',
          //   style: GoogleFonts.poppins(
          //     fontSize: 14,
          //     fontWeight: FontWeight.w600,
          //   ),
          // ),
          // const SizedBox(height: 8),
          // GestureDetector(
          //   onTap: pickFiles,
          //   child: DottedBorder(
          //     color: Colors.grey,
          //     dashPattern: [6, 4],
          //     borderType: BorderType.RRect,
          //     radius: const Radius.circular(12),
          //     child: Container(
          //       height: 150,
          //       width: double.infinity,
          //       alignment: Alignment.center,
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           const Icon(Icons.cloud_upload_outlined, size: 50, color: Colors.grey),
          //           const SizedBox(height: 8),
          //           Text(
          //             'Tap to Upload',
          //             style: GoogleFonts.poppins(color: Colors.grey),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
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
          GestureDetector(
            onTapDown: (_) => setState(() => _scale = 0.97),
            onTapUp: (_) {
              setState(() => _scale = 1.0);
              _handleSubmit();
            },
            onTapCancel: () => setState(() => _scale = 1.0),
            child: AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF9d4edd),
                    elevation: 4,
                    shadowColor: Colors.grey.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Submit Complaint',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}
