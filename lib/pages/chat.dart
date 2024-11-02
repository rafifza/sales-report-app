import 'dart:io'; // Import this for Platform checks
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tripasammkt/ip.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  // Client data
  List<Map<String, String>> clients = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  // Fetch clients from the API
  Future<void> _fetchClients() async {
    const String apiUrl = '$ip/klien/getall'; // Update this with your actual IP
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          // Ensure the data is cast to the correct type
          clients = data
              .map((client) {
                return {
                  'nama': client['nama_klien'].toString(), // Cast to String
                  'no_telp':
                      client['notelp_klien'].toString(), // Cast to String
                };
              })
              .toList()
              .cast<Map<String, String>>(); // Cast to List<Map<String, String>>
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load clients';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  // Method to filter clients based on search query
  List<Map<String, String>> _filterClients(String query) {
    if (query.isEmpty) {
      return clients;
    } else {
      return clients
          .where((client) =>
              client['nama']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  final Logger logger = Logger(); // Create a logger instance
  // Method to launch WhatsApp chat
  Future<void> _launchWhatsApp(String phoneNumber) async {
    String contact = phoneNumber; // Use the actual phone number
    String text = ''; // Add any default message if needed

    // URL for Android and iOS
    String androidUrl = "whatsapp://send?phone=$contact&text=$text";
    String iosUrl = "https://wa.me/$contact?text=${Uri.encodeComponent(text)}";
    String webUrl = 'https://api.whatsapp.com/send/?phone=$contact&text=hi';

    try {
      if (Platform.isIOS) {
        if (await canLaunchUrl(Uri.parse(iosUrl))) {
          await launchUrl(Uri.parse(iosUrl));
        } else {
          await launchUrl(Uri.parse(webUrl),
              mode: LaunchMode.externalApplication);
        }
      } else {
        if (await canLaunchUrl(Uri.parse(androidUrl))) {
          await launchUrl(Uri.parse(androidUrl));
        } else {
          await launchUrl(Uri.parse(webUrl),
              mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      logger.e('Error launching WhatsApp: $e');
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredClients = _filterClients(searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat Page',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 33, 149, 243),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by client name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Show loading indicator
            if (isLoading) const Center(child: CircularProgressIndicator()),
            // Show error message if any
            if (errorMessage.isNotEmpty)
              Center(
                  child: Text(errorMessage,
                      style: const TextStyle(color: Colors.red))),
            // Show message before search
            if (!isLoading && searchQuery.isEmpty && errorMessage.isEmpty)
              const Center(
                child: Text(
                  'Search to display clients',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            // Display filtered clients
            if (!isLoading && searchQuery.isNotEmpty)
              Expanded(
                child: filteredClients.isNotEmpty
                    ? SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Nama Klien')),
                            DataColumn(label: Text('Hubungi')),
                          ],
                          rows: filteredClients.map((client) {
                            return DataRow(cells: [
                              DataCell(Text(client['nama']!)),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () {
                                    _launchWhatsApp(client['no_telp']!);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2, vertical: 4),
                                    minimumSize: const Size(80, 30),
                                  ),
                                  child: const Text(
                                    'WhatsApp',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black),
                                  ),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      )
                    : const Center(child: Text('No clients found')),
              ),
          ],
        ),
      ),
    );
  }
}
