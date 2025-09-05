import 'package:flutter/material.dart';
import 'package:flutter_code/cart.dart';
import 'package:flutter_code/feedback.dart';
import 'package:flutter_code/login.dart';
import 'package:flutter_code/notification.dart';
import 'package:flutter_code/orderhistory.dart';
import 'package:flutter_code/products.dart';
import 'package:flutter_code/rationcarddetails.dart';
import 'package:flutter_code/requestrationcard.dart';
import 'package:flutter_code/rstatus.dart';
import 'package:flutter_code/shopkeeper.dart';

void main() {
  runApp(const UserPage());
}

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const UserHome(title: 'User Dashboard'),
    );
  }
}

class UserHome extends StatefulWidget {
  const UserHome({super.key, required this.title});

  final String title;

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage(title: 'User Dashboard')),
            );
          },
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Welcome to Ration Management",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCard(context, "Request Card", Icons.credit_card, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => reqApp()));
                  }),
                  _buildCard(context, "Check Status", Icons.info_outline, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => statusApp()));
                  }),
                  _buildCard(context, "View Card", Icons.card_membership, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CardApp()));
                  }),
                  _buildCard(context, "Shops", Icons.store, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ShopApp()));
                  }),
                  _buildCard(context, "Products", Icons.shopping_bag, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductApp()));
                  }),
                  _buildCard(context, "Cart", Icons.shopping_cart, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CartApp()));
                  }),
                  _buildCard(context, "Order History", Icons.reorder, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryApp()));
                  }),
                  _buildCard(context, "Notifications", Icons.notifications, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationApp()));
                  }),
                  _buildCard(context, "Feedback", Icons.feedback, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackPage()));
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: Colors.deepPurple),
                const SizedBox(height: 10),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
