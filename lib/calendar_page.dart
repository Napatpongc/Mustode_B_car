import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Separate variables for pickup and return dates.
  DateTime? _pickupDate;
  DateTime? _returnDate;
  
  // Time variables
  TimeOfDay _pickupTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _returnTime = const TimeOfDay(hour: 12, minute: 0);
  
  // Calendar settings
  DateTime _focusedDay = DateTime.now();
  final DateTime _firstDay = DateTime.now();
  final DateTime _lastDay = DateTime(2030);
  
  // 0: pickup, 1: return
  int _selectedTab = 0;
  
  Future<void> _selectTime(BuildContext context, bool isPickup) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isPickup ? _pickupTime : _returnTime,
    );
    if (pickedTime != null) {
      setState(() {
        if (isPickup) {
          _pickupTime = pickedTime;
        } else {
          _returnTime = pickedTime;
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Entire page in light theme
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(title: const Text('เลือกวัน-เวลา รับรถ/คืนรถ')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Toggle to switch between pickup and return slots.
              ToggleButtons(
                isSelected: [_selectedTab == 0, _selectedTab == 1],
                onPressed: (index) {
                  setState(() {
                    _selectedTab = index;
                    _focusedDay = DateTime.now();
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('วันรับรถ'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('วันคืนรถ'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Calendar as a single-date selector.
              TableCalendar(
                firstDay: _firstDay,
                lastDay: _lastDay,
                focusedDay: _focusedDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    if (_selectedTab == 0) {
                      _pickupDate = selectedDay;
                    } else {
                      _returnDate = selectedDay;
                    }
                  });
                },
                selectedDayPredicate: (day) {
                  if (_selectedTab == 0) {
                    return isSameDay(day, _pickupDate);
                  } else {
                    return isSameDay(day, _returnDate);
                  }
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                  defaultTextStyle: const TextStyle(color: Colors.black),
                  weekendTextStyle: const TextStyle(color: Colors.red),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  decoration: const BoxDecoration(color: Colors.white),
                  titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              // Larger, easier-to-tap time selection button.
              _selectedTab == 0
                  ? GestureDetector(
                      onTap: () => _selectTime(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Text(
                          'เวลารับรถ: ${_pickupTime.format(context)}',
                          style: const TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () => _selectTime(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Text(
                          'เวลาคืนรถ: ${_returnTime.format(context)}',
                          style: const TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_pickupDate == null || _returnDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('กรุณาเลือกทั้งวันรับรถและวันคืนรถ')),
                    );
                  } else {
                    Navigator.pop(context, {
                      'pickupDate': _pickupDate,
                      'pickupTime': _pickupTime,
                      'returnDate': _returnDate,
                      'returnTime': _returnTime,
                    });
                  }
                },
                child: const Text("ตกลง"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
