import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this for SharedPreferences
import 'login.dart'; // Import your login page
import 'changepassword.dart'; // Import your ChangePasswordPage

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    // Delete access token from SharedPreferences or any other storage
    final prefs = await SharedPreferences.getInstance();
    await prefs
        .remove('access_token'); // Adjust key based on your implementation

    // Check if the widget is still mounted before navigating
    if (!context.mounted) return;

    // Navigate to the login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<Map<String, dynamic>> _getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'karyawan_nama': prefs.getString('karyawan_nama') ?? 'N/A',
      'notelp': prefs.getString('notelp') ?? 'N/A',
      'cabang': prefs.getString('cabang') ?? 'N/A',
      'karyawanid': prefs.getInt('karyawanid') ?? 0, // Changed to int
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 33, 149, 243),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserDetails(), // Fetch user details
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userDetails = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile photo placeholder on the left side
                    Container(
                      width: 126,
                      height: 126,
                      decoration: BoxDecoration(
                        color: Colors.grey[300], // Placeholder color
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person, // Placeholder icon
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Right side details (Nama, NoTelp, Cabang, ID)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: 'Nama: \n', // Text before the colon (bold)
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                              children: [
                                TextSpan(
                                  text: userDetails['karyawan_nama']!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text.rich(
                            TextSpan(
                              text: 'No Telp: \n',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                              children: [
                                TextSpan(
                                  text: userDetails['notelp']!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text.rich(
                            TextSpan(
                              text: 'Cabang: \n',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                              children: [
                                TextSpan(
                                  text: userDetails['cabang']!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text.rich(
                            TextSpan(
                              text: 'ID Karyawan: \n',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                              children: [
                                TextSpan(
                                  text: userDetails['karyawanid']
                                      .toString(), // Cast to String for display
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // Change Password and Logout buttons near the navbar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final karyawanid = userDetails['karyawanid']
                          as int; // Retrieve karyawanid from userDetails
                      // Navigate to ChangePasswordPage and pass karyawanid
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePasswordPage(
                            karyawanid: karyawanid, // Pass karyawanId directly
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                    ),
                    child: const Text('Change Password',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight
                                .w600)), // Add a child for the button text
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _logout(context); // Call the logout function
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                    ),
                    child: const Text('Logout',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 80), // Spacing at the bottom
              ],
            ),
          );
        },
      ),
    );
  }
}
