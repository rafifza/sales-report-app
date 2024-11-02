import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tripasammkt/ip.dart';
import 'package:tripasammkt/pages/home.dart';

class Lanjutpage extends StatefulWidget {
  final int aktivitasid;
  const Lanjutpage({super.key, required this.aktivitasid});

  @override
  LanjutPageState createState() => LanjutPageState();
}

class LanjutPageState extends State<Lanjutpage> {
  final logger = Logger();
  String? selectedPerkembangan;
  String? selectedKategoriPolis;
  String? selectedProspekOption;
  final TextEditingController kategoriPolisController = TextEditingController();
  final TextEditingController obyekAsuransiController = TextEditingController();
  final TextEditingController tsiController = TextEditingController();
  final TextEditingController estimasiPremiController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();

  int? karyawanid; // To store karyawanid

  @override
  void initState() {
    super.initState();
    getKaryawanId(); // Fetch karyawanid on init
  }

  Future<void> getKaryawanId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      karyawanid = prefs.getInt(
          'karyawanid'); // Retrieve the karyawanid from SharedPreferences
    });
  }

  String formatCurrency(String value) {
    if (value.isEmpty) return '';
    final formatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0);
    return formatter.format(int.tryParse(value.replaceAll('.', '')) ?? 0);
  }

  @override
  void dispose() {
    kategoriPolisController.dispose();
    obyekAsuransiController.dispose();
    tsiController.dispose();
    estimasiPremiController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    if (karyawanid == null) {
      logger.e('karyawanid is null');
      return; // If karyawanid is null, do not proceed
    }

    final apiUrl = selectedPerkembangan == 'Tidak Prospek'
        ? '$ip/api/batalprospek'
        : '$ip/prospek/';

    String cleanTSI = tsiController.text.replaceAll(RegExp(r'[^\d]'), '');
    String cleanEstimasiPremi =
        estimasiPremiController.text.replaceAll(RegExp(r'[^\d]'), '');

    Map<String, dynamic> requestBody;

    if (selectedPerkembangan == 'Tidak Prospek') {
      requestBody = {
        'aktivitasid': widget.aktivitasid,
        'catatan': catatanController.text,
        'karyawanid': karyawanid, // Send karyawanid
      };
    } else {
      requestBody = {
        'aktivitasid': widget.aktivitasid,
        'kategori_polis': selectedKategoriPolis,
        'jenis_asuransi': selectedProspekOption,
        'kategori_polis_field': kategoriPolisController.text,
        'obyek': obyekAsuransiController.text,
        'tsi': cleanTSI,
        'estimasi_premi': cleanEstimasiPremi,
        'catatan': catatanController.text,
        'karyawanid': karyawanid, // Send karyawanid
        'status': 'Waiting'
      };
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      logger.i('Response status: ${response.statusCode}'); // Log status code

      if (response.statusCode == 201 || response.statusCode == 200) {
        logger.i('Form submitted successfully: ${response.body}');

        // Parse the response
        final responseData = jsonDecode(response.body);
        logger.i('Response data: $responseData'); // Log responseData

        // Ensure the widget is still mounted before using context
        if (!mounted) return;

        // Show success dialog
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: Text(
                  'Response: ${responseData['message'] ?? 'Prospek created successfully, aktivitas telah menjadi prospek. '}',
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MyHomePage()),
                      );
                    },
                  ),
                ],
              );
            });
      } else {
        // Log the error response and show an error dialog
        logger.e('Failed to submit form: ${response.body}');

        // Ensure the widget is still mounted before using context
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to submit form: ${response.body}'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      logger.e('Error submitting form: $e');
      // Handle error (e.g., show an error message)

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('An error occurred: $e'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Prospek',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 33, 149, 243),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDropdown(
                items: const ['Prospek', 'Tidak Prospek'],
                hintText: 'Perkembangan',
                onChanged: (newValue) {
                  setState(() {
                    selectedPerkembangan = newValue;
                    selectedKategoriPolis = null;
                    selectedProspekOption = null;
                    kategoriPolisController.clear();
                    obyekAsuransiController.clear();
                    tsiController.clear();
                    estimasiPremiController.clear();
                    catatanController.clear();
                  });
                },
              ),
              if (selectedPerkembangan == 'Prospek') ...[
                const SizedBox(height: 20),
                CustomDropdown(
                  items: const ['Baru', 'Endorsement', 'Renewal', 'Cancel'],
                  hintText: 'Kategori Polis',
                  onChanged: (newValue) {
                    setState(() {
                      selectedKategoriPolis = newValue;
                      selectedProspekOption = null;
                    });
                  },
                ),
                if (selectedKategoriPolis != null) ...[
                  const SizedBox(height: 20),
                  CustomDropdown(
                    items: const [
                      'Property',
                      'Motor Vehicle',
                      'Marine Cargo',
                      'Marine Hull',
                      'Aviation Hull',
                      'Satellite',
                      'Energy',
                      'Engineering',
                      'Liability',
                      'General Liability',
                      'Bond',
                      'Miscellaneous',
                      'Credit'
                    ],
                    hintText: 'Jenis Asuransi',
                    onChanged: (newValue) {
                      setState(() {
                        selectedProspekOption = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: kategoriPolisController,
                    decoration: InputDecoration(
                      labelText: 'Kategori Polis',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: obyekAsuransiController,
                    decoration: InputDecoration(
                      labelText: 'Obyek Asuransi',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: tsiController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        final formattedValue = formatCurrency(newValue.text);
                        return newValue.copyWith(
                          text: formattedValue,
                          selection: TextSelection.collapsed(
                              offset: formattedValue.length),
                        );
                      }),
                    ],
                    decoration: InputDecoration(
                      labelText: 'TSI (Rp.)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: estimasiPremiController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        final formattedValue = formatCurrency(newValue.text);
                        return newValue.copyWith(
                          text: formattedValue,
                          selection: TextSelection.collapsed(
                              offset: formattedValue.length),
                        );
                      }),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Estimasi Premi (Rp.)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 20),
              TextField(
                controller: catatanController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Catatan',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: submitForm,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
