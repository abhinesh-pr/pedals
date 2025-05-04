import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pedals/views/authentication/auth_page.dart';
import 'package:pedals/views/raise_ticket/raise_complaint.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../raise_ticket/complaint_records.dart';

class ProfilePage extends StatefulWidget {

  const ProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? fullName;
  String? email;
  String? userId;
  String? lastCycle; // If you want to store this too later
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }



  // Controllers for the change password fields
  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();


  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Current Password'),
              ),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'New Password'),
              ),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm New Password'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                String currentPassword = _currentPasswordController.text;
                String newPassword = _newPasswordController.text;
                String confirmPassword = _confirmPasswordController.text;

                // Form validation
                if (currentPassword.isEmpty ||
                    newPassword.isEmpty ||
                    confirmPassword.isEmpty) {
                  Get.snackbar(
                    'Error',
                    'All fields are required',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else if (newPassword != confirmPassword) {
                  Get.snackbar(
                    'Error',
                    'New passwords do not match',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else if (newPassword.length < 6) {
                  Get.snackbar(
                    'Error',
                    'Password should be at least 6 characters',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }

              },
              child: Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullName') ?? 'No Name';
      email = prefs.getString('email') ?? 'No Email';
      userId = prefs.getString('userId') ?? 'No UserId';
      // lastCycle = prefs.getString('lastCycle') ?? 'No Cycle'; // If you have lastCycle too
    });
  }

  Widget _buildSquareTile(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFE5D8FB),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(2, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 6,
            spreadRadius: 1,
            offset: Offset(-2, -2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: Colors.deepPurple.shade700,
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Enables horizontal scrolling
            child: Text(
              label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis, // Truncate if text overflows
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    // Check if system is in dark mode
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
                    text: "Profile",
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 1.8, // Square tiles
              children: [
                _buildSquareTile(MdiIcons.account, fullName ?? 'No Name'),
                _buildSquareTile(MdiIcons.email, email ?? 'No Email'),
                _buildSquareTile(MdiIcons.cardAccountDetails, userId ?? 'No UserId'),
                _buildSquareTile(MdiIcons.bicycle, "Cycle_01"),
              ],
            ),

            SizedBox(height: 30.h),
            // Raise Issue Section
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.to(ComplaintPage());
                    },
                    icon: Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Icon(MdiIcons.alertOctagon,color: Colors.black87,),
                    ),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text('Raise Issue',style: TextStyle(color: Colors.black87),),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                      isDarkMode ? Colors.white70 : Colors.black87,
                      backgroundColor: Color(0xFFa873e8), // Text color based on theme
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Issue Records Section

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.to(ComplaintRecords());
                    },
                    icon: Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Icon(MdiIcons.history,color: Colors.black87,),
                    ),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text('Issue Records',style: TextStyle(color: Colors.black87),),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                      isDarkMode ? Colors.white70 : Colors.black87,
                      backgroundColor: Color(0xFFa873e8), // Text color based on theme
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
// Change Password Button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showChangePasswordDialog(
                          context); // Show change password dialog
                    },
                    icon: Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Icon(MdiIcons.keyChange,color: Colors.black87,),
                    ),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text('Change Password',style: TextStyle(color: Colors.black87),),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                      isDarkMode ? Colors.white70 : Colors.black87,
                      backgroundColor: Color(0xffa873e8), // Text color based on theme
                      padding: EdgeInsets.symmetric(
                          vertical:
                          16.0), // Add padding to increase button height
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Logout Button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Obtain the shared preferences instance
                      SharedPreferences prefs =
                      await SharedPreferences.getInstance();

                      // Clear all data in shared preferences
                      prefs.setBool('isLoggedIn', false);
                      await prefs.clear();

                      // Sign out the user
                      await FirebaseAuth.instance.signOut();

                      // Navigate back to the login screen
                      Get.off(() => AuthPage()); // Navigate to LoginPage
                    }, // Logout functionality
                    icon: Icon(Icons.logout), // Logout icon
                    label: Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      backgroundColor:
                      Color(0xFFff6666), // Text color based on theme
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}