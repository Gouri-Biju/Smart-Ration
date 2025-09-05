import 'package:flutter/material.dart';
import 'package:flutter_code/Timeslot.dart';
import 'package:flutter_code/feedback.dart';
import 'package:flutter_code/rating.dart';
import 'package:flutter_code/reg.dart';
import 'package:flutter_code/userhome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login.dart';

void main() {
  runApp(const ShopApp());
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shops',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Available Shops'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> _shops = [];

  @override
  void initState() {
    super.initState();
    _loadshops();
  }

  Future<void> _loadshops() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString("url");
    var response = await http.post(Uri.parse("$url/api/usershops"));
    final result = json.decode(response.body);
    setState(() {
      _shops = result['data'];
    });
  }

  Widget _buildShopCard(dynamic shop) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.storefront, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    shop['shopname'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(shop['place']),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.phone, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(shop['phone']),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    String? rsid = shop['id'].toString();
                    SharedPreferences sh = await SharedPreferences.getInstance();
                    sh.setString('rsid', rsid);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RateApp()));
                  },
                  icon: const Icon(Icons.star, color: Colors.white,),
                  label: const Text("Rate Shop", style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final SharedPreferences sh = await SharedPreferences.getInstance();
                    String? sid = shop['id'].toString();
                    sh.setString('sid', sid);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SlotApp()));
                  },
                  icon: const Icon(Icons.calendar_month, color: Colors.white,),
                  label: const Text('Book Slot', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
      body: RefreshIndicator(
        onRefresh: _loadshops,
        child: _shops.isEmpty
            ? const Center(
          child: Text(
            "No shops found",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: _shops.length,
          itemBuilder: (context, index) {
            return _buildShopCard(_shops[index]);
          },
        ),
      ),
    );
  }
}
