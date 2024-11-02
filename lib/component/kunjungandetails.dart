import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:http/http.dart' as http;
import '../../ip.dart';
import 'package:logger/logger.dart';

class KunjunganDetails extends StatefulWidget {
  final String? selectedClientType;
  final TextEditingController kunjunganNamaController;
  final TextEditingController kunjunganAlamatController;
  final TextEditingController kunjunganKotaController;
  final TextEditingController kunjunganNoTelpController;
  final TextEditingController kunjunganEmailController;
  final TextEditingController kunjunganJabatanController;
  final SingleSelectController<String?> kunjunganNamaDropdownController;

  const KunjunganDetails({
    super.key,
    required this.selectedClientType,
    required this.kunjunganNamaController,
    required this.kunjunganAlamatController,
    required this.kunjunganKotaController,
    required this.kunjunganNoTelpController,
    required this.kunjunganEmailController,
    required this.kunjunganNamaDropdownController,
    required this.kunjunganJabatanController,
  });

  @override
  KunjunganDetailsState createState() => KunjunganDetailsState();
}

class KunjunganDetailsState extends State<KunjunganDetails> {
  List<String> kunjunganNamaOptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchKunjunganNamaOptions(); // Fetch kunjungan options on init
  }

  // Fetch kunjungan names from API
  Future<void> fetchKunjunganNamaOptions() async {
    final url = Uri.parse('$ip/klien/getall');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          kunjunganNamaOptions =
              data.map((item) => item['nama_klien'] as String).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load kunjungan nama options');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  final Logger logger = Logger();

  // Fetch details of a selected kunjungan from API
  Future<void> fetchKunjunganDetails(String kunjunganNama) async {
    final url = Uri.parse('$ip/klien/getdetails?nama=$kunjunganNama');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> kunjunganData = json.decode(response.body);

        setState(() {
          widget.kunjunganAlamatController.text =
              kunjunganData['alamat_klien'] ?? '';
          widget.kunjunganKotaController.text = kunjunganData['kota'] ?? '';
          widget.kunjunganNoTelpController.text =
              kunjunganData['notelp_klien'] ?? '';
          widget.kunjunganEmailController.text =
              kunjunganData['email_klien'] ?? '';
          widget.kunjunganJabatanController.text =
              kunjunganData['jabatan_klien'] ?? '';
        });

        logger.i('Kunjungan details fetched successfully.');
      } else {
        logger.e(
            'Failed to load kunjungan details. Status code: ${response.statusCode}');
        throw Exception('Failed to load kunjungan details');
      }
    } catch (error) {
      logger.e('Error fetching kunjungan details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Client Details',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        // Conditional Dropdown or TextField based on selectedClientType
        if (widget.selectedClientType == 'Klien Terdaftar') ...[
          isLoading
              ? const CircularProgressIndicator()
              : CustomDropdown<String>.search(
                  hintText: 'Cari Nama Kunjungan',
                  items: kunjunganNamaOptions,
                  controller: widget.kunjunganNamaDropdownController,
                  onChanged: (value) {
                    if (value != null) {
                      // Fetch details when a kunjungan is selected
                      fetchKunjunganDetails(value);
                    }
                  },
                ),
        ] else ...[
          TextField(
            controller: widget.kunjunganNamaController,
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

        // Alamat Field
        TextField(
          controller: widget.kunjunganAlamatController,
          decoration: InputDecoration(
            labelText: 'Alamat',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
          enabled: widget.selectedClientType == 'Sumber & Klien Baru' ||
              widget.selectedClientType ==
                  'Klien Baru', // Keep it disabled until data is fetched
        ),
        const SizedBox(height: 10),

        // Kota Field
        TextField(
          controller: widget.kunjunganKotaController,
          decoration: InputDecoration(
            labelText: 'Kota',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
          enabled: widget.selectedClientType == 'Sumber & Klien Baru' ||
              widget.selectedClientType ==
                  'Klien Baru', // Keep it disabled until data is fetched
        ),
        const SizedBox(height: 10),

        // No Telp Field
        TextField(
          controller: widget.kunjunganNoTelpController,
          decoration: InputDecoration(
            labelText: 'No Telp',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
          enabled: widget.selectedClientType == 'Sumber & Klien Baru' ||
              widget.selectedClientType ==
                  'Klien Baru', // Keep it disabled until data is fetched
        ),
        const SizedBox(height: 10),

        // Email Field
        TextField(
          controller: widget.kunjunganEmailController,
          decoration: InputDecoration(
            labelText: 'Email',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
          enabled: widget.selectedClientType == 'Sumber & Klien Baru' ||
              widget.selectedClientType ==
                  'Klien Baru', // Keep it disabled until data is fetched
        ),
        const SizedBox(height: 10),

        //Jabatan Field
        TextField(
          controller: widget.kunjunganJabatanController,
          decoration: InputDecoration(
            labelText: 'Jabatan',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
          enabled: widget.selectedClientType == 'Sumber & Klien Baru' ||
              widget.selectedClientType ==
                  'Klien Baru', // Keep it disabled until data is fetched
        ),
      ],
    );
  }
}
