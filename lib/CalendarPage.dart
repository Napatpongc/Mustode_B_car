import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  final DateTime? initialPickupDate;
  final TimeOfDay? initialPickupTime;
  final DateTime? initialReturnDate;
  final TimeOfDay? initialReturnTime;

  const CalendarPage({
    Key? key,
    this.initialPickupDate,
    this.initialPickupTime,
    this.initialReturnDate,
    this.initialReturnTime,
  }) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // เก็บค่าที่เลือก
  DateTime selectedPickupDate = DateTime.now();
  TimeOfDay selectedPickupTime = TimeOfDay.now();
  DateTime selectedReturnDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay selectedReturnTime = TimeOfDay.now();

  // ควบคุม calendar ให้รู้ว่าตอนนี้กำลังเลือก "pickup" หรือ "return"
  bool isSelectingPickup = true; // true = เลือกวัน-เวลา รับรถ, false = เลือกวัน-เวลา คืนรถ

  @override
  void initState() {
    super.initState();
    if (widget.initialPickupDate != null) {
      selectedPickupDate = widget.initialPickupDate!;
    }
    if (widget.initialPickupTime != null) {
      selectedPickupTime = widget.initialPickupTime!;
    }
    if (widget.initialReturnDate != null) {
      selectedReturnDate = widget.initialReturnDate!;
    }
    if (widget.initialReturnTime != null) {
      selectedReturnTime = widget.initialReturnTime!;
    }
  }

  // ยืนยันการเลือก
  void _confirmSelection() {
    Navigator.pop(context, {
      'pickupDate': selectedPickupDate,
      'pickupTime': selectedPickupTime,
      'returnDate': selectedReturnDate,
      'returnTime': selectedReturnTime,
    });
  }

  // ฟังก์ชันเลือกเวลา
  Future<void> _pickTime(bool isPickup) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isPickup ? selectedPickupTime : selectedReturnTime,
    );
    if (picked != null) {
      setState(() {
        if (isPickup) {
          selectedPickupTime = picked;
        } else {
          selectedReturnTime = picked;
        }
      });
    }
  }

  // ฟังก์ชันเลือกวันในปฏิทิน
  void _onDaySelected(DateTime day) {
    setState(() {
      if (isSelectingPickup) {
        selectedPickupDate = day;
      } else {
        selectedReturnDate = day;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // UI หลัก
    return Scaffold(
      appBar: AppBar(
        title: const Text("เลือกวัน-เวลา รับรถ/คืนรถ"),
        backgroundColor: const Color(0xFF00377E),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------------------------------------------
            // แถบเลือกกำลังดู Calendar ของ "รับรถ" หรือ "คืนรถ"
            // ---------------------------------------------
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue, width: 1.5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ปุ่มเลือกวัน-เวลารับรถ
                  GestureDetector(
                    onTap: () => setState(() => isSelectingPickup = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelectingPickup ? Colors.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "รับรถ",
                        style: TextStyle(
                          color: isSelectingPickup ? Colors.white : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // ปุ่มเลือกวัน-เวลาคืนรถ
                  GestureDetector(
                    onTap: () => setState(() => isSelectingPickup = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: !isSelectingPickup ? Colors.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "คืนรถ",
                        style: TextStyle(
                          color: !isSelectingPickup ? Colors.white : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ---------------------------------------------
            // ส่วน TableCalendar
            // ---------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TableCalendar(
                focusedDay: isSelectingPickup ? selectedPickupDate : selectedReturnDate,
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                selectedDayPredicate: (day) {
                  return isSelectingPickup
                      ? isSameDay(selectedPickupDate, day)
                      : isSameDay(selectedReturnDate, day);
                },
                onDaySelected: (selectedDay, _) => _onDaySelected(selectedDay),
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ---------------------------------------------
            // ส่วนเลือกเวลา (Time Picker)
            // ---------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "เวลา${isSelectingPickup ? "รับรถ" : "คืนรถ"}: ",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _pickTime(isSelectingPickup),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9CD9FF),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isSelectingPickup
                          ? "${selectedPickupTime.hour.toString().padLeft(2, '0')}:${selectedPickupTime.minute.toString().padLeft(2, '0')} น."
                          : "${selectedReturnTime.hour.toString().padLeft(2, '0')}:${selectedReturnTime.minute.toString().padLeft(2, '0')} น.",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ---------------------------------------------
            // แสดงค่าวัน-เวลาที่เลือก
            // ---------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    "รับรถ: "
                    "${selectedPickupDate.day}/${selectedPickupDate.month}/${selectedPickupDate.year} "
                    "${selectedPickupTime.format(context)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "คืนรถ: "
                    "${selectedReturnDate.day}/${selectedReturnDate.month}/${selectedReturnDate.year} "
                    "${selectedReturnTime.format(context)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ---------------------------------------------
            // ปุ่ม "ตกลง" ยืนยัน
            // ---------------------------------------------
            ElevatedButton(
              onPressed: _confirmSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("ตกลง", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
