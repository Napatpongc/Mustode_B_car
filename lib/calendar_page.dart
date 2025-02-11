import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
        backgroundColor: Color(0xFF00377E),  // Set color matching theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),  // Add padding for better spacing
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
            ),
            SizedBox(height: 20),

            // Display selected date
            if (_selectedDay != null)
              Text(
                'Selected Date: ${_selectedDay!.toLocal()}'.split(' ')[0],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            
            SizedBox(height: 20),

            // Back button to HomePage
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);  // Return to the previous page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,  
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Back to Home",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
