import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart'; // Syncfusion DatePicker
import 'package:tripasammkt/pages/home.dart';
import '../../ip.dart'; // import your IP configuration

class ReschedulePage extends StatefulWidget {
  final int aktivitasid;
  final String waktu;
  final String tanggal;

  const ReschedulePage({
    super.key,
    required this.aktivitasid,
    required this.waktu,
    required this.tanggal,
  });

  @override
  State<ReschedulePage> createState() => _ReschedulePageState();
}

class _ReschedulePageState extends State<ReschedulePage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = false;
  final TextEditingController catatanController = TextEditingController();

  // Format the selected date and time
  String get formattedDate {
    if (selectedDate != null) {
      return DateFormat('dd-MM-yyyy').format(selectedDate!.toLocal());
    } else {
      return widget.tanggal; // If no date selected, use existing date
    }
  }

  String formattedTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  // Show time picker
  void _selectTime(BuildContext context) {
    Navigator.of(context).push(
      showPicker(
        context: context,
        value: Time(hour: 11, minute: 30),
        onChange: (Time newTime) {
          setState(() {
            selectedTime =
                TimeOfDay(hour: newTime.hour, minute: newTime.minute);
          });
        },
      ),
    );
  }

  // Function to send the reschedule data to the API
  Future<void> rescheduleAktivitas() async {
    final Logger logger = Logger();
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$ip/api/reschedule');
    final Map<String, dynamic> rescheduleData = {
      'aktivitasid': widget.aktivitasid,
      'tanggal': formattedDate, // Use the updated formattedDate getter
      'waktu':
          selectedTime != null ? formattedTime(selectedTime!) : widget.waktu,
      'catatan': catatanController.text,
    };

    // Debug statements
    logger.e('Sending date: $formattedDate');
    logger.e(
        'Sending time: ${selectedTime != null ? formattedTime(selectedTime!) : widget.waktu}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(rescheduleData),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        logger.i(responseData);
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to reschedule: ${response.statusCode}')),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Reschedule successful!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MyHomePage()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: const Text(
          'Reschedule Aktivitas',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Tanggal:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(12), // Add borderRadius here
                border: Border.all(color: Colors.grey), // Optional border
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    12), // Ensure the content is clipped with the radius
                child: SfDateRangePicker(
                  initialSelectedDate: DateTime.now(),
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                    setState(() {
                      selectedDate = args.value;
                    });
                  },
                  selectionMode: DateRangePickerSelectionMode.single,
                  showNavigationArrow: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedTime != null
                          ? formattedTime(selectedTime!)
                          : widget.waktu,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.access_time),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: catatanController,
              decoration: InputDecoration(
                labelText: 'Catatan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Enter your notes here...',
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : rescheduleAktivitas,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Reschedule',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
