import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventify/event_display.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'src/authentication.dart';

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
    '/chat',
  ];

  String _searchQuery = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _updateFirebaseIfLoggedIn();
      _isFirstLoad = false;
    }
  }

  // Need to verify
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0.0,
                        horizontal: 16.0,
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
//                     onChanged: (value) {
//                       setState(() {
                    //Search for events through their titles
                    onChanged: (value) {
                      setState(() {
                        //Convert event titles to lower case for ease of search
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
//<<<<<<< JXchanges
                SizedBox(width: 8),
                //Button to push to my events page
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/my_events');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
//=======
                      // JXchanges conflict
//                 const SizedBox(width: 8),
//                 SizedBox(
//                   width: 48,
//                   height: 52, // Match the minimum height specified in the theme
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Handle filter button press, may not be needed
//                     },
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.blue,
//                       backgroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                 SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Handle filter button press, may not be needed
//                   },
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.blue,
//                     backgroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//>>>>>>> main
                    ),
                    child: const Icon(Icons.filter_list),
                  ),
//<<<<<<< JXchanges
                  icon: Icon(Icons.my_library_books),
                  label: Text(
                    'My Events',
                  ),
//=======
//>>>>>>> main
                ),
              ],
            ),
            const SizedBox(
                height: 16), // Add some space between the row and the text
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
                    print('No data available');
                    return Center(child: CircularProgressIndicator());
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
          // context.push(body[newIndex]);
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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       backgroundColor: Colors.blue,
  //       leading: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Image.asset('assets/eventify.png'),
  //       ),
  //       actions: [
  //         Padding(
  //           padding: const EdgeInsets.only(right: 16.0),
  //           child: Consumer<ApplicationState>(
  //             builder: (context, appState, _) => AuthFunc(
  //                 loggedIn: appState.loggedIn,
  //                 signOut: () {
  //                   FirebaseAuth.instance.signOut();
  //                 }),
  //           ),
  //         ),
  //       ],
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         children: [
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: TextField(
  //                   decoration: InputDecoration(
  //                     hintText: 'Search...',
  //                     filled: true,
  //                     fillColor: Colors.white,
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(8.0),
  //                       borderSide: BorderSide.none,
  //                     ),
  //                     contentPadding: EdgeInsets.symmetric(
  //                       vertical: 0.0,
  //                       horizontal: 16.0,
  //                     ),
  //                     prefixIcon: Icon(Icons.search),
  //                   ),
  //                   //Search for events through their titles
  //                   onChanged: (value) {
  //                     setState(() {
  //                       //Convert event titles to lower case for ease of search
  //                       _searchQuery = value.toLowerCase();
  //                     });
  //                   },
  //                 ),
  //               ),
  //               SizedBox(width: 8),
  //               ElevatedButton(
  //                 onPressed: () {
  //                   // Handle filter button press, may not be needed
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   foregroundColor: Colors.blue,
  //                   backgroundColor: Colors.white,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8.0),
  //                   ),
  //                 ),
  //                 child: Icon(Icons.filter_list),
  //               ),
  //             ],
  //           ),
  //           Text(
  //             "Current Events",
  //             style: TextStyle(
  //               fontWeight: FontWeight.bold,
  //               fontSize: 15.0,
  //             ),
  //           ),

  //           //Displaying current event in the home page, by taking data from firebasestore
  //           Expanded(
  //             child: StreamBuilder<QuerySnapshot>(
  //               stream: FirebaseFirestore.instance
  //                   .collection('events')
  //                   .orderBy('timestamp', descending: true)
  //                   .snapshots(),
  //               builder: (context, snapshot) {
  //                 if (!snapshot.hasData) {
  //                   return Center(child: CircularProgressIndicator());
  //                 }
  //                 //Search for events with the similar titles
  //                 var events = snapshot.data!.docs.where((doc) {
  //                   var data = doc.data() as Map<String, dynamic>;
  //                   //Convert event titles to lower case for ease of search
  //                   var title = data['title']?.toString().toLowerCase() ?? '';
  //                   return title.contains(_searchQuery);
  //                 }).map((doc) {
  //                   var data = doc.data() as Map<String, dynamic>;
  //                   return Event_display(
  //                     title: data['title'] ?? '',
  //                     description: data['description'] ?? '',
  //                     startDate: data['startDate'] != null
  //                         ? (data['startDate'] as Timestamp)
  //                             .toDate()
  //                             .toString()
  //                             .split(' ')[0]
  //                         : '',
  //                     endDate: data['endDate'] != null
  //                         ? (data['endDate'] as Timestamp)
  //                             .toDate()
  //                             .toString()
  //                             .split(' ')[0]
  //                         : '',
  //                     startTime: data['startTime'] ?? '',
  //                     endTime: data['endTime'] ?? '',
  //                     thumbnailUrl: data['thumbnailUrl'] ?? '',
  //                     location: data['location'] ?? '',
  //                     price: data['price'] ?? '',
  //                   );
  //                 }).toList();
  //                 return ListView(
  //                   children: events,
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //     bottomNavigationBar: BottomNavigationBar(
  //       currentIndex: _currentIndex,
  //       onTap: (int newIndex) {
  //         context.push(body[newIndex]);
  //       },
  //       items: [
  //         BottomNavigationBarItem(
  //           label: 'Home',
  //           icon: Icon(Icons.home),
  //         ),
  //         BottomNavigationBarItem(
  //           label: 'Add Event',
  //           icon: Icon(Icons.add),
  //         ),
  //         BottomNavigationBarItem(
  //           label: 'Calendar',
  //           icon: Icon(Icons.calendar_month),
  //         ),
  //         BottomNavigationBarItem(
  //           label: 'Chat',
  //           icon: Icon(Icons.chat_bubble),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         leading: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Image.asset('assets/eventify.png'),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16.0),
//             child: Consumer<ApplicationState>(
//               builder: (context, appState, _) => AuthFunc(
//                   loggedIn: appState.loggedIn,
//                   signOut: () {
//                     FirebaseAuth.instance.signOut();
//                   }),
//             ),
//           ),
//         ],
//       ),
//       body: FutureBuilder(
//         // Newly added
//         future: _updateFirebaseIfLoggedIn(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         decoration: InputDecoration(
//                           hintText: 'Search...',
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8.0),
//                             borderSide: BorderSide.none,
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                             vertical: 0.0,
//                             horizontal: 16.0,
//                           ),
//                           prefixIcon: const Icon(Icons.search),
//                         ), //Search for events through their titles
//                         onChanged: (value) {
//                           setState(() {
//                             //Convert event titles to lower case for ease of search
//                             _searchQuery = value.toLowerCase();
//                           });
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton(
//                       onPressed: () {
//                         // Handle filter button press
//                       },
//                       style: ElevatedButton.styleFrom(
//                         foregroundColor: Colors.blue,
//                         backgroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                       ),
//                       child: const Icon(Icons.filter_list),
//                     ),
//                   ],
//                 ),
//                 const Text(
//                   "Current Events",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15.0,
//                   ),
//                 ),

//                 //Displaying current event in the home page, by taking data from firebasestore
//                 Expanded(
//                   child: StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection('events')
//                         .orderBy('timestamp', descending: true)
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData) {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                       var events = snapshot.data!.docs.map((doc) {
//                         var data = doc.data() as Map<String, dynamic>;
//                         //Convert event titles to lower case for ease of search
//                         var title =
//                             data['title']?.toString().toLowerCase() ?? '';
//                         return title.contains(_searchQuery);
//                       }).map((doc) {
//                         var data = doc.data() as Map<String, dynamic>;
//                         return Event_display(
//                           title: data['title'] ?? '',
//                           description: data['description'] ?? '',
//                           startDate: data['startDate'] != null
//                               ? (data['startDate'] as Timestamp)
//                                   .toDate()
//                                   .toString()
//                                   .split(' ')[0]
//                               : '',
//                           endDate: data['endDate'] != null
//                               ? (data['endDate'] as Timestamp)
//                                   .toDate()
//                                   .toString()
//                                   .split(' ')[0]
//                               : '',
//                           startTime: data['startTime'] ?? '',
//                           endTime: data['endTime'] ?? '',
//                           thumbnailUrl: data['thumbnailUrl'] ?? '',
//                           location: data['location'] ?? '',
//                           price: data['price'] ?? '',
//                         );
//                       }).toList();
//                       return ListView(
//                         children: events,
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (int newIndex) {
//           context.push(body[newIndex]);
//         },
//         items: const [
//           BottomNavigationBarItem(
//             label: 'Home',
//             icon: Icon(Icons.home),
//           ),
//           BottomNavigationBarItem(
//             label: 'Add Event',
//             icon: Icon(Icons.add),
//           ),
//           BottomNavigationBarItem(
//             label: 'Chat',
//             icon: Icon(Icons.chat_bubble),
//           ),
//         ],
//       ),
//     );
//   }
// }