import 'dart:convert';
import 'package:flutter_code/feedback.dart';
import 'package:flutter_code/reg.dart';
import 'package:flutter_code/tr.dart';
import 'package:flutter_code/userhome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const loginApp());
}

class loginApp extends StatelessWidget {
  const loginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginPage(title: 'Login'),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController uname = TextEditingController();
  TextEditingController pwd = TextEditingController();
  @override
  void initState() {
    super.initState();

    // Initialize URL and navigate after 2 seconds
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    await sh.setString("url", "https://smart-ration-python-django-flutter.onrender.com");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/img.png"),fit: BoxFit.cover),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: uname,
                                decoration: InputDecoration(
                                  labelText: "Username",
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: pwd,
                                obscureText: true,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Invalid username and password';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  prefixIcon: Icon(Icons.lock),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (!_formKey.currentState!.validate()) return;

                                    final SharedPreferences sh =
                                    await SharedPreferences.getInstance();
                                    String username = uname.text.trim();
                                    String password = pwd.text.trim();
                                    String url = sh.getString("url") ?? "";

                                    try {
                                      var response = await http.post(
                                        Uri.parse("$url/api/loginuser"),
                                        body: {
                                          'username1': username,
                                          'password': password,
                                        },
                                      );

                                      var jsonData = json.decode(response.body);
                                      String status =
                                      jsonData['usertype'].toString();

                                      if (status == "user") {
                                        String lid =
                                        jsonData['login_id'].toString();
                                        sh.setString("lid", lid);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                            const UserPage(),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Invalid username or password.',
                                            ),
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'An error occurred. Please try again. $e',
                                          ),
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: Colors.deepPurple,
                                  ),
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                              TextButton(onPressed: () async {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>RegApp()));
    }, child: Text('Register')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}
