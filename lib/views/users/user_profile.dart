
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pedals/views/authentication/auth_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  final String? useremail;
  final String userId;
  final String lastCycle;

  const ProfilePage({
    Key? key,
    required this.username,
    required this.useremail,
    required this.userId,
    required this.lastCycle,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

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

  @override
  Widget build(BuildContext context) {
    // Check if system is in dark mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Profile Page')),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 4,
              margin: EdgeInsets.only(bottom: 20.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text(
                        "${widget.username}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    ListTile(
                      leading: Icon(Icons.email),
                      title: Text(
                        "${widget.useremail}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    ListTile(
                      leading: Icon(Icons.drive_eta_rounded),
                      title: Text(
                        "${widget.userId}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    ListTile(
                      leading: Icon(Icons.wheelchair_pickup),
                      title: Text(
                        "Last Cycle : ${widget.lastCycle}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // Raise Issue Section
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                    },
                    icon: Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Icon(Icons.warning),
                    ),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text('Raise Issue'),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                      isDarkMode ? Colors.white70 : Colors.black87,
                      backgroundColor: isDarkMode
                          ? Colors.white12
                          : Colors.white54, // Text color based on theme
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
                    },
                    icon: Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Icon(Icons.file_copy),
                    ),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text('Issue Records'),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                      isDarkMode ? Colors.white70 : Colors.black87,
                      backgroundColor: isDarkMode
                          ? Colors.white12
                          : Colors.white54, // Text color based on theme
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
                      child: Icon(Icons.lock),
                    ),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text('Change Password'),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                      isDarkMode ? Colors.white70 : Colors.black87,
                      backgroundColor: isDarkMode
                          ? Colors.white12
                          : Colors.white54, // Text color based on theme
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