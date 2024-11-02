import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tripasammkt/pages/updateprospek.dart';

final Logger logger = Logger();

class DetailProspekPage extends StatefulWidget {
  final int prospekid;
  final String nama;
  final String kategori;
  final String tsi;
  final String estimasi;
  final String jenis;
  final String obyek;
  final String status;
  final String premi;
  final String polis;
  final String catatan;

  const DetailProspekPage({
    super.key,
    required this.prospekid,
    required this.nama,
    required this.kategori,
    required this.tsi,
    required this.estimasi,
    required this.jenis,
    required this.obyek,
    required this.status,
    required this.premi,
    required this.polis,
    required this.catatan,
  });

  @override
  DetailProspekPageState createState() => DetailProspekPageState();
}

class DetailProspekPageState extends State<DetailProspekPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: const Text(
          'Detail Prospek',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 33, 149, 243),
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
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
            ),
            child: Column(
              children: [
                _buildTable(),
                const SizedBox(height: 16.0),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildColoredButton('Update', Colors.green, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateProspekPage(
                                prospekid: widget.prospekid,
                                status: widget.status,
                                polis: widget.polis,
                              ),
                            ),
                          );
                        }),
                        _buildColoredButton(
                            'Buat Aktivitas', Colors.blue, () {}),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Table(
      border: TableBorder.all(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.black,
      ),
      columnWidths: const {
        0: FixedColumnWidth(150),
      },
      children: [
        _buildTableRow('Nama', widget.nama),
        _buildTableRow('Kategori Polis', widget.kategori),
        _buildTableRow('Jenis Asuransi', widget.jenis),
        _buildTableRow('Obyek Asuransi', widget.obyek),
        _buildTableRow('TSI', widget.tsi),
        _buildTableRow('Estimasi Premi', widget.estimasi),
        _buildTableRow('Status Prospek', widget.status),
        _buildTableRow('No Polis', widget.polis),
        _buildTableRow('Premi', widget.premi),
        _buildTableRow('Catatan', widget.catatan),
      ],
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildColoredButton(
      String title, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 144,
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
