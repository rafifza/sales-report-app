import 'package:flutter/material.dart';
import 'package:tripasammkt/pages/batalaktivitas.dart';
import 'package:tripasammkt/pages/lanjutpage.dart';
import 'package:tripasammkt/pages/reschedule.dart';

class DetailAktivitasPage extends StatelessWidget {
  final int aktivitasid;
  final String title;
  final String subtitle;
  final String date;
  final String detailTitle;
  final String detailSubtitle;
  final String time;
  final String catatan; // New parameter for catatan
  final String notelp; // New parameter for notelp
  final String namaKaryawan; // New parameter for nama_karyawan
  final String alamat;
  final bool fromHistory;

  const DetailAktivitasPage({
    super.key,
    required this.aktivitasid,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.detailTitle,
    required this.detailSubtitle,
    required this.time,
    required this.catatan, // Pass the new parameter
    required this.notelp, // Pass the new parameter
    required this.namaKaryawan, // Pass the new parameter
    required this.alamat,
    this.fromHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: const Text(
          'Detail Aktivitas',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor:
            const Color.fromARGB(255, 33, 149, 243), // New AppBar color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Go back to the previous page
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0), // Rounded corners
              color: Colors.white, // Background color for the table
            ),
            child: Column(
              children: [
                Table(
                  border: TableBorder.all(
                    borderRadius:
                        BorderRadius.circular(12.0), // Rounded borders
                    color: Colors.black, // Border color
                  ),
                  columnWidths: const {
                    0: FixedColumnWidth(
                        150), // Adjust width of the first column
                  },
                  children: [
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Agenda',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(detailTitle),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Jenis',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(detailSubtitle),
                        ),
                      ],
                    ),
                    if (subtitle != '')
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Sumber Bisnis',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(subtitle),
                          ),
                        ],
                      ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Nama',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(title),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Tanggal',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(date),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Jam',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(time),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No Telp',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(notelp), // Display notelp
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Alamat',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(alamat), // Display notelp
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('PIC',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              namaKaryawan), // Display nama_karyawan as PIC
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Catatan',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(catatan), // Display catatan
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                    height: 16.0), // Spacing between table and buttons
                if (!fromHistory) // Only show buttons if not from HistoryAktivitas
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildColoredButton('Lanjutkan', Colors.green, () {
                            // Navigate to ProgressPage and pass aktivitasid
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Lanjutpage(aktivitasid: aktivitasid),
                              ),
                            );
                          }),
                          _buildColoredButton('Batalkan', Colors.red, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BatalAktivitasPage(
                                    aktivitasid: aktivitasid),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16.0), // Spacing between rows
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildColoredButton('Lokasi', Colors.blue, () {
                            // Handle "Lokasi" button press
                          }),
                          _buildColoredButton('Re-Schedule', Colors.orange, () {
                            // Navigate to ReschedulePage with aktivitasId, waktu, and tanggal
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReschedulePage(
                                  aktivitasid: aktivitasid,
                                  waktu: time,
                                  tanggal: date,
                                ),
                              ),
                            );
                          }),
                        ],
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

  Widget _buildColoredButton(
      String title, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 140, // Set a fixed width for uniform button sizes
      height: 36, // Set a fixed height for uniform button sizes
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // Set the button color
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)), // Rounded corners
        ),
        child: Text(
          title,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
