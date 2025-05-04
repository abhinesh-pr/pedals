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

  const ComplaintConfirmationPage({
    super.key,
    required this.email,
    required this.complaintId,
    required this.category,
    required this.service,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE7FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 1),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: const Color(0xFFc8b6ff),
            centerTitle: true,
            title: RichText(
              text: TextSpan(
                text: "Overview",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lotties/success_lottie.json',
              height: 80,
              repeat: false,
            ),
            const SizedBox(height: 16),
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
            Text(
              "Your Complaint ID:",
              style: GoogleFonts.lato(fontSize: 16, color: Colors.black87),
            ),
            Text(
              complaintId,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:  Color(0xFF9d4edd),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Next Steps",
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildProgressStep("Submitted", true),
            _buildProgressStep("Under Review", false),
            _buildProgressStep("In Progress", false),
            _buildProgressStep("Resolved", false),
            const SizedBox(height: 24),

            // 👇 "Complaint Details" Text and Card Design
            Text(
              "Complaint Details",
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // 👇 New Card Design for Complaint Summary
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Color(0xffe2d0ff),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _cardRow("Category:", category),
                    const SizedBox(height: 12),
                    _cardRow("Service:", service),
                    const SizedBox(height: 12),
                    _cardRow("Details:", description),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Get.to(UserDashboard(uemail: email));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:  Color(0xFF9d4edd),
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
            color: isCompleted ? Colors.black87 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _cardRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title  ",
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Color(0xff353535),
            ),
          ),
        ),
      ],
    );
  }
}