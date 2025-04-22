import 'package:flutter/material.dart';
import 'package:pedals/controllers/my_complaints_controller.dart';
import 'package:pedals/viewmodels/complaint_model.dart';
import 'package:pedals/views/raise_ticket/complaints_confirmation_view.dart';
import 'package:pedals/views/raise_ticket/widgets/custom_dropdown.dart';
import 'package:pedals/views/raise_ticket/widgets/custom_input_fields.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:shimmer/shimmer.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  String? selectedCategory;
  String? selectedService;
  String? selectedComplaintType;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  List<String> uploadedFiles = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Load the user ID from SharedPreferences
  }

  void _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  void pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );
    if (result != null) {
      setState(() {
        uploadedFiles = result.paths.map((path) => path!).toList();
      });
    }
  }

  void _handleSubmit() {
    final viewModel = Provider.of<MyComplaintViewModel>(context, listen: false);

    if (selectedCategory == null ||
        selectedService == null ||
        selectedComplaintType == null ||
        descriptionController.text.isEmpty ||
        userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields.")),
      );
      return;
    }

    // Create complaint object
    final complaint = Complaint(
      category: selectedCategory!,
      service: selectedService!,
      type: selectedComplaintType!,
      complaintNumber: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: double.tryParse(amountController.text.trim()) ?? 0.0,
      complaintDate: DateTime.now().toIso8601String(),
      complaintOffice: "641042", // Can be dynamic later
      description: descriptionController.text.trim(),
      supportingDocuments: uploadedFiles,
      userId: userId!,
    );

    // Call API
    viewModel.createComplaint(complaint).then((_) {
      if (viewModel.responseMessage != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComplaintConfirmationPage(
              complaintId: complaint.complaintNumber,
              category: selectedCategory!,
              service: selectedService!,
              type: selectedComplaintType!,
              description: descriptionController.text,
              uploadedFiles: uploadedFiles,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MyComplaintViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Create Complaint",
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: userId == null
          ? _buildShimmerLoading()
          : _buildComplaintForm(viewModel),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: List.generate(6, (index) {
          return Column(
            children: [
              Container(height: 60, color: Colors.white),
              const SizedBox(height: 16),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildComplaintForm(MyComplaintViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomDropdown(
            label: "Category",
            hint: "Select category",
            value: selectedCategory,
            items: ComplaintData.categories,
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
              });
            },
          ),
          const SizedBox(height: 16),
          CustomDropdown(
            label: "Service",
            hint: "Select service",
            value: selectedService,
            items: ComplaintData.services,
            onChanged: (value) {
              setState(() {
                selectedService = value;
              });
            },
          ),
          const SizedBox(height: 16),
          CustomDropdown(
            label: "Complaint Type",
            hint: "Select complaint type",
            value: selectedComplaintType,
            items: ComplaintData.types,
            onChanged: (value) {
              setState(() {
                selectedComplaintType = value;
              });
            },
          ),
          const SizedBox(height: 16),
          CustomInputField(
            controller: descriptionController,
            label: "Description",
            hintText: "Enter details of your complaint",
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          Text(
            "Supporting Evidence",
            style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: pickFiles,
            child: DottedBorder(
              color: Colors.grey,
              strokeWidth: 1,
              dashPattern: [6, 4],
              borderType: BorderType.RRect,
              radius: const Radius.circular(8),
              child: Container(
                width: double.infinity,
                height: 150,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, color: Colors.grey[400], size: 50),
                    const SizedBox(height: 8),
                    Text(
                      "Tap to upload supporting evidence",
                      style: GoogleFonts.lato(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (uploadedFiles.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              "Uploaded Files:",
              style: GoogleFonts.lato(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...uploadedFiles.map((file) => ListTile(
              leading: Icon(Icons.insert_drive_file, color: Colors.red),
              title: Text(
                file.split('/').last,
                style: GoogleFonts.lato(color: Colors.black),
              ),
            )),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: viewModel.isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: viewModel.isLoading
                  ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
                  : Text(
                "Submit Complaint",
                style:
                GoogleFonts.lato(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}