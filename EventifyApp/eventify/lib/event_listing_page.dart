import 'package:flutter/material.dart';

class EventListingPage extends StatelessWidget {
  const EventListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Listing'),
      ),
      body: Center(
        child: Text('Event Listing Content'),
      ),
    );
  }
}