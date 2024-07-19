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
  //Initial format of the calendar
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Representing ther currently selected date in the calendar
  DateTime _selectedDay = DateTime.now();

  //Representing the date that is currently focused in the calendar view.
  //This is the date that is displayed in the center of the calendar when the user navigates through different months.
  DateTime _focusedDay = DateTime.now();

  //Initialise an empty map to store events by their date
  // Map<DateTime, List> is a map where each key is a 'DateTime' representing a day
  // and the value is a list of events occurring on that day
  Map<DateTime, List> _events = {};

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  //Function to fetch events from Firestore and organise them by date
  Future<void> _fetchEvents() async {
    // Fetch all documents from the 'events' collection in Firestore.
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('events').get();

    Map<DateTime, List> events = {};

    // Loop through each document fetched from Firestore.
    querySnapshot.docs.forEach((doc) {
      // Convert the document data to a map
      var data = doc.data() as Map<String, dynamic>;

      // Get the start date of the event as a DateTime object
      DateTime startDate = (data['startDate'] as Timestamp).toDate();

      //Extract only the date part of the DateTime object for it to display accurately on the calendar
      DateTime eventDate =
          DateTime(startDate.year, startDate.month, startDate.day);

      // Initialise the list for this date if it is not already initialised
      if (events[eventDate] == null) {
        events[eventDate] = [];
      }
      // Add the event data to the list of events for this date
      events[eventDate]!.add(data);
    });

    // Update the state with the fetched events and trigger a rebuild
    setState(() {
      _events = events;
    });
  }

  // Function to get events for a specific day
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

            //When a user selects a date, onDaySelected callback is triggered
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },

            //When the calendar format is changed, example from month to week view, this callback updates the format
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },

            //When a user navigates to a different month, this callback updates the focused day.
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

  // To build the event list for the selected day
  Widget _buildEventList() {
    //Get the events for the selected day
    List events = _getEventsForDay(_selectedDay);

    // If there are no events, show a message
    if (events.isEmpty) {
      return Center(child: Text('No events for this day.'));
    }

    //Build a ListView to display the events
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        var event = events[index] as Map<String, dynamic>;
        return Event_display(
          title: event['title'] ?? '',
          description: event['description'] ?? '',
          startDate: event['startDate'] != null
              ? (event['startDate'] as Timestamp)
                  .toDate()
                  .toString()
                  .split(' ')[0]
              : '',
          endDate: event['endDate'] != null
              ? (event['endDate'] as Timestamp)
                  .toDate()
                  .toString()
                  .split(' ')[0]
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
