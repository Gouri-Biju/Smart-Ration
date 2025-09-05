import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_code/login.dart';
import 'package:flutter_code/userhome.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const RegApp());
}

class RegApp extends StatelessWidget {
  const RegApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Registration',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const RegPage(title: 'User Registration Page'),
    );
  }
}

class RegPage extends StatefulWidget {
  const RegPage({super.key, required this.title});
  final String title;

  @override
  State<RegPage> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController fname = TextEditingController();
  TextEditingController lname = TextEditingController();
  TextEditingController hname = TextEditingController();
  TextEditingController ward = TextEditingController();
  TextEditingController hno = TextEditingController();
  TextEditingController place = TextEditingController();
  TextEditingController age = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController designation = TextEditingController();
  TextEditingController uname = TextEditingController();
  TextEditingController pwd = TextEditingController();

  String? selectedGender;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = prefs.getString("url") ?? "";
    if (url.isEmpty) {
      print("API URL not found");
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$url/api/userregister'),
    );
    request.fields['first_name'] = fname.text;
    request.fields['last_name'] = lname.text;
    request.fields['hname'] = hname.text;
    request.fields['ward'] = ward.text;
    request.fields['hno'] = hno.text;
    request.fields['phone'] = phone.text;
    request.fields['place'] = place.text;
    request.fields['age'] = age.text;
    request.fields['gender'] = selectedGender ?? '';
    request.fields['email'] = email.text;
    request.fields['designation'] = designation.text;
    request.fields['uname'] = uname.text;
    request.fields['password'] = pwd.text;

    try {
      var response = await request.send();
      var responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        var jsonData = json.decode(responseBody.body);
        print("Registration successful: $jsonData");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage(title: 'Login')),
        );
      } else {
        print("Failed: ${responseBody.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Required field';
    if (RegExp(r'[0-9]').hasMatch(value)) return 'Name should not contain numbers';
    return null;
  }

  String? _validateNumberOnly(String? value, String fieldName) {
    if (value == null || value.isEmpty) return 'Required field';
    if (RegExp(r'[A-Za-z]').hasMatch(value)) return '$fieldName should not contain letters';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Required field';
    if (!RegExp(r'^\d{10}$').hasMatch(value)) return 'Phone must be exactly 10 digits';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Required field';
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$%^&+=!]).{8,}$')
        .hasMatch(value)) {
      return 'Min 8 chars with upper, lower, number & special char';
    }
    return null;
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
              MaterialPageRoute(builder: (context) => const LoginPage(title: 'Login')),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Registration Form",
                style: TextStyle(fontSize: 28, color: Colors.deepPurple),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: fname,
                decoration: const InputDecoration(labelText: "First Name", border: OutlineInputBorder()),
                validator: _validateName,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: lname,
                decoration: const InputDecoration(labelText: "Last Name", border: OutlineInputBorder()),
                validator: _validateName,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: hname,
                decoration: const InputDecoration(labelText: "House Name", border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? "Required field" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: hno,
                decoration: const InputDecoration(labelText: "House Number", border: OutlineInputBorder()),
                validator: (val) => _validateNumberOnly(val, "House Number"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: ward,
                decoration: const InputDecoration(labelText: "Ward", border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? "Required field" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: place,
                decoration: const InputDecoration(labelText: "Place", border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? "Required field" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: age,
                decoration: const InputDecoration(labelText: "Age", border: OutlineInputBorder()),
                validator: (val) => _validateNumberOnly(val, "Age"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: const InputDecoration(labelText: "Gender", border: OutlineInputBorder()),
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (val) => setState(() => selectedGender = val),
                validator: (val) => val == null ? 'Select a gender' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phone,
                decoration: const InputDecoration(labelText: "Phone Number", border: OutlineInputBorder()),
                validator: _validatePhone,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? "Required field" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: designation,
                decoration: const InputDecoration(labelText: "Designation", border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? "Required field" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: uname,
                decoration: const InputDecoration(labelText: "Username", border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? "Required field" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: pwd,
                decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
                obscureText: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
