import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pedals/views/raise_ticket/raise_complaint.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ComplaintRecords extends StatefulWidget {
  const ComplaintRecords({super.key,});

  @override
  State<ComplaintRecords> createState() => _ComplaintRecords();
}

class _ComplaintRecords extends State<ComplaintRecords> {
  String? userId;
  String? email;
  String? fullName;
  List<Map<String, dynamic>> userComplaints = [];
  bool isLoading = true;

  // Change the raiseTicket to a valid route (Example: 'raise_ticket')
  final String raiseTicketRoute = '/raise_ticket';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // Load user data from SharedPreferences and then load complaints
  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullName') ?? 'No Name';
      email = prefs.getString('email') ?? 'No Email';
      userId = prefs.getString('userId') ?? 'No UserId';
    });

    // After loading the user data, load complaints
    if (userId != null) {
      _loadComplaints();
    }
  }

  Future<void> _loadComplaints() async {
    if (userId == null) return;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .where('userId', isEqualTo: userId)
          .orderBy('complaintDate', descending: true)
          .get();

      setState(() {
        userComplaints = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching complaints: $e');
      setState(() {
        isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('My Complaints', style: TextStyle(color: Colors.white)), actions: [
          IconButton(onPressed: (){Get.to(ComplaintPage());}, icon: Icon(Icons.add))
        ],),
        body: _buildShimmerLoading(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('My Complaints', style: TextStyle(color: Colors.white)),
        actions: [IconButton(onPressed: (){Get.to(ComplaintPage());}, icon: Icon(Icons.add, color: Colors.white,))],
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: isLoading
          ? _buildShimmerLoading()
          : userComplaints.isEmpty
          ? Center(child: Text('No complaints found.'))
          : ListView.builder(
        padding: EdgeInsets.only(top: 8),
        itemCount: userComplaints.length,
        itemBuilder: (context, index) {
          final complaint = userComplaints[index];
          final complaintDate = complaint['complaintDate'] ?? '';
          final dateOnly = complaintDate.toString().split('T')[0];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(dateOnly),
              _buildComplaintCard(context, complaint),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      children: [
        SizedBox(height: 16),
        _buildShimmerLine(),
        SizedBox(height: 16),
        _buildShimmerBlock(),
        SizedBox(height: 16),
        _buildShimmerBlock(),
      ],
    );
  }

  Widget _buildShimmerLine() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.5),
      highlightColor: Colors.white.withOpacity(0.2),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        height: 20,
        color: Colors.white,
      ),
    );
  }

  Widget _buildShimmerBlock() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.5),
      highlightColor: Colors.white.withOpacity(0.2),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        height: 100,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDateHeader(String dateKey) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 18, color: Colors.red),
          SizedBox(width: 8),
          Text(
            dateKey,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(BuildContext context, Map<String, dynamic> complaint) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(complaint['category'] ?? 'Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
            SizedBox(height: 8),
            Text(complaint['description'] ?? 'No description', style: TextStyle(color: Colors.grey, fontSize: 14)),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.pending, color: Colors.purple, size: 20),
                SizedBox(width: 8),
                Text(
                  'Status: ${complaint['complaint_status'] ?? 'Unknown'}',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.purpleAccent, fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  _showTrackingBottomSheet(context, complaint);
                },
                child: Text('Track Complaint', style: TextStyle(fontSize: 14, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrackingBottomSheet(BuildContext context, Map<String, dynamic> complaint) {
    String complaintStatus = "Resolved"; // Dynamically change based on data

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.6,
          expand: false,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 4,
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Text(
                    'Track Complaint',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _infoLine("Category", "${complaint['category'] ?? 'Unknown'}"),
                  _infoLine("Service", "${complaint['service'] ?? 'Unknown'}"),
                  _infoLine("Complaint No.", "${complaint['complaintNumber'] ?? 'Unknown'}"),
                  _infoLine("Description", "${complaint['description'] ?? 'Unknown'}"),
                  _infoLine("Complaint Date", "${complaint['complaintDate'] ?? 'Unknown'}"),
                  if (complaintStatus == "Resolved") ...[
                    _infoLine("Resolved By", "${complaint['resolved_by'] ?? 'Unknown'}"),
                  ],
                  SizedBox(height: 24),
                  Divider(thickness: 1.2),
                  Text(
                    "Status Timeline",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  SizedBox(height: 20),
                  _buildTimeline(complaintStatus),
                  // if (complaintStatus == "Resolved") ...[
                  //   SizedBox(height: 20),
                  //   Row(
                  //     children: [
                  //       Icon(Icons.verified_user, color: Colors.green),
                  //       SizedBox(width: 8),
                  //       Expanded(
                  //         child: Text(
                  //           "Resolved by: $resolvedBy",
                  //           style: TextStyle(
                  //             fontSize: 15,
                  //             fontWeight: FontWeight.w600,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   )
                  // ],
                  SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.red),
                      label: Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimeline(String currentStatus) {
    final steps = ["Submitted", "Under Review", "In Progress", "Resolved"];
    final stepColors = {
      "Submitted": Colors.yellow,
      "Under Review": Colors.blue,
      "In Progress": Colors.orange,
      "Resolved": Colors.green,
    };

    int currentIndex = steps.indexOf(currentStatus);

    return Column(
      children: List.generate(steps.length, (index) {
        String step = steps[index];
        bool isActive = index <= currentIndex;
        bool isLast = index == steps.length - 1;

        Color activeColor = stepColors[step] ?? Colors.grey;
        Color nextActiveColor = !isLast ? stepColors[steps[index + 1]] ?? Colors.grey : Colors.grey;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                // Dot
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? activeColor : Colors.grey[300],
                  ),
                ),
                // Gradient Line
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: index < currentIndex
                          ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          activeColor,
                          nextActiveColor,
                        ],
                      )
                          : null,
                      color: index >= currentIndex ? Colors.grey[300] : null,
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                step,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }



  Widget _infoLine(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: Text(title, style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 5, child: Text(value, style: TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }


}
