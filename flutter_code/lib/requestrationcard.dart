import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_code/feedback.dart';
import 'package:flutter_code/reg.dart';
import 'package:flutter_code/userhome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

void main() {
  runApp(const reqApp());
}

class reqApp extends StatelessWidget {
  const reqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Request Message',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ReqPage(title: 'Request Result'),
    );
  }
}

class ReqPage extends StatefulWidget {
  const ReqPage({super.key, required this.title});
  final String title;

  @override
  State<ReqPage> createState() => _ReqPageState();
}

class _ReqPageState extends State<ReqPage> {
  String? message;

  @override
  void initState() {
    super.initState();
    _loadReq();
  }

  Future<void> _loadReq() async {
    SharedPreferences p = await SharedPreferences.getInstance();
    String? _url = p.getString("url");
    String? lid = p.getString("lid");

    final response = await http.post(
      Uri.parse("$_url/api/req"),
      body: {'lid': lid},
    );

    var result = json.decode(response.body);
    String? msg = result['message'];

    setState(() {
      message = msg ?? "No message available.";
    });
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
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              "Request Feedback",
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
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.message_outlined,
                      color: Colors.deepPurple,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message ?? "Loading...",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
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
