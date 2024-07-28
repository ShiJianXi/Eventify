import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventify/view/widgets/event_display.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import 'authentication.dart';
import 'package:eventify/service/firebase_firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _searchQuery = '';
  bool _isFirstLoad = true;

  List<String> body = const [
    '/',
    '/event_listing',
    '/calendar',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _updateFirebaseIfLoggedIn();
      _isFirstLoad = false;
    }
  }

  Future<void> _updateFirebaseIfLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, perform Firebase update
      await FirebaseFirestoreService.updateUserData(
        {'lastActive': DateTime.now()},
      );
    } else {
      // User is not logged in, handle accordingly
      print('User is not logged in');
    }
  }

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
          IconButton(
            icon: const Icon(Icons.chat_bubble),
            onPressed: () {
              context.push('/chat');
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Consumer<ApplicationState>(
              builder: (context, appState, _) => AuthFunc(
                loggedIn: appState.loggedIn,
                signOut: () {
                  FirebaseAuth.instance.signOut();
                },
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Flexible(
                  flex: 8,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0.0,
                        horizontal: 16.0,
                      ),
                      prefixIcon: const Icon(Icons.search),
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
                const SizedBox(width: 8),
                Flexible(
                  flex: 5,
                  child: SizedBox(
                    height:
                        52, // Match the minimum height specified in the theme
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/my_events');
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: 1, // Scale down the icon size
                            child: const Icon(Icons.my_library_books),
                          ),
                          Transform.scale(
                            scale: 1, // Scale down the text size
                            child: const Text(' My Events'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
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
                    // print('No data available');
                    return const Center(child: CircularProgressIndicator());
                  }
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
                          ? (data['startDate'] as Timestamp)
                              .toDate()
                              .toString()
                              .split(' ')[0]
                          : '',
                      endDate: data['endDate'] != null
                          ? (data['endDate'] as Timestamp)
                              .toDate()
                              .toString()
                              .split(' ')[0]
                          : '',
                      startTime: data['startTime'] ?? '',
                      endTime: data['endTime'] ?? '',
                      thumbnailUrl: data['thumbnailUrl'] ?? '',
                      location: data['location'] ?? '',
                      price: data['price'] ?? '',
                      userId: data['userId'] ?? '',
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
          setState(() {
            _currentIndex = newIndex;
          });
          context.push(body[newIndex]);
        },
        items: const [
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
