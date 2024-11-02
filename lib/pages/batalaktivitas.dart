import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tripasammkt/pages/home.dart';
import '../../ip.dart'; // Adjust the path if needed

class BatalAktivitasPage extends StatefulWidget {
  final int aktivitasid;

  const BatalAktivitasPage({super.key, required this.aktivitasid});

  @override
  BatalAktivitasPageState createState() => BatalAktivitasPageState();
}

class BatalAktivitasPageState extends State<BatalAktivitasPage> {
  final TextEditingController _catatanController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pembatalkan Aktivitas",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 33, 149, 243),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildTextField(
                controller: _catatanController,
                labelText: "Masukkan alasan pembatalan",
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _cancelAktivitas();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Batalkan Aktivitas",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue, width: 1.0),
        ),
      ),
    );
  }

  Future<void> _cancelAktivitas() async {
    String catatan = _catatanController.text;

    // Construct the cancellation request
    final url = Uri.parse('$ip/api/batal');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'aktivitasid': widget.aktivitasid,
        'catatan': catatan,
      }),
    );

    if (response.statusCode == 200) {
      if (!mounted) return;

      // Show the alert dialog and navigate to MyHomePage after clicking OK
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sukses'),
            content: const Text('Aktivitas berhasil dibatalkan'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true)
                      .pushReplacement(MaterialPageRoute(
                    builder: (context) => const MyHomePage(),
                  ));
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Show an error message if the request fails
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal membatalkan aktivitas")),
      );
    }
  }
}
