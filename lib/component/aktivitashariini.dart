import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import http package
import 'package:intl/intl.dart';
import 'dart:convert'; // For json decoding
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import '/pages/detailaktivitas.dart'; // Import the DetailAktivitasPage
import '/ip.dart';
import 'package:logger/logger.dart';

class AktivitasHariIni extends StatefulWidget {
  const AktivitasHariIni({super.key});

  @override
  AktivitasHariIniState createState() => AktivitasHariIniState();
}

class AktivitasHariIniState extends State<AktivitasHariIni> {
  List<Map<String, dynamic>> activityData = [];
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchActivities(); // Fetch activities when the widget is initialized
  }

  Future<void> fetchActivities() async {
    final Logger logger = Logger();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? karyawanIdInt =
          prefs.getInt('karyawanid'); // Get karyawanid as an int
      String? karyawanId = karyawanIdInt?.toString();

      if (karyawanId == null) {
        throw Exception('Karyawan ID not found');
      }

      // Replace with your API endpoint for today's activities
      final response = await http
          .get(Uri.parse('$ip/api/aktivitas/today/karyawan/$karyawanId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Map response data to the required format
        setState(() {
          activityData = data.map((item) {
            // Manually parse the date using DateFormat based on the API's format
            final DateFormat apiDateFormat = DateFormat('MM/dd/yyyy');
            DateTime parsedDate = apiDateFormat.parse(item['tanggal']);
            String formattedDate = DateFormat('dd/MM/yyyy')
                .format(parsedDate); // Format to dd/MM/yyyy

            return {
              'aktivitasid': item['aktivitasid'],
              'title': item['nama_klien'], // From klien table
              'subtitle': item['nama_sumber'], // From sumber table
              'date': formattedDate, // Formatted date
              'detailTitle': item['agenda'], // From aktivitas table
              'detailSubtitle': item['jenis'], // From aktivitas table
              'time': item['waktu'], // From aktivitas table
              'catatan': item['catatan'], // Include catatan
              'notelp': item['notelp'],
              'nama_karyawan': item['nama_karyawan'],
              'alamat': item['alamat'],
            };
          }).toList();
          isLoading = false; // Set loading to false after data is fetched
        });
      } else {
        throw Exception('Failed to load activities');
      }
    } catch (e) {
      logger.e('Error fetching activities: $e'); // Use logger instead of print
      // Handle error (e.g., show a snackbar or a dialog)
      setState(() {
        isLoading = false; // Set loading to false even on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator()); // Show loading indicator
    }

    if (activityData.isEmpty) {
      // If no data, display "Tidak ada aktivitas hari ini" message
      return const Center(
        child: Text(
          'Tidak ada aktivitas hari ini',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    return _buildActivityCards(activityData, context);
  }

  Widget _buildActivityCards(
      List<Map<String, dynamic>> activityData, BuildContext context) {
    return SizedBox(
      height: 330,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: activityData.length, // Number of items in the list
              itemBuilder: (context, index) {
                // Extract the data for the current index
                final activity = activityData[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: _buildActivityCard(
                    activity['aktivitasid'] ?? '',
                    activity['title'] ?? '',
                    activity['subtitle'] ?? '',
                    activity['date'] ?? '',
                    activity['detailTitle'] ?? '',
                    activity['detailSubtitle'] ?? '',
                    activity['time'] ?? '',
                    activity['catatan'] ?? '', // Pass catatan
                    activity['notelp'] ?? '', // Pass no_telp_klien
                    activity['nama_karyawan'] ?? '',
                    activity['alamat'] ?? '',
                    context,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
      int aktivitasid,
      String title,
      String subtitle,
      String date,
      String detailTitle,
      String detailSubtitle,
      String time,
      String catatan, // Added catatan
      String notelp, // Added notelp
      String namaKaryawan,
      String alamat,
      BuildContext context) {
    return SizedBox(
      height: 100,
      child: InkWell(
        onTap: () {
          // Navigate to DetailAktivitasPage with the activity details
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetailAktivitasPage(
                aktivitasid: aktivitasid,
                title: title,
                subtitle: subtitle,
                date: date,
                detailTitle: detailTitle,
                detailSubtitle: detailSubtitle,
                time: time,
                catatan: catatan, // Pass catatan
                notelp: notelp, // Pass notelp
                namaKaryawan: namaKaryawan,
                alamat: alamat,
                fromHistory: false,
              ),
            ),
          );
        },
        child: Card(
          elevation: 5,
          color: Colors.lightBlueAccent,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      date,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      detailTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      detailSubtitle,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
