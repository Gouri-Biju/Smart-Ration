import 'dart:convert';
import 'package:flutter_code/userhome.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';
import 'package:flutter_code/feedback.dart';
import 'package:flutter_code/reg.dart';

void main() {
  runApp(const statusApp());
}

class statusApp extends StatelessWidget {
  const statusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Request Status',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const statusPage(title: 'Request Status'),
    );
  }
}

class statusPage extends StatefulWidget {
  const statusPage({super.key, required this.title});
  final String title;

  @override
  State<statusPage> createState() => _statusPageState();
}

class _statusPageState extends State<statusPage> {
  String? _status;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    SharedPreferences p = await SharedPreferences.getInstance();
    String? url = p.getString("url");
    String? lid = p.getString("lid");

    final response = await http.post(
      Uri.parse("$url/api/rstatus"),
      body: {'lid': lid},
    );

    final jsonData = json.decode(response.body);

    setState(() {
      _status = jsonData['reqstatus'];
    });
  }

  Color _getStatusColor() {
    switch (_status?.toLowerCase()) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      case "pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (_status?.toLowerCase()) {
      case "approved":
        return Icons.check_circle_outline;
      case "rejected":
        return Icons.cancel_outlined;
      case "pending":
        return Icons.hourglass_top;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              "Current Application Status",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.deepPurple),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                  children: [
                    Icon(
                      _getStatusIcon(),
                      color: _getStatusColor(),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _status ?? "Loading...",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
