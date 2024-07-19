//This page shows the details of the specific event when the users clicks on the event on the home page

import 'package:flutter/material.dart';

class EventDetailsPage extends StatelessWidget {
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String thumbnailUrl;
  final String location;
  final String price;

  EventDetailsPage({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.thumbnailUrl,
    required this.location,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(thumbnailUrl),
              SizedBox(height: 16),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(description),
              SizedBox(height: 16),
              Text(
                'Date & Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('From: $startDate at $startTime'),
              Text('To: $endDate at $endTime'),
              SizedBox(height: 16),
              Text(
                'Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(location),
              SizedBox(height: 16),
              Text(
                'Price',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('\$' + '$price'),
            ],
          ),
        ),
      ),
    );
  }
}
