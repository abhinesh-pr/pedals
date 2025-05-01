import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pedals/views/users/user_dashboard.dart';


class ComplaintConfirmationPage extends StatelessWidget {
  final String? email;
  final String complaintId;
  final String category;
  final String service;
  final String description;
  //final List<String> uploadedFiles;

  const ComplaintConfirmationPage({
    super.key,
    required this.email,
    required this.complaintId,
    required this.category,
    required this.service,
    required this.description,
    //required this.uploadedFiles,
  });

  String? get mycomplaints_view => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Complaint Submitted",
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Success Icon
            Lottie.asset(
              'assets/lotties/success_lottie.json',
              height: 80,
              repeat: false,
            ),
            const SizedBox(height: 16),

            // Success Message
            Text(
              "Complaint Submitted Successfully!",
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),

            // Complaint ID
            Text(
              "Your Complaint ID:",
              style: GoogleFonts.lato(fontSize: 16, color: Colors.black87),
            ),
            Text(
              complaintId,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),

            // Progress Indicator for Next Steps
            Text(
              "Next Steps",
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildProgressStep("Complaint Received", true),
            _buildProgressStep("Under Review", false),
            _buildProgressStep("Resolution In Progress", false),
            _buildProgressStep("Resolution Completed", false),

            const SizedBox(height: 24),

            // Complaint Details Section
            Text(
              "Complaint Details",
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow("Category", category),
            _buildDetailRow("Service", service),
            const SizedBox(height: 12),

            // Description Section
            Text(
              "Description",
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.lato(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // Uploaded Files Section
            // if (uploadedFiles.isNotEmpty) ...[
            //   Text(
            //     "Uploaded Files",
            //     style: GoogleFonts.lato(
            //       fontSize: 18,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.black87,
            //     ),
            //   ),
            //   const SizedBox(height: 8),
            //   ...uploadedFiles.map((file) => ListTile(
            //     leading: Icon(Icons.insert_drive_file, color: Colors.red),
            //     title: Text(
            //       file.split('/').last,
            //       style: GoogleFonts.lato(fontSize: 16),
            //     ),
            //   )),
            //   const SizedBox(height: 16),
            // ],

            // Navigation Button
            ElevatedButton(
              onPressed: () {
                Get.to(UserDashboard(uemail: email));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Center(
                child: Text(
                  "Go to Home",
                  style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String stepName, bool isCompleted) {
    return Row(
      children: [
        Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 12),
        Text(
          stepName,
          style: GoogleFonts.lato(
            fontSize: 16,
            color: isCompleted ? Colors.black87 : Colors.grey,
          ),
        ),
      ],
    );
  }
}