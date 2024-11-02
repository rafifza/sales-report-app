import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripasammkt/ip.dart';
import 'package:intl/intl.dart';
import 'package:tripasammkt/pages/detailprospek.dart';
import 'package:logger/logger.dart';

class DaftarProspek extends StatefulWidget {
  const DaftarProspek({super.key});

  @override
  DaftarProspekState createState() => DaftarProspekState();
}

class DaftarProspekState extends State<DaftarProspek> {
  final Logger logger = Logger();
  List<Map<String, dynamic>> activityData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProspekData();
  }

  String formatCurrency(int amount) {
    final formatCurrency = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return formatCurrency.format(amount);
  }

  Future<void> fetchProspekData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? karyawanid = prefs.getInt('karyawanid');

      if (karyawanid == null) {
        throw Exception('karyawanid is not available');
      }

      final response = await http.get(Uri.parse('$ip/prospek/$karyawanid'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          activityData = data.map((item) {
            return {
              'nama': item['nama_klien'] ?? '',
              'kategori': item['kategori_polis'] ?? '',
              'tsi': formatCurrency(item['tsi'] ?? 0),
              'estimasi': formatCurrency(item['estimasi_premi'] ?? 0),
              'jenis': item['jenis_asuransi'] ?? '',
              'obyek': item['obyek'] ?? '',
              'prospekid': item['prospekid'],
              'status': item['status_prospek'] ?? '',
              'premi': formatCurrency(item['premi'] ?? 0),
              'polis': item['polis'] ?? '',
              'catatan': item['catatan'] ?? '',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        logger
            .e('Failed to load data with status code: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      logger.e('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : _buildActivityCards(activityData, context);
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
              itemCount: activityData.length,
              itemBuilder: (context, index) {
                final activity = activityData[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: _buildActivityCard(
                    activity['prospekid'] ?? 0,
                    activity['nama'] ?? '',
                    activity['kategori'] ?? '',
                    activity['tsi'] ?? '',
                    activity['estimasi'] ?? '',
                    activity['jenis'] ?? '',
                    activity['obyek'] ?? '',
                    activity['status'] ?? '',
                    activity['premi'] ?? '',
                    activity['polis'] ?? '',
                    activity['catatan'] ?? '',
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
      int prospekid,
      String nama,
      String kategori,
      String tsi,
      String estimasi,
      String jenis,
      String obyek,
      String status,
      String premi,
      String polis,
      String catatan,
      BuildContext context) {
    return SizedBox(
      height: 100,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetailProspekPage(
                prospekid: prospekid,
                jenis: jenis,
                nama: nama,
                kategori: kategori,
                tsi: tsi,
                estimasi: estimasi,
                obyek: obyek,
                status: status,
                premi: premi,
                polis: polis,
                catatan: catatan,
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      kategori,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      tsi,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      status,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      jenis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      estimasi,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
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
