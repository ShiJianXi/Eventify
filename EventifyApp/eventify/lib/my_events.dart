import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {

  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete event: $e')));
    }
  }
  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('My Events'),
        ),
        body: Center(
          child: Text('You need to be logged in to see your events.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Events'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('userId', isEqualTo: currentUser!.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Something went wrong: ${snapshot.error.toString()}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No events found.'));
          }

          var events = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              elevation: 5,
              child: ListTile(
                leading: data['thumbnailUrl'] != null
                    ? Image.network(data['thumbnailUrl'], width: 50, height: 50, fit: BoxFit.cover)
                    : Icon(Icons.event, size: 50),
                title: Text(data['title'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['description'] ?? ''),
                    SizedBox(height: 5),
                    Text('Location: ${data['location'] ?? ''}'),
                    Text('Date: ${data['startDate'] != null
                        ? (data['startDate'] as Timestamp).toDate().toString().split(' ')[0]
                        : ''}'),
                    Text('Time: ${data['startTime'] ?? ''} - ${data['endTime'] ?? ''}'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteEvent(doc.id);
                  },
                ),
              ),
            );
          }).toList();
          return ListView(
            children: events,
          );
        },
      ),
    );
  }
}
