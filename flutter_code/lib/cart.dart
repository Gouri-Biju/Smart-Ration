import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_code/feedback.dart';
import 'package:flutter_code/paymentpage.dart';
import 'package:flutter_code/reg.dart';
import 'package:flutter_code/userhome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

void main() {
  runApp(const CartApp());
}

class CartApp extends StatelessWidget {
  const CartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CartPage(title: 'My Cart'),
    );
  }
}

class CartPage extends StatefulWidget {
  const CartPage({super.key, required this.title});
  final String title;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> data = [];
  String? bid = '';
  String? total;

  @override
  void initState() {
    super.initState();
    _loadcart();
  }

  Future<void> _loadcart() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('lid');

    if (url != null && lid != null) {
      var response = await http.post(
        Uri.parse('$url/api/userviewcart'),
        body: {'lid': lid},
      );

      final jsonData = json.decode(response.body);
      setState(() {
        data = jsonData['data'] ?? [];
        bid = jsonData['bid'].toString();
        total=jsonData['total'].toString();
      });
    }
  }

  Widget _buildCartCard(dynamic cart) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.deepPurple.shade100,
          child: const Icon(Icons.shopping_cart, color: Colors.deepPurple),
        ),
        title: Text(
          cart['pname'] ?? 'No Name',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              const Text(
                "Quantity: ",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(cart['quantity'].toString() ?? '0'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
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
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const Text(
                'My Cart',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),
              data.isEmpty
                  ? const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Cart is empty",
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return _buildCartCard(data[index]);
                },
              ),
              const SizedBox(height: 30),
              data.isEmpty
              ? Text("Add somethong to cart to proceed")
              :
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PayPage(buyid: bid.toString(), title: ''),
                      ),
                    );
                  },
                  icon: const Icon(Icons.payment),
                  label: Text("Pay ${total}"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
