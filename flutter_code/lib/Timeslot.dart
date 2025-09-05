import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_code/userhome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const SlotApp());
}

class SlotApp extends StatelessWidget {
  const SlotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slot Booking',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SlotPage(title: 'Slot Booking Page'),
    );
  }
}

class SlotPage extends StatefulWidget {
  const SlotPage({super.key, required this.title});
  final String title;

  @override
  State<SlotPage> createState() => _SlotPageState();
}

class _SlotPageState extends State<SlotPage> {
  String? message;
  final _slotKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    _loadSlotHistory();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _loadSlotHistory() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('lid');
    String? sid = sh.getString('sid');

    var response = await http.post(
      Uri.parse('$url/api/slothistory'),
      body: {'sid': sid, 'lid': lid},
    );

    final result = json.decode(response.body);

    setState(() {
      data = result['data'];
    });
  }

  Widget _buildCardSlot(dynamic slot) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.schedule, color: Colors.deepPurple),
        title: Text("${slot['date']} - ${slot['time']}"),
        subtitle: Text("Status: ${slot['status']}"),
      ),
    );
  }

  Future<void> _submitSlot() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString("url");
    String? lid = sh.getString('lid');
    String? sid = sh.getString('sid');

    if (_selectedDate != null && _selectedTime != null) {
      final formattedDate = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
      final formattedTime = "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}";

      var response = await http.post(
        Uri.parse('$url/api/userslot'),
        body: {
          'uid': lid,
          'sid': sid,
          'date': formattedDate,
          'time': formattedTime,
        },
      );
      final result = json.decode(response.body);
      message = result['message'].toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$message Slot Requested: $formattedDate at $formattedTime")),
      );

      _loadSlotHistory(); // reload after booking

      // Optionally clear selections
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both date and time.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
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
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Request for Time Slot",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 30),
            Form(
              key: _slotKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Date", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text("Choose Date"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (_selectedDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "Selected Date: ${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  const SizedBox(height: 30),
                  const Text("Select Time", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: const Text("Choose Time"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (_selectedTime != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "Selected Time: ${_selectedTime!.format(context)}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _submitSlot,
                    child: const Text("Submit Slot Request"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Divider(),
                  const Text(
                    "Your Slot History",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  data.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No slots booked yet."),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return _buildCardSlot(data[index]);
                    },
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
 