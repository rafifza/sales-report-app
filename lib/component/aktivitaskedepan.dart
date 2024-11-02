import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert'; // For json decoding
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import '/pages/detailaktivitas.dart'; // Import the DetailAktivitasPage
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import '/ip.dart';
import 'package:logger/logger.dart';

class AktivitasKedepan extends StatefulWidget {
  const AktivitasKedepan({super.key});

  @override
  AktivitasKedepanState createState() => AktivitasKedepanState();
}

class AktivitasKedepanState extends State<AktivitasKedepan> {
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

      // Replace with your API endpoint
      final response = await http
          .get(Uri.parse('$ip/api/aktivitas/future/karyawan/$karyawanId'));

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
              'nama_klien': item['nama_klien'], // From klien table
              'nama_sumber': item['nama_sumber'], // From sumber table
              'tanggal': formattedDate, // Formatted date
              'agenda': item['agenda'], // From aktivitas table
              'jenis': item['jenis'], // From aktivitas table
              'waktu': item['waktu'], // From aktivitas table
              'catatan': item['catatan'],
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
                    activity['nama_klien'] ?? '',
                    activity['nama_sumber'] ?? '',
                    activity['tanggal'] ?? '',
                    activity['agenda'] ?? '',
                    activity['jenis'] ?? '',
                    activity['waktu'] ?? '',
                    activity['catatan'] ?? '',
                    activity['notelp'] ?? '',
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
      String namaKlien,
      String namaSumber,
      String tanggal,
      String agenda,
      String jenis,
      String waktu,
      String catatan,
      String notelp,
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
                title: namaKlien,
                subtitle: namaSumber,
                date: tanggal,
                detailTitle: agenda,
                detailSubtitle: jenis,
                time: waktu,
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
                      namaKlien,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      namaSumber,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      tanggal,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      agenda,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      jenis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      waktu,
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
