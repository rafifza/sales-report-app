import 'dart:convert';
import 'package:logger/logger.dart'; // Import the logger package
import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import '/component/sumberdetails.dart';
import '/component/kunjungandetails.dart';
import 'package:intl/intl.dart'; // For formatting time
import '../ip.dart';
import 'package:http/http.dart' as http; // Import http package
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripasammkt/pages/home.dart';

class BuatAktivitasPage extends StatefulWidget {
  final String karyawanNama;

  const BuatAktivitasPage({
    super.key,
    required this.karyawanNama,
  });

  @override
  BuatAktivitasPageState createState() => BuatAktivitasPageState();
}

class BuatAktivitasPageState extends State<BuatAktivitasPage> {
  String? _selectedAgenda;
  String? _selectedJenis;
  String? _selectedClientType;
  String? _selectedAktivitas;
  String? _selectedSumber;

  DateTime? _selectedDate;
  final TimeOfDay _selectedTime = TimeOfDay.now(); // Initialize to current time
  final TextEditingController _timeController =
      TextEditingController(); // Controller for text field

  // Format the time for display
  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  // Initialize the time controller with the current time
  @override
  void initState() {
    super.initState();
    _timeController.text = _formatTimeOfDay(_selectedTime); // Set initial time
  }

// Initialize the controllers to null or an existing value
  final SingleSelectController<String?> _agendaController =
      SingleSelectController(null);
  final SingleSelectController<String?> _jenisController =
      SingleSelectController(null);
  final SingleSelectController<String?> _sumberController =
      SingleSelectController(null);
  final SingleSelectController<String?> _clientTypeController =
      SingleSelectController(null);
  final SingleSelectController<String?> _sumberNamaController =
      SingleSelectController(null);
  final SingleSelectController<String?> _kunjunganNamaDropdownController =
      SingleSelectController(null);
  final SingleSelectController<String?> _aktivitasDropdownController =
      SingleSelectController(null);

  // Method to check and update controller value
  void _updateControllerValue<T>(
      SingleSelectController<T?> controller, List<T> items) {
    if (controller.value != null && !items.contains(controller.value)) {
      controller.value = null; // Reset to null if value doesn't match any item
    }
  }

  final List<String> _agendaOptions = ['Prospek', 'Maintenance'];
  final List<String> _jenisOptions = ['Langsung', 'Pihak Ke-3'];
  final List<String> _sumberPihakOptions = [
    'BNI',
    'Bank lain',
    'CoInsurance',
    'Leasing',
    'Broker',
    'Agent'
  ];
  final List<String> _sumberLangsungOptions = [
    'Non Institusi',
    'Institusi',
    'Referral',
  ];
  final List<String> _clientTypeOptions = [
    'Klien Terdaftar',
    'Klien Baru',
    'Sumber & Klien Baru'
  ];
  final List<String> _clientTypeLangsungOptions = [
    'Klien Terdaftar',
    'Klien Baru',
  ];

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _kotaController = TextEditingController();
  final TextEditingController _picController = TextEditingController();
  final TextEditingController _jabatanController = TextEditingController();
  final TextEditingController _noTelpController = TextEditingController();
  final TextEditingController _alamatFormController = TextEditingController();

  Time _time = Time(hour: 11, minute: 30);

  void onTimeChanged(Time newTime) {
    setState(() {
      _time = newTime;
      // Update text field with the new time format
      _timeController.text = _formatTimeOfDay(
          TimeOfDay(hour: newTime.hour, minute: newTime.minute));
    });
  }

  final TextEditingController _kunjunganNamaController =
      TextEditingController();
  final TextEditingController _kunjunganAlamatController =
      TextEditingController();
  final TextEditingController _kunjunganKotaController =
      TextEditingController();
  final TextEditingController _kunjunganNoTelpController =
      TextEditingController();
  final TextEditingController _kunjunganEmailController =
      TextEditingController();
  final TextEditingController _kunjunganJabatanController =
      TextEditingController();

  final List<String> _aktivitasOptions = [
    'Pertemuan',
    'Rekonsiliasi',
    'Kunjungan rutin',
    'Tindak lanjut',
    'Renewal notice',
    'Penyerahan polis',
    'Penagihan premi',
    'Administrasi',
    'Zoom internal cabang',
    'On call',
  ];

  Future<void> _sendDataToApi() async {
    final url = Uri.parse('$ip/api/aktivitas');
    final Logger logger = Logger(); // Create a logger instance
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int karyawanId = prefs.getInt('karyawanid') ?? 0;
    logger.d("Karyawan ID: $karyawanId"); // Log the karyawanId

    Map<String, dynamic> requestBody = {
      'tanggal': _selectedDate?.toIso8601String(),
      'waktu': _timeController.text,
      'jenis': _selectedJenis,
      'alamat': _alamatController.text,
      'agenda': _selectedAgenda,
      'status': 'waiting',
      'aktivitas': '',
      'alamat_form': _alamatFormController.text,
      'catatan': '',
      'sumber': _selectedSumber,
      'karyawanid': karyawanId,
      'jabatan_sumber': _jabatanController.text,
      'notelp_sumber': _noTelpController.text,
      'alamat_sumber': _alamatController.text,
      'kota_sumber': _kotaController.text,
      'alamat_klien': _kunjunganAlamatController.text,
      'kota_klien': _kunjunganKotaController.text,
      'notelp_klien': _kunjunganNoTelpController.text,
      'email_klien': _kunjunganEmailController.text,
      'jabatan_klien': _kunjunganJabatanController.text,
      'pic_sumber': _picController.text,
    };

    if (_selectedClientType == 'Klien Terdaftar') {
      requestBody['nama_sumber'] = _sumberNamaController.value;
      requestBody['nama_klien'] = _kunjunganNamaDropdownController.value;
    } else if (_selectedClientType == 'Klien Baru') {
      requestBody['nama_sumber'] = _sumberNamaController.value;
      requestBody['nama_klien'] = _kunjunganNamaController.text;
    } else if (_selectedClientType == 'Sumber & Klien Baru') {
      requestBody['nama_sumber'] = _namaController.text;
      requestBody['nama_klien'] = _kunjunganNamaController.text;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (mounted) {
        // Check if the widget is still mounted
        if (response.statusCode == 201) {
          final responseData = json.decode(response.body);
          final aktivitasId = responseData['aktivitas_id'];
          final picController = responseData['pic_sumber'];
          logger.e(
              "Activity created successfully with ID: $aktivitasId, $picController");

          // Show a success dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Aktivitas berhasil dibuat.'),
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
        } else {
          logger.e("Error: ${response.body}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${response.body}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Check if the widget is still mounted
        logger.e("Failed to send data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateControllerValue(_agendaController, _agendaOptions);
    _updateControllerValue(_jenisController, _jenisOptions);
    _updateControllerValue(
        _sumberController,
        _selectedJenis == 'Langsung'
            ? _sumberLangsungOptions
            : _sumberPihakOptions);
    _updateControllerValue(
        _clientTypeController,
        _selectedJenis == 'Langsung'
            ? _clientTypeLangsungOptions
            : _clientTypeOptions);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text(
              'Buat Aktivitas',
              style:
                  TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
            ),
            backgroundColor: const Color.fromARGB(255, 33, 149, 243),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Back button functionality
              },
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            floating:
                true, // Makes the AppBar disappear on scroll down and reappear on scroll up
            pinned: false, // AppBar is not pinned
            snap: true, // AppBar snaps back into view when you scroll up
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Agenda:'),
                    CustomDropdown<String>(
                      hintText: 'Pilih Agenda',
                      items: _agendaOptions,
                      controller: _agendaController,
                      onChanged: (value) {
                        setState(() {
                          _selectedAgenda = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Jenis:'),
                    CustomDropdown<String>(
                      hintText: 'Pilih Jenis',
                      items: _jenisOptions,
                      controller: _jenisController,
                      onChanged: (value) {
                        setState(() {
                          _selectedJenis = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Sumber Bisnis:'),
                    CustomDropdown<String>(
                      hintText: 'Pilih Sumber Bisnis',
                      items: _selectedJenis == 'Langsung'
                          ? _sumberLangsungOptions
                          : _sumberPihakOptions,
                      controller: _sumberController,
                      onChanged: (value) {
                        setState(() {
                          _selectedSumber = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Tipe Klien:'),
                    CustomDropdown<String>(
                      hintText: 'Pilih Tipe Klien',
                      items: _selectedJenis == 'Langsung'
                          ? _clientTypeLangsungOptions
                          : _clientTypeOptions,
                      controller: _clientTypeController,
                      onChanged: (value) {
                        setState(() {
                          _selectedClientType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_selectedClientType != null &&
                        _selectedJenis != 'Langsung') ...[
                      SumberDetails(
                        selectedClientType: _selectedClientType,
                        namaController: _namaController,
                        alamatController: _alamatController,
                        kotaController: _kotaController,
                        picController: _picController,
                        jabatanController: _jabatanController,
                        noTelpController: _noTelpController,
                        sumberNamaController: _sumberNamaController,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_selectedClientType != null) ...[
                      KunjunganDetails(
                        kunjunganNamaController: _kunjunganNamaController,
                        kunjunganAlamatController: _kunjunganAlamatController,
                        kunjunganKotaController: _kunjunganKotaController,
                        kunjunganNoTelpController: _kunjunganNoTelpController,
                        kunjunganEmailController: _kunjunganEmailController,
                        kunjunganJabatanController: _kunjunganJabatanController,
                        kunjunganNamaDropdownController:
                            _kunjunganNamaDropdownController,
                        selectedClientType: _selectedClientType,
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text('Tanggal Kunjungan:'),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(12), // Add border radius here
                        border:
                            Border.all(color: Colors.grey), // Optional border
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3), // Adds shadow for depth
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            12), // Ensure SfDateRangePicker is clipped with the radius
                        child: SfDateRangePicker(
                          minDate: DateTime.now(),
                          onSelectionChanged:
                              (DateRangePickerSelectionChangedArgs args) {
                            setState(() {
                              _selectedDate = args.value;
                            });
                          },
                          selectionMode: DateRangePickerSelectionMode.single,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text('Waktu Kunjungan:'),
                    TextField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        hintText: 'Pilih Waktu',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () {
                            Navigator.of(context).push(
                              showPicker(
                                context: context,
                                value: _time,
                                sunrise: const TimeOfDay(hour: 6, minute: 0),
                                sunset: const TimeOfDay(hour: 18, minute: 0),
                                sunAsset: Image.asset('assets/Sun.png'),
                                moonAsset: Image.asset('assets/Moon.png'),
                                is24HrFormat: false,
                                duskSpanInMinutes: 120,
                                onChange: onTimeChanged,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _alamatFormController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Alamat',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Aktivitas dropdown, only visible after selecting Tipe Klien
                    // Aktivitas dropdown, only visible after selecting Tipe Klien
                    const Text('Aktivitas:'),
                    CustomDropdown<String>(
                      hintText: 'Pilih Aktivitas',
                      items: _aktivitasOptions,
                      controller: _aktivitasDropdownController,
                      onChanged: (value) {
                        setState(() {
                          _selectedAktivitas = value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_selectedAgenda != null &&
                                _selectedJenis != null &&
                                _selectedClientType != null &&
                                _selectedSumber != null &&
                                _selectedAktivitas != null &&
                                _selectedDate != null &&
                                _timeController.text.isNotEmpty) {
                              // Call the function to send data to the API
                              _sendDataToApi();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill all fields'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          child: const Text(
                            'Buat Aktivitas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
