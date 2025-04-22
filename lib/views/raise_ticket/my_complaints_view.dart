import 'package:flutter/material.dart';
import 'package:pedals/controllers/my_complaints_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../viewmodels/my_complaint.dart';


class MyComplaintsPage extends StatefulWidget {
  @override
  State<MyComplaintsPage> createState() => _MyComplaintsPageState();
}

class _MyComplaintsPageState extends State<MyComplaintsPage> {
  String? userId;

  String? get raiseTicket => null;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  Future<void> _refreshData(BuildContext context) async {
    if (userId != null) {
      await Provider.of<MyComplaintViewModel>(context, listen: false).fetchComplaints(userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(

        appBar: AppBar(title: Text('My Complaints', style: TextStyle(color: Colors.white)),actions: [IconButton(onPressed: (){Navigator.of(context).pushNamed(raiseTicket!);}, icon: Icon(Icons.add))],),
        body: _buildShimmerLoading(),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => MyComplaintViewModel()..fetchComplaints(userId!),
      child: Scaffold(

        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('My Complaints', style: TextStyle(color: Colors.white)),
          actions: [IconButton(onPressed: (){Navigator.of(context).pushNamed(raiseTicket!);}, icon: Icon(Icons.add,color: Colors.white,))],
          backgroundColor: Colors.red,
          elevation: 0,
        ),
        body: Container(

          child: Consumer<MyComplaintViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return _buildShimmerLoading();
              }

              if (viewModel.errorMessage.isNotEmpty) {
                return _buildErrorState(viewModel.errorMessage);
              }

              if (viewModel.complaints.isEmpty) {
                return _buildEmptyState();
              }

              Map<String, List<MyComplaintViewModel>> groupedComplaints = _groupComplaintsByDate(viewModel.complaints);

              return RefreshIndicator(
                onRefresh: () => _refreshData(context),
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 8),
                  itemCount: groupedComplaints.keys.length,
                  itemBuilder: (context, index) {
                    String dateKey = groupedComplaints.keys.toList()[index];
                    List<MyComplaintViewModel> complaintsOnDate = groupedComplaints[dateKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateHeader(dateKey),
                        for (var complaint in complaintsOnDate)
                          _buildComplaintCard(context, complaint),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Shimmer loading state for complaints
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

  // Error state with retry button
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 50),
            SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (userId != null) {
                  Provider.of<MyComplaintViewModel>(context, listen: false).fetchComplaints(userId!);
                }
              },
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, color: Colors.grey, size: 50),
            SizedBox(height: 8),
            Text(
              'No complaints found.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (userId != null) {
                  Provider.of<MyComplaintViewModel>(context, listen: false).fetchComplaints(userId!);
                }
              },
              child: Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Group complaints by date
  Map<String, List<MyComplaintViewModel>> _groupComplaintsByDate(List<MyComplaint> complaints) {
    Map<String, List<MyComplaintViewModel>> groupedComplaints = {};

    complaints.sort((a, b) => DateTime.parse(b.complaintDate).compareTo(DateTime.parse(a.complaintDate)));

    for (var complaint in complaints) {
      String dateKey = complaint.complaintDate.substring(0, 10);
      if (groupedComplaints.containsKey(dateKey)) {
        groupedComplaints[dateKey]!.add(complaint);
      } else {
        groupedComplaints[dateKey] = [complaint];
      }
    }

    return groupedComplaints;
  }

  // Date Header with modern styling
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

  // Complaint Card with modern design
  Widget _buildComplaintCard(BuildContext context, MyComplaint complaint) {
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
            Text(complaint.category,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
            SizedBox(height: 8),
            Text(
              complaint.description,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _getStatusIcon(complaint.status),
                  color: _getStatusColor(complaint.status),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Status: ${complaint.status}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(complaint.status),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  _showTrackingDialog(context, complaint);
                },
                child: Text('Track Complaint', style: TextStyle(fontSize: 14,color: Colors.white)),
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

  // Get icon based on status
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'review':
        return Icons.pending;
      case 'accepted':
        return Icons.check_circle;
      case 'closed':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  // Get color based on status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'review':
        return Colors.yellow;
      case 'accepted':
        return Colors.blue;
      case 'closed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Dialog to show tracking information
  void _showTrackingDialog(BuildContext context, MyComplaint complaint) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,  // Background color for the dialog
          title: Text(
            'Track Complaint #${complaint.complaintNumber}',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complaint Status: ${complaint.status}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Service: ${complaint.service}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Type: ${complaint.type}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Complaint Date: ${complaint.complaintDate.substring(0, 10)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Complaint Office: ${complaint.complaintOffice}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 12),
                _buildStatusDetails(complaint.status),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusDetails(String status) {
    if (status == 'Closed') {
      return Text('This complaint has been closed.', style: TextStyle(color: Colors.green[700]));
    } else if (status == 'Rejected') {
      return Text('This complaint was rejected.', style: TextStyle(color: Colors.red[700]));
    } else if (status == 'Accepted') {
      return Text('Your complaint has been accepted and is being processed.', style: TextStyle(color: Colors.blue[700]));
    } else {
      return Text('The complaint is under review.', style: TextStyle(color: Colors.orange[700]));
    }
  }
}