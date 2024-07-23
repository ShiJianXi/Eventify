// chat.dart
import 'package:eventify/model/user.dart';
import 'package:eventify/service/firebase_firestore_service.dart';
import 'package:eventify/view/screens/search_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:provider/provider.dart';
import 'package:eventify/provider/firebase_provider.dart';
import 'package:eventify/view/widgets/user_item.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Provider.of<FirebaseProvider>(context, listen: false).getAllUsers();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        FirebaseFirestoreService.updateUserData({
          'lastActive': DateTime.now(),
          'isOnline': true,
        });
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        FirebaseFirestoreService.updateUserData({'isOnline': false});
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case. Do nothing.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  final userData = [
    UserModel(
      uid: '1',
      name: 'Hazy',
      email: 'test@test.test',
      image: 'https://i.pravatar.cc/150?img=0',
      isOnline: true,
      lastActive: DateTime.now(),
    ),
    UserModel(
      uid: '2',
      name: 'Charlotte',
      email: 'test@test.test',
      image: 'https://i.pravatar.cc/150?img=1',
      isOnline: false,
      lastActive: DateTime.now(),
    ),
    UserModel(
      uid: '3',
      name: 'Ahmed',
      email: 'test@test.test',
      image: 'https://i.pravatar.cc/150?img=2',
      isOnline: true,
      lastActive: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UsersSearchScreen())),
              icon: const Icon(Icons.search, color: Colors.black),
            ),
            // IconButton(
            //   // Try whether the following works
            //   onPressed: () => FirebaseAuth.instance.signOut(),
            //   icon: const Icon(Icons.logout, color: Colors.black),
            // ),
          ],
        ),
        body: Consumer<FirebaseProvider>(builder: (context, value, child) {
          return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: value.users.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              physics: const BouncingScrollPhysics(),
              // Got to check whether the FirebaseAuth is correct one since mine is using the pre-built
              itemBuilder: (context, index) => value.users[index].uid !=
                      FirebaseAuth.instance.currentUser?.uid
                  ? UserItem(user: value.users[index])
                  : const SizedBox());
        }),
      );
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Chats'),
  //     ),
  //     body: Consumer<FirebaseProvider>(
  //       builder: (context, firebaseProvider, child) {
  //         if (firebaseProvider.users.isEmpty) {
  //           return const Center(child: CircularProgressIndicator());
  //         } else {
  //           return ListView.separated(
  //             padding: const EdgeInsets.symmetric(horizontal: 16),
  //             itemCount: firebaseProvider.users.length,
  //             separatorBuilder: (context, index) => const SizedBox(height: 10),
  //             physics: const BouncingScrollPhysics(),
  //             itemBuilder: (context, index) =>
  //                 UserItem(user: firebaseProvider.users[index]),
  //           );
  //         }
  //       },
  //     ),
  //   );
  // }
}
