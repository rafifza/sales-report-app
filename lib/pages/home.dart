import 'package:flutter/material.dart';
import 'package:draggable_home/draggable_home.dart';
import 'package:tripasammkt/component/navbar.dart';
import 'package:tripasammkt/component/mininavbar.dart';
import 'package:tripasammkt/component/historynasabah.dart';
import 'package:tripasammkt/component/historyaktivitas.dart';
import 'package:tripasammkt/component/daftarprospek.dart';
import 'package:tripasammkt/component/aktivitaskedepan.dart';
import 'package:tripasammkt/component/aktivitashariini.dart';
import 'package:tripasammkt/pages/chat.dart';
import 'package:tripasammkt/pages/profil.dart';
import 'package:tripasammkt/pages/buataktivitas.dart'; // Import BuatAktivitasPage
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String karyawanNama = 'User'; // Default value for karyawan_nama
  int karyawanId = 0; // Default value for karyawan_id
  String informasiText = 'Informasi'; // Default Informasi text
  String selectedActivity = ''; // Track which activity is selected
  final ScrollController _scrollController =
      ScrollController(); // Scroll controller for DraggableHome

  @override
  void initState() {
    super.initState();
    _loadKaryawanNama(); // Load the karyawanNama and karyawanId from SharedPreferences
  }

  Future<void> _loadKaryawanNama() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      karyawanNama =
          prefs.getString('karyawan_nama') ?? 'User'; // Use 'User' if null
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      informasiText = 'Informasi';
      selectedActivity = ''; // Reset activity when navigating away
    });
  }

  // Method to handle activity selection
  void _onActivitySelected(String activity) {
    setState(() {
      if (selectedActivity == activity) {
        // If the same activity is selected again, reset to Informasi
        selectedActivity = '';
        informasiText = 'Informasi';
      } else {
        // Set the new selected activity
        selectedActivity = activity;
        switch (activity) {
          case 'Aktivitas Hari Ini':
            informasiText = 'Aktivitas Hari Ini';
            break;
          case 'Aktivitas Kedepan':
            informasiText = 'Aktivitas Kedepan';
            break;
          case 'History Aktivitas':
            informasiText = 'History Aktivitas';
            break;
          case 'History Nasabah':
            Navigator.of(context)
                .push(MaterialPageRoute(
              builder: (context) => const HistoryNasabahPage(),
            ))
                .then((_) {
              setState(() {
                selectedActivity = '';
                informasiText = 'Informasi';
              });
            });
            return;
          case 'Daftar Prospek':
            informasiText = 'Daftar Prospek';
            break;
          default:
            informasiText = 'Informasi'; // Reset if it's another activity
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navbar(
        onPageSelected: _onTabSelected,
        pages: [
          _buildHomePage(), // Home Page
          const ChatPage(), // Chat Page added here
          const Center(
              child: Text('Calculate Page')), // Placeholder for Calculate Page
          const ProfilePage(), // Profile Page
        ],
        scrollController: _scrollController, // Pass ScrollController
      ),
    );
  }

  Widget _buildHomePage() {
    return DraggableHome(
      title: const SizedBox.shrink(),
      headerWidget: _buildHeaderWidget(),
      body: [
        SingleChildScrollView(
          controller: _scrollController, // Attach ScrollController
          child: Column(
            children: [
              MiniNavbar(onActivitySelected: _onActivitySelected),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          informasiText, // Updated dynamically
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (selectedActivity == 'Aktivitas Hari Ini' ||
                            selectedActivity == 'History Aktivitas' ||
                            selectedActivity == 'Aktivitas Kedepan')
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => BuatAktivitasPage(
                                    karyawanNama: karyawanNama,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Buat Aktivitas',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildActivityDetails(selectedActivity),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderWidget() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenHeight = MediaQuery.of(context).size.height;
        double screenWidth = MediaQuery.of(context).size.width;

        return Container(
          width: double.infinity,
          color: const Color.fromARGB(255, 33, 59, 165),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: const Color.fromARGB(255, 33, 149, 243),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'Selamat datang,\n$karyawanNama!', // Use karyawanNama here
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Anda Memiliki:\n3 Aktivitas hari ini\n1 Aktivitas kedepan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Image.asset(
                                'assets/logo.png', // Update the path to your logo asset
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: 1.0,
                      child: Image.asset(
                        'assets/Artboardc.png',
                        width: screenWidth,
                        height: screenHeight * 0.14,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityDetails(String activity) {
    switch (activity) {
      case 'Aktivitas Hari Ini':
        return const AktivitasHariIni();
      case 'Aktivitas Kedepan':
        return const AktivitasKedepan();
      case 'History Aktivitas':
        return const HistoryAktivitas();
      case 'History Nasabah':
        return const SizedBox.shrink();
      case 'Daftar Prospek':
        return const DaftarProspek();
      default:
        return const Text('Select an activity to view details');
    }
  }
}
