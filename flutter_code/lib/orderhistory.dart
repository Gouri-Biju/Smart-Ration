import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_code/userhome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const HistoryApp());
}

class HistoryApp extends StatelessWidget {
  const HistoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order History',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HistoryPage(title: 'Order History'),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.title});

  final String title;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> historyData = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('lid');

    if (url == null || lid == null) {
      print('URL or LID not set in SharedPreferences');
      return;
    }

    try {
      var response = await http.post(
        Uri.parse('$url/api/orderhistory'),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          historyData = result['data'];
        });
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserHome(title: 'User Dashboard')),
            );
          },
        ),
      ),
      body: historyData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: historyData.length,
        itemBuilder: (context, index) {
          var item = historyData[index];
          String date = item['date'];
          String total = item['total'].toString();
          List products = item['products_bought'];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🗓️ Date: $date",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text("💰 Total Amount: ₹$total",
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 8),
                  const Text("🛒 Products Bought:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 5),
                  ...products.map((product) => Text("• $product")).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
