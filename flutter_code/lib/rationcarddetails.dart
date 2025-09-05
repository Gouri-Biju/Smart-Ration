import 'dart:convert';
import 'package:flutter_code/userhome.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_code/feedback.dart';
import 'package:flutter_code/reg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

void main() {
  runApp(const CardApp());
}

class CardApp extends StatelessWidget {
  const CardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ration Card Details',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CardPage(title: 'Ration Card Info'),
    );
  }
}

class CardPage extends StatefulWidget {
  const CardPage({super.key, required this.title});
  final String title;

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  String? _cardnumber;
  String? _issuedate;
  String? _cardtype;

  @override
  void initState() {
    super.initState();
    _loaddetails();
  }

  Future<void> _loaddetails() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? _url = sh.getString("url");
    String? lid = sh.getString("lid");

    var response = await http.post(
      Uri.parse("$_url/api/rdetails"),
      body: {'lid': lid},
    );

    final JsonData = json.decode(response.body);

    setState(() {
      _cardnumber = JsonData['cn'];
      _issuedate = JsonData['issued_date'];
      _cardtype = JsonData['card_type'];
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
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              "Ration Card Details",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.deepPurple),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.credit_card, color: Colors.deepPurple),
                    title: Text("Card Number"),
                    subtitle: Text(_cardnumber ?? "Loading..."),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.category, color: Colors.deepPurple),
                    title: Text("Card Type"),
                    subtitle: Text(_cardtype ?? "Loading..."),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.date_range, color: Colors.deepPurple),
                    title: Text("Issue Date"),
                    subtitle: Text(_issuedate ?? "Loading..."),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
