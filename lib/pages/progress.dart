import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class ProgressPage extends StatefulWidget {
  final int aktivitasid;
  const ProgressPage({super.key, required this.aktivitasid});

  @override
  ProgressPageState createState() => ProgressPageState();
}

class ProgressPageState extends State<ProgressPage> {
  final logger = Logger();
  String? selectedOption; // Track the selected option
  String? selectedProspekOption; // Track the second dropdown option for Prospek
  final TextEditingController alasanController =
      TextEditingController(); // Controller for alasan text field
  final TextEditingController kategoriPolisController = TextEditingController();
  final TextEditingController obyekAsuransiController = TextEditingController();
  final TextEditingController tsiController = TextEditingController();
  final TextEditingController estimasiPremiController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();

  // Format the input for numbers with "Rp." and thousand separator
  String formatCurrency(String value) {
    if (value.isEmpty) return '';
    final formatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0);
    return formatter.format(int.tryParse(value.replaceAll('.', '')) ?? 0);
  }

  @override
  void dispose() {
    alasanController.dispose();
    kategoriPolisController.dispose();
    obyekAsuransiController.dispose();
    tsiController.dispose();
    estimasiPremiController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if the submit button should be visible
    bool isFormComplete = false;
    if (selectedOption == 'Prospek' &&
        selectedProspekOption != null &&
        kategoriPolisController.text.isNotEmpty &&
        obyekAsuransiController.text.isNotEmpty &&
        tsiController.text.isNotEmpty &&
        estimasiPremiController.text.isNotEmpty &&
        catatanController.text.isNotEmpty) {
      isFormComplete = true; // Show button if Prospek is fully completed
    } else if (selectedOption == 'Batal' && alasanController.text.isNotEmpty) {
      isFormComplete = true; // Show button if Batal and alasan is filled
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Progress',
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
              // Custom Dropdown for Prospek or Batal
              CustomDropdown(
                items: const ['Prospek', 'Batal'], // First dropdown options
                hintText: 'Pilih Status',
                onChanged: (newValue) {
                  setState(() {
                    selectedOption = newValue;
                    selectedProspekOption = null;
                    alasanController.clear();
                    kategoriPolisController.clear();
                    obyekAsuransiController.clear();
                    tsiController.clear();
                    estimasiPremiController.clear();
                    catatanController.clear();
                  });
                },
              ),
              const SizedBox(height: 20),

              // Conditionally render the second dropdown or alasan text field
              if (selectedOption == 'Prospek')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

                    // Additional TextFields for Prospek
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
                        // Add thousands separator automatically
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
                        // Add thousands separator automatically
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
                    const SizedBox(height: 20),

                    TextField(
                      controller: catatanController,
                      maxLines: 4,
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
                )
              else if (selectedOption == 'Batal')
                TextField(
                  controller: alasanController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Alasan Pembatalan',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Conditionally render the submit button if the form is complete
              if (isFormComplete)
                SizedBox(
                  width: double.infinity, // Make the button full width
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle the form submission
                      if (selectedOption == 'Prospek') {
                        logger.e(
                            'Submit progress: $selectedOption - $selectedProspekOption');
                        logger.e(
                            'Kategori Polis: ${kategoriPolisController.text}');
                        logger.e(
                            'Obyek Asuransi: ${obyekAsuransiController.text}');
                        logger.e('TSI: ${tsiController.text}');
                        logger.e(
                            'Estimasi Premi: ${estimasiPremiController.text}');
                        logger.e('Catatan: ${catatanController.text}');
                      } else if (selectedOption == 'Batal' &&
                          alasanController.text.isNotEmpty) {
                        logger.e(
                            'Submit progress: $selectedOption - ${alasanController.text}');
                      }
                    },
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
