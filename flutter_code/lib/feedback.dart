import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_code/userhome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const FeedbackPage());
}

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feedback App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Feedback(title: 'Feedback Page'),
    );
  }
}

class Feedback extends StatefulWidget {
  const Feedback({super.key, required this.title});
  final String title;

  @override
  State<Feedback> createState() => _FeedbackState();
}

class _FeedbackState extends State<Feedback> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController fd = TextEditingController();
  List<dynamic> _feedbacks = [];
  String? _url;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _url = prefs.getString("url");

    final response = await http.post(Uri.parse("$_url/api/view_feedback"));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'true') {
        setState(() {
          _feedbacks = result['data'];
        });
      }
    }
  }

  Widget _buildFeedbackCard(dynamic feedback) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          feedback['customer_name'] ?? "Anonymous",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              feedback['feedback_text'] ?? '',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  feedback['feedback_date'] ?? "",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserHome(title: 'User Dashboard')),
            );
          },
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Share Your Feedback",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: fd,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Feedback';
                        }
                        return null;
                      },
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Your feedback here",
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text("Send Feedback"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          final SharedPreferences sh =
                          await SharedPreferences.getInstance();
                          String id = sh.getString("lid") ?? "";
                          String feedbackText = fd.text.trim();
                          String url = sh.getString("url") ?? "";

                          try {
                            var response = await http.post(
                              Uri.parse("$url/api/userfeedback"),
                              body: {
                                'feedback': feedbackText,
                                'lid': id,
                              },
                            );

                            var jsonData = json.decode(response.body);

                            if (jsonData['status'] == 'success') {
                              fd.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Feedback sent successfully")),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const FeedbackPage()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Failed to send feedback")),
                              );
                            }
                          } catch (e) {
                            print("Error: $e");
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _feedbacks.isEmpty
                ? const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text("No feedbacks found",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _feedbacks.length,
              itemBuilder: (context, index) {
                return _buildFeedbackCard(_feedbacks[index]);
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
