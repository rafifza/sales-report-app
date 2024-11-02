import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tripasammkt/ip.dart';

class HistoryNasabahPage extends StatefulWidget {
  const HistoryNasabahPage({super.key});

  @override
  HistoryNasabahPageState createState() => HistoryNasabahPageState();
}

class HistoryNasabahPageState extends State<HistoryNasabahPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  List<Map<String, dynamic>> nasabahData =
      []; // Changed to dynamic to support JSON
  bool isLoading = true; // To track loading state
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchNasabahData();
  }

  Future<void> _fetchNasabahData() async {
    const String apiUrl = '$ip/klien/getall'; // Replace with your actual IP
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          nasabahData = data
              .map((item) => {
                    'nama': item['nama_klien'],
                    'noHp': item['notelp_klien'],
                    'noPolis':
                        item['no_polis'], // Change based on your API response
                  })
              .toList();
          isLoading = false; // Stop loading when data is fetched
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data';
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

  // Method to filter nasabah based on search query
  List<Map<String, dynamic>> _filterNasabah(String query) {
    if (query.isEmpty) {
      return []; // Return an empty list when there's no search query
    } else {
      // Split the search query into words and convert to lowercase
      final queryWords = query.toLowerCase().split(RegExp(r'\s+'));
      return nasabahData.where((item) {
        final nama = item['nama']?.toLowerCase() ?? '';
        // Check if all query words are in the nama
        return queryWords.every((word) => nama.contains(word));
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtered data based on the search query
    final filteredNasabah = _filterNasabah(searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History Nasabah',
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
                hintText: 'Search by Nama',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Loading Indicator
            if (isLoading) const Center(child: CircularProgressIndicator()),
            // Show error message if any
            if (errorMessage.isNotEmpty)
              Center(
                  child:
                      Text(errorMessage, style: const TextStyle(color: Colors.red))),
            // Show message before search
            if (searchQuery.isEmpty && !isLoading && errorMessage.isEmpty)
              const Center(
                child: Text(
                  'Search to display nasabah data',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            // Display filtered nasabah data only when search query is not empty
            if (!isLoading && searchQuery.isNotEmpty)
              Expanded(
                child: filteredNasabah.isNotEmpty
                    ? ListView.builder(
                        itemCount: filteredNasabah.length,
                        itemBuilder: (context, index) {
                          final data = filteredNasabah[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: _buildHistoryCard(
                              data['nama'] ?? 'N/A',
                              data['noHp'] ?? 'N/A',
                              data['noPolis'] ?? 'N/A',
                              context,
                            ),
                          );
                        },
                      )
                    : const Center(child: Text('No nasabah found')),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
      String title, String noHp, String noPolis, BuildContext context) {
    return SizedBox(
      height: 100,
      child: InkWell(
        onTap: () {
          // Action when the card is tapped (if needed)
        },
        child: Card(
          elevation: 5,
          color: Colors.lightBlueAccent,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Column for Nama and No HP
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5), // Space between Nama and No HP
                      Text(
                        noHp,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // Right Column for No Polis
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No Polis: $noPolis',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
