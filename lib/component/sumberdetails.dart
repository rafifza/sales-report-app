import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../../ip.dart';

class SumberDetails extends StatefulWidget {
  final String? selectedClientType;
  final TextEditingController namaController;
  final TextEditingController alamatController;
  final TextEditingController kotaController;
  final TextEditingController picController;
  final TextEditingController jabatanController;
  final TextEditingController noTelpController;
  final SingleSelectController<String?> sumberNamaController;

  const SumberDetails({
    super.key,
    required this.selectedClientType,
    required this.namaController,
    required this.alamatController,
    required this.kotaController,
    required this.picController,
    required this.jabatanController,
    required this.noTelpController,
    required this.sumberNamaController,
  });

  @override
  SumberDetailsState createState() => SumberDetailsState();
}

class SumberDetailsState extends State<SumberDetails> {
  List<String> sumberNamaOptions = [];
  bool isLoading = true;
  final Logger logger = Logger();
  @override
  void initState() {
    super.initState();
    fetchSumberNamaOptions();
  }

  Future<void> fetchSumberNamaOptions() async {
    final url = Uri.parse('$ip/api/sumber');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          sumberNamaOptions =
              data.map((item) => item['nama_sumber'] as String).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load sumber nama options');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      logger.e('Error fetching sumber names: $error');
    }
  }

  Future<void> fetchSumberDetails(String sumberNama) async {
    final url = Uri.parse('$ip/api/sumberdetails?nama=$sumberNama');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> sumberData = json.decode(response.body);

        // Clear text fields before populating them with new data
        setState(() {
          widget.alamatController.text = sumberData['alamat_sumber'] ?? '';
          widget.kotaController.text = sumberData['kota'] ?? '';
          widget.picController.text = sumberData['pic_sumber'] ?? '';
          widget.jabatanController.text = sumberData['jabatan_sumber'] ?? '';
          widget.noTelpController.text = sumberData['notelp_sumber'] ?? '';
        });
      } else {
        throw Exception(
            'Failed to load sumber details: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      logger.e('Error fetching sumber details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sumber Details:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        if (widget.selectedClientType == 'Klien Terdaftar' ||
            widget.selectedClientType == 'Klien Baru') ...[
          isLoading
              ? const CircularProgressIndicator()
              : CustomDropdown<String>.search(
                  hintText: 'Cari Nama Sumber',
                  items: sumberNamaOptions,
                  controller: widget.sumberNamaController,
                  onChanged: (value) {
                    if (value != null) {
                      // Fetch details when a name is selected
                      fetchSumberDetails(value);
                    }
                  },
                ),
        ] else ...[
          TextField(
            controller: widget.namaController,
            decoration: InputDecoration(
              labelText: 'Nama',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        TextField(
          controller: widget.alamatController,
          decoration: InputDecoration(
            labelText: 'Alamat',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
          enabled: widget.selectedClientType ==
              'Sumber & Klien Baru', // Keep it disabled
        ),
        const SizedBox(height: 10),
        TextField(
          controller: widget.kotaController,
          decoration: InputDecoration(
            labelText: 'Kota',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
          enabled: widget.selectedClientType ==
              'Sumber & Klien Baru', // Keep it disabled
        ),
        const SizedBox(height: 10),
        TextField(
          controller: widget.picController,
          decoration: InputDecoration(
            labelText: 'PIC',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
          enabled: widget.selectedClientType ==
              'Sumber & Klien Baru', // Keep it disabled
        ),
        const SizedBox(height: 10),
        TextField(
          controller: widget.jabatanController,
          decoration: InputDecoration(
            labelText: 'Jabatan',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
          enabled: widget.selectedClientType ==
              'Sumber & Klien Baru', // Keep it disabled
        ),
        const SizedBox(height: 10),
        TextField(
          controller: widget.noTelpController,
          decoration: InputDecoration(
            labelText: 'No Telp',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
          enabled: widget.selectedClientType ==
              'Sumber & Klien Baru', // Keep it disabled
        ),
      ],
    );
  }
}
