import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  final DateTime _today = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  TimeOfDay _pickupTime = TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _returnTime = TimeOfDay(hour: 12, minute: 0);
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  Future<void> _selectTime(BuildContext context, bool isPickup) async {
    TimeOfDay? pickedTime = await showTimePicker(
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

  int _calculateRentalDays() {
    if (_rangeStart != null && _rangeEnd != null) {
      return _rangeEnd!.difference(_rangeStart!).inDays + 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เลือกวัน-เวลา รับรถ/คืนรถ'),
        backgroundColor: Color(0xFF00377E),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSelection(context),
            SizedBox(height: 20),
            _buildCalendar(),
            SizedBox(height: 20),
            Center(
              child: _buildRentalDaysDisplay(),
            ),
            SizedBox(height: 30),
            Center(
              child: _buildConfirmButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _dateBox(
          label: 'วันรับรถ',
          date: _rangeStart != null ? _formatDate(_rangeStart!) : 'เลือกวันที่',
          time: _pickupTime.format(context),
          onTapDate: () => setState(
              () => _rangeSelectionMode = RangeSelectionMode.toggledOn),
          onTapTime: () => _selectTime(context, true),
        ),
        _dateBox(
          label: 'วันคืนรถ',
          date: _rangeEnd != null ? _formatDate(_rangeEnd!) : 'เลือกวันที่',
          time: _returnTime.format(context),
          onTapTime: () => _selectTime(context, false),
        ),
      ],
    );
  }

  Widget _dateBox({
    required String label,
    required String date,
    required String time,
    required VoidCallback onTapTime,
    VoidCallback? onTapDate,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF575454))),
          GestureDetector(
            onTap: onTapDate,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Color(0xFF9CD9FF),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(2, 2))
                ],
              ),
              child: Text(date,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: onTapTime,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(2, 2))
                ],
              ),
              child: Text(time,
                  style: TextStyle(fontSize: 16, color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: _today,
      lastDay: DateTime(2030),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      availableCalendarFormats: {CalendarFormat.month: 'Month'},
      rangeSelectionMode: _rangeSelectionMode,
      rangeStartDay: _rangeStart,
      rangeEndDay: _rangeEnd,
      onRangeSelected: (start, end, focusedDay) {
        if (start != null && start.isBefore(_today)) return;
        if (end != null && end.isBefore(_today)) return;
        setState(() {
          _rangeStart = start;
          _rangeEnd = end;
          _focusedDay = focusedDay;
        });
      },
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        decoration: BoxDecoration(color: Color(0xFF00377E)),
        titleTextStyle: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildRentalDaysDisplay() {
    int rentalDays = _calculateRentalDays();
    return Text(
      rentalDays > 0 ? 'จำนวนวันเช่า: $rentalDays วัน' : 'โปรดเลือกช่วงวันเช่า',
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_rangeStart == null || _rangeEnd == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('กรุณาเลือกวันรับและวันคืนรถ')),
          );
        } else {
          Navigator.pop(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF00377E),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
      ),
      child: Text("ตกลง", style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
