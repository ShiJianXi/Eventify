import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'event_display.dart';


class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List> _events = {};

   @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('events').get();

    Map<DateTime, List> events = {};

    querySnapshot.docs.forEach((doc) {
      var data = doc.data() as Map<String, dynamic>;
      DateTime startDate = (data['startDate'] as Timestamp).toDate();

      //Only use the date part
      DateTime eventDate = DateTime(startDate.year, startDate.month, startDate.day);

      if (events[eventDate] == null) {
        events[eventDate] = [];
      }
      events[eventDate]!.add(data);
    });

    setState(() {
      _events = events;
    });

  }

  List _getEventsForDay(DateTime day) {

    //use only date part
    DateTime eventDate = DateTime(day.year, day.month, day.day);
    return _events[eventDate] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    List events = _getEventsForDay(_selectedDay);
    if (events.isEmpty) {
      return Center(child: Text('No events for this day.'));
    }
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        var event = events[index] as Map<String, dynamic>;
        return Event_display(
          title: event['title'] ?? '',
          description: event['description'] ?? '',
          startDate: event['startDate'] != null
              ? (event['startDate'] as Timestamp).toDate().toString().split(' ')[0]
              : '',
          endDate: event['endDate'] != null
              ? (event['endDate'] as Timestamp).toDate().toString().split(' ')[0]
              : '',
          startTime: event['startTime'] ?? '',
          endTime: event['endTime'] ?? '',
          thumbnailUrl: event['thumbnailUrl'] ?? '',
          location: event['location'] ?? '',
          price: event['price'] ?? '',
        );
      },
    );
  }
}