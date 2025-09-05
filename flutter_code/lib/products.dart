import 'package:flutter/material.dart';
import 'package:flutter_code/feedback.dart';
import 'package:flutter_code/reg.dart';
import 'package:flutter_code/userhome.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'login.dart';

void main() {
  runApp(const ProductApp());
}

class ProductApp extends StatelessWidget {
  const ProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ProductPage(title: 'Products'),
    );
  }
}

class ProductPage extends StatefulWidget {
  const ProductPage({super.key, required this.title});
  final String title;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString("url");
    String? lid = sh.getString("lid");

    var response = await http.post(
      Uri.parse("$url/api/pdetails"),
      body: {'lid': lid},
    );

    final result = json.decode(response.body);
    setState(() {
      products = result['data'];
    });
  }

  Widget _buildProductCard(dynamic product) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  child: Icon(Icons.local_drink, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    product['product_name'] ?? 'Product name',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text("Quantity in units: ",
                    style: TextStyle(fontSize: 15)),
                const SizedBox(width: 10),
                Text(
                  product['KiloLiter'] ?? "Not Found",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 60,),
                Text('Amount: ${product['amount']}', style: TextStyle(color: Colors.black)),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  SharedPreferences sh =
                  await SharedPreferences.getInstance();
                  String? url = sh.getString('url');
                  String? lid = sh.getString('lid');

                  var response = await http.post(
                    Uri.parse('$url/api/cart'),
                    body: {
                      'p': product['id'].toString(),
                      'lid': lid.toString(),
                    },
                  );

                  final result = json.decode(response.body);
                  String? message = result['message'];
                  String? status = result['status'];

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Server: $message',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor:
                      status == "kkkkkkk" ? Colors.red : Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart, color: Colors.white,),
                label: const Text("Add to Cart", style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
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
        title: Text(widget.title),
      ),
      body: products.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "No products found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(products[index]);
        },
      ),
    );
  }
}
