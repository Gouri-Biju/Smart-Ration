import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_code/cart.dart';
import 'package:flutter_code/userhome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const PayApp());
}

class PayApp extends StatelessWidget {
  const PayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment Page',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PayPage(title: 'Payment', buyid: ''),
    );
  }
}

class PayPage extends StatefulWidget {
  final String title;
  final String buyid;

  const PayPage({super.key, required this.title, required this.buyid});

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController ccvController = TextEditingController();

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      expiryController.text = "${picked.month}/${picked.year}";
    }
  }

  Future<void> _makePayment() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString("url");

      var response = await http.post(
        Uri.parse("$url/api/payment"),
        body: {'bid': widget.buyid},
      );

      final result = json.decode(response.body);
      String? message = result['message'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message: $message'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context)=>UserHome(title: 'User Dashboard')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CartApp()),
            );
          },
        ),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Enter Card Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Card Holder Name
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Card Holder Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 20),

              // Card Number
              TextFormField(
                controller: numberController,
                decoration: const InputDecoration(
                  labelText: "Card Number",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 16,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter card number";
                  if (value.length != 16) return "Must be 16 digits";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Expiry Date with Picker
              TextFormField(
                controller: expiryController,
                readOnly: true,
                onTap: () => _selectExpiryDate(context),
                decoration: const InputDecoration(
                  labelText: "Expiry Date (MM/YYYY)",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Select expiry date" : null,
              ),
              const SizedBox(height: 20),

              // CCV
              TextFormField(
                controller: ccvController,
                decoration: const InputDecoration(
                  labelText: "CCV",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter CCV";
                  if (value.length != 3) return "Must be 3 digits";
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Pay Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _makePayment,
                  icon: const Icon(Icons.payment),
                  label: const Text("Pay"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
