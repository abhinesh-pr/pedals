import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
    // Simulate userId loading (you can load from SharedPreferences or other source)
    setState(() {
      userId = "123"; // Example user ID
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('My Complaints', style: TextStyle(color: Colors.white)), actions: [IconButton(onPressed: (){Navigator.of(context).pushNamed(raiseTicket!);}, icon: Icon(Icons.add))],),
        body: _buildShimmerLoading(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('My Complaints', style: TextStyle(color: Colors.white)),
        actions: [IconButton(onPressed: (){Navigator.of(context).pushNamed(raiseTicket!);}, icon: Icon(Icons.add,color: Colors.white,))],
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: Container(
        child: ListView.builder(
          padding: EdgeInsets.only(top: 8),
          itemCount: 3,  // Just for demonstration, replace with real data
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateHeader("2025-04-27"), // Example date
                _buildComplaintCard(context),
              ],
            );
          },
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
  Widget _buildComplaintCard(BuildContext context) {
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
            Text('Complaint Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
            SizedBox(height: 8),
            Text('Complaint Description', style: TextStyle(color: Colors.grey, fontSize: 14)),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.pending, color: Colors.yellow, size: 20),
                SizedBox(width: 8),
                Text(
                  'Status: Under Review',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.yellow, fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  _showTrackingDialog(context);
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

  // Dialog to show tracking information
  void _showTrackingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,  // Background color for the dialog
          title: Text(
            'Track Complaint #123',  // Example complaint number
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
                  'Complaint Status: Under Review',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Service: Service Name',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Complaint Date: 2025-04-27',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Complaint Office: Office Name',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 12),
                _buildStatusDetails('review'),
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
