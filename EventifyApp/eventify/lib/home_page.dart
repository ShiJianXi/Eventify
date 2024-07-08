// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

//import 'package:eventify/event_listing_page.dart';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventify/event_display.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
//import 'package:eventify/event_details_page.dart';
import 'app_state.dart'; // new
// import 'guest_book.dart';
import 'src/authentication.dart'; // new
// import 'src/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _currentIndex = 0;

  List<String> body = const [
    '/',
    '/event_listing',
    '/calendar',
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/eventify.png'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Consumer<ApplicationState>(
              builder: (context, appState, _) => AuthFunc(
                  loggedIn: appState.loggedIn,
                  signOut: () {
                    FirebaseAuth.instance.signOut();
                  }),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0.0,
                        horizontal: 16.0,
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                    //Search for events through their titles
                    onChanged: (value) {
                      setState(() {
                        //Convert event titles to lower case for ease of search
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Handle filter button press, may not be needed
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Icon(Icons.filter_list),
                ),
              ],
            ),
            Text(
              "Current Events",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
            ),
            ),

            //Displaying current event in the home page, by taking data from firebasestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    //this print is for debugging, remove before production
                    print('No data available');
                    return Center(child: CircularProgressIndicator());
                  }
                  //this print is for debugging, remove before production
                  print('data fetched successfully');
                  //Search for events with the similar titles
                  var events = snapshot.data!.docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    //Convert event titles to lower case for ease of search
                    var title = data['title']?.toString().toLowerCase() ?? '';
                    return title.contains(_searchQuery);
                  }).map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return Event_display(
                      title: data['title'] ?? '',
                      description: data['description'] ?? '',
                      startDate: data['startDate'] != null
                          ? (data['startDate'] as Timestamp).toDate().toString().split(' ')[0]
                          : '',
                      endDate: data['endDate'] != null
                          ? (data['endDate'] as Timestamp).toDate().toString().split(' ')[0]
                          : '',
                      startTime: data['startTime'] ?? '',
                      endTime: data['endTime'] ?? '',
                      thumbnailUrl: data['thumbnailUrl'] ?? '',
                      location: data['location'] ?? '',
                      price: data['price'] ?? '',
                    );
                  }).toList();
                  return ListView(
                    children: events,
                  );
                },
              ),
            ),
          ],
        ),
      ),
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          context.push(body[newIndex]);
        },
        items: [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Add Event',
            icon: Icon(Icons.add),
          ),
          BottomNavigationBarItem(
            label: 'Calendar',
            icon: Icon(Icons.calendar_month),
          ),
        ],
      ),
    );
  }
}
