import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tripasammkt/ip.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tripasammkt/pages/home.dart';

final Logger logger = Logger();

class UpdateProspekPage extends StatefulWidget {
  final int prospekid;
  final String status;
  final String polis;

  const UpdateProspekPage({
    super.key,
    required this.prospekid,
    required this.status,
    required this.polis,
  });

  @override
  UpdateProspekPageState createState() => UpdateProspekPageState();
}

class UpdateProspekPageState extends State<UpdateProspekPage> {
  final List<String> dropdownOptions = [
    'Inforce',
    'Kalah T&C',
    'Kalah rate',
    'Tidak dapat backup',
    'Dibatalkan tertanggung',
  ];

  final SingleSelectController<String?> _statusController =
      SingleSelectController(null);

  bool showNoPolisField = false;
  bool showCatatanField = false;
  final TextEditingController _polisController = TextEditingController();
  final TextEditingController _premiController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: const Text(
          'Update Prospek',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 33, 149, 243),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildDropdownAndInput(),
              const SizedBox(height: 16.0),
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownAndInput() {
    return Column(
      children: [
        CustomDropdown<String>(
          hintText: 'Status',
          items: dropdownOptions,
          controller: _statusController,
          onChanged: (value) {
            setState(() {
              showNoPolisField = (value == 'Inforce');
              showCatatanField = (value != 'Inforce');
            });
          },
        ),
        if (showNoPolisField) ...[
          const SizedBox(height: 16.0),
          TextField(
            controller: _polisController,
            decoration: InputDecoration(
              labelText: 'No Polis',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _premiController,
            decoration: InputDecoration(
              labelText: 'Premi',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
        if (showCatatanField) ...[
          const SizedBox(height: 16.0),
          TextField(
            controller: _catatanController,
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
        ],
      ],
    );
  }

  Widget _buildUpdateButton() {
    return ElevatedButton(
      onPressed: () async {
        await _updateProspek();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: const Text(
        'Update',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Future<void> _updateProspek() async {
    String? selectedOption = _statusController.value;
    String polis = _polisController.text;
    String premi = _premiController.text;
    String catatan = _catatanController.text;

    // Logging the data
    logger.i("Updated Prospek: $polis");
    logger.i("Selected Option: $selectedOption");

    final url = Uri.parse(
      selectedOption == 'Inforce'
          ? '$ip/prospek/updatestatus'
          : '$ip/prospek/updatekalah',
    );

    final bodyData = {
      'prospekid': widget.prospekid,
      'status_prospek': selectedOption,
      'polis': polis,
    };

    // Add fields conditionally
    if (selectedOption == 'Inforce') {
      bodyData['premi'] = premi;
    } else {
      bodyData['catatan'] = catatan;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        logger.i('Prospek updated successfully');

        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Prospek updated successfully.'),
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
            },
          );
        }
      } else {
        logger
            .e('Failed to update Prospek. Status code: ${response.statusCode}');
      }
    } catch (error) {
      logger.e('Error updating Prospek: $error');
    }
  }
}
