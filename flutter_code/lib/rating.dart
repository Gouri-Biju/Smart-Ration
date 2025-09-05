import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_code/userhome.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const RateApp());
}

class RateApp extends StatelessWidget {
  const RateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const RatePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class RatePage extends StatefulWidget {
  const RatePage({super.key, required this.title});

  final String title;

  @override
  State<RatePage> createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  final _formRateKey = GlobalKey<FormState>();
  TextEditingController _rateController = TextEditingController();
  String? rated;
  String? date;
  double _currentRating = 3;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadrating();
  }

  Future<void> _loadrating() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? uid = sh.getString('lid');
    String? url = sh.getString('url');
    String? sid = sh.getString('rsid');
    var response = await http.post(
      Uri.parse("$url/api/viewrate"),
      body: {'uid': uid, 'sid': sid},
    );
    final result = json.decode(response.body);
    print("Response body: ${response.body}");

    setState(() {
      rated = result['rated'].toString();
      date = result['date'].toString();
    }
    );

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Add Rating",
              style: TextStyle(fontSize: 30, color: Colors.deepPurple),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formRateKey,
                child: Column(
                  children: [
                    RatingBar.builder(
                      initialRating: _currentRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) =>
                          Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _currentRating = rating;
                          _rateController.text = rating.toInt().toString();
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        SharedPreferences sh =
                            await SharedPreferences.getInstance();
                        String? url = sh.getString('url');
                        String? rsid = sh.getString('rsid');
                        String? lid = sh.getString('lid');
                        String rating = _rateController.text.trim();
                        String? m;

                        print("URL: $url");
                        print("RSID: $rsid");
                        print("LID: $lid");
                        print("RATING: $rating");

                        var response = await http.post(
                          Uri.parse("$url/api/rate"),
                          body: {
                            'rsid': rsid ?? '',
                            'lid': lid ?? '',
                            'rating': rating,
                          },
                        );
                        final result=await json.decode(response.body);
                        m =result['message'];
                        if (response.statusCode == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("$m"),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Failed to submit rating.")),
                          );
                        }
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>RateApp()));
                      },
                      child: Text("Submit"),
                    ),
                    Text('rated $rated star on $date'),
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
