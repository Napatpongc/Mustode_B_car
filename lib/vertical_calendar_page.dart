import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

/// แปลง DateTime ให้เป็นรูปแบบภาษาไทย เช่น "วันพฤหัสบดีที่ 1 มีนาคม 2568"
String formatDateThai(DateTime date) {
  final List<String> thaiWeekdays = [
    "", // index 0 ไม่ได้ใช้
    "จันทร์",
    "อังคาร",
    "พุธ",
    "พฤหัสบดี",
    "ศุกร์",
    "เสาร์",
    "อาทิตย์"
  ];
  final List<String> thaiMonths = [
    "",
    "มกราคม",
    "กุมภาพันธ์",
    "มีนาคม",
    "เมษายน",
    "พฤษภาคม",
    "มิถุนายน",
    "กรกฎาคม",
    "สิงหาคม",
    "กันยายน",
    "ตุลาคม",
    "พฤศจิกายน",
    "ธันวาคม"
  ];
  String weekday = thaiWeekdays[date.weekday];
  String day = date.day.toString();
  String month = thaiMonths[date.month];
  int buddhistYear = date.year + 543;
  return "วัน$weekdayที่ $day $month $buddhistYear";
}

class VerticalCalendarPage extends StatefulWidget {
  const VerticalCalendarPage({Key? key}) : super(key: key);

  @override
  _VerticalCalendarPageState createState() => _VerticalCalendarPageState();
}

class _VerticalCalendarPageState extends State<VerticalCalendarPage> {
  PickerDateRange? _selectedRange;
  // ตัวแปรเวลา
  TimeOfDay? _pickupTime;
  TimeOfDay? _returnTime;

  final DateTime now = DateTime.now();
  late final DateTime lastDay = DateTime(now.year, now.month + 12, now.day);

  // ฟังก์ชันเลือกเวลา โดยรับ parameter ว่าเป็นเวลารับรถ (isPickup=true) หรือเวลาคืนรถ (isPickup=false)
  Future<void> _selectTime(bool isPickup) async {
    final TimeOfDay initialTime = isPickup
        ? _pickupTime ?? const TimeOfDay(hour: 9, minute: 0)
        : _returnTime ?? const TimeOfDay(hour: 17, minute: 0);
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
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
    int? daysCount;
    String? dateRangeText;
    if (_selectedRange != null &&
        _selectedRange!.startDate != null &&
        _selectedRange!.endDate != null) {
      daysCount = _selectedRange!.endDate!
              .difference(_selectedRange!.startDate!)
              .inDays +
          1;
      dateRangeText =
          "${formatDateThai(_selectedRange!.startDate!)}\nถึง\n${formatDateThai(_selectedRange!.endDate!)}";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกช่วงวันที่และเวลา'),
        centerTitle: true,
        backgroundColor: const Color(0xFF00377E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SfDateRangePicker(
              enableMultiView: false,
              selectionMode: DateRangePickerSelectionMode.range,
              minDate: now,
              maxDate: lastDay,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is PickerDateRange) {
                  setState(() {
                    _selectedRange = args.value;
                  });
                }
              },
              headerStyle: const DateRangePickerHeaderStyle(
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              view: DateRangePickerView.month,
              monthViewSettings: const DateRangePickerMonthViewSettings(dayFormat: 'EEE'),
              selectionColor: Colors.orange,
              rangeSelectionColor: Colors.orange.withOpacity(0.5),
              startRangeSelectionColor: Colors.orange,
              endRangeSelectionColor: Colors.orange,
              todayHighlightColor: Colors.blue,
              selectionShape: DateRangePickerSelectionShape.rectangle,
            ),
            const SizedBox(height: 20),
            if (daysCount != null)
              Column(
                children: [
                  Text(
                    'คุณทำการเช่ารถ $daysCount วัน',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateRangeText ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            // ปุ่มเลือกเวลา: รับรถ และ คืนรถ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _selectTime(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00377E),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    _pickupTime != null
                        ? "รับรถ: ${_pickupTime!.format(context)}"
                        : "เลือกเวลา รับรถ",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectTime(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00377E),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    _returnTime != null
                        ? "คืนรถ: ${_returnTime!.format(context)}"
                        : "เลือกเวลา คืนรถ",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // ตรวจสอบว่าผู้ใช้ได้เลือกช่วงวันที่และเวลา "รับรถ" กับ "คืนรถ" ครบถ้วนหรือไม่
                if (_selectedRange != null &&
                    _selectedRange!.startDate != null &&
                    _selectedRange!.endDate != null &&
                    _pickupTime != null &&
                    _returnTime != null) {
                  Navigator.pop(context, {
                    'startDate': _selectedRange!.startDate,
                    'endDate': _selectedRange!.endDate,
                    'daysCount': daysCount,
                    'pickupTime': _pickupTime,
                    'returnTime': _returnTime,
                  });
                } else {
                  // แสดงข้อความเฉพาะในหน้า vertical_calendar_page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('กรุณาใส่วันเวลารับรถ-คืนรถให้ครบด้วยนะครับ'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00377E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'ยืนยัน',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
