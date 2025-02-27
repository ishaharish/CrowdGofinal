import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class UserDashboard extends StatefulWidget {
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String? _selectedEvent;
  final _registerIdController = TextEditingController();

  Future<void> _registerForEvent() async {
    if (_selectedEvent != null && _registerIdController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('registrations').add({
          'eventId': _selectedEvent,
          'registerId': _registerIdController.text,
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'registeredAt': DateTime.now(),
        });
        _registerIdController.clear();
        setState(() {
          _selectedEvent = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('events').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                List<DropdownMenuItem<String>> eventItems = snapshot.data!.docs
                    .map((event) => DropdownMenuItem(
                          value: event.id,
                          child: Text(event['name']),
                        ))
                    .toList();

                return DropdownButtonFormField<String>(
                  value: _selectedEvent,
                  decoration: InputDecoration(
                    labelText: 'Select Event',
                    border: OutlineInputBorder(),
                  ),
                  items: eventItems,
                  onChanged: (value) {
                    setState(() {
                      _selectedEvent = value;
                    });
                  },
                );
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _registerIdController,
              decoration: InputDecoration(
                labelText: 'Register ID',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _registerForEvent,
              child: Text('Register for Event'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 