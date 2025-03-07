import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

/// ฟังก์ชันแปลงวันที่เป็นภาษาไทย (ถ้าไม่ต้องการใช้ สามารถลบออกได้)
String formatDateThai(DateTime date) {
  final List<String> thaiWeekdays = [
    "", "จันทร์", "อังคาร", "พุธ", "พฤหัสบดี",
    "ศุกร์", "เสาร์", "อาทิตย์"
  ];
  final List<String> thaiMonths = [
    "", "มกราคม", "กุมภาพันธ์", "มีนาคม", "เมษายน",
    "พฤษภาคม", "มิถุนายน", "กรกฎาคม", "สิงหาคม",
    "กันยายน", "ตุลาคม", "พฤศจิกายน", "ธันวาคม"
  ];
  String weekday = thaiWeekdays[date.weekday];
  String day = date.day.toString();
  String month = thaiMonths[date.month];
  int buddhistYear = date.year + 543;
  return "วัน$weekdayที่ $day $month $buddhistYear";
}

class VerticalCalendarPage extends StatefulWidget {
  final DateTime? initialPickupDate;
  final TimeOfDay? initialPickupTime;
  final DateTime? initialReturnDate;
  final TimeOfDay? initialReturnTime;

  const VerticalCalendarPage({
    Key? key,
    this.initialPickupDate,
    this.initialPickupTime,
    this.initialReturnDate,
    this.initialReturnTime,
  }) : super(key: key);

  @override
  _VerticalCalendarPageState createState() => _VerticalCalendarPageState();
}

class _VerticalCalendarPageState extends State<VerticalCalendarPage> {
  /// ตัวแปรเก็บช่วงวันที่ (range) ที่เลือก
  PickerDateRange? _selectedRange;

  /// เวลา "รับรถ" และ "คืนรถ"
  TimeOfDay? _pickupTime;
  TimeOfDay? _returnTime;

  final DateTime now = DateTime.now();
  // กำหนดวันสุดท้ายเป็น 12 เดือนข้างหน้าจากวันนี้
  late final DateTime lastDay = DateTime(now.year, now.month + 12, now.day);

  @override
  void initState() {
    super.initState();
    // ตั้งเวลาเริ่มต้น
    _pickupTime = widget.initialPickupTime ?? const TimeOfDay(hour: 9, minute: 0);
    _returnTime = widget.initialReturnTime ?? const TimeOfDay(hour: 17, minute: 0);

    // ถ้ามีค่าเริ่มต้นของวันมา ก็ set ให้ _selectedRange
    if (widget.initialPickupDate != null && widget.initialReturnDate != null) {
      _selectedRange = PickerDateRange(
        widget.initialPickupDate,
        widget.initialReturnDate,
      );
    }
  }

  /// ฟังก์ชันเลือกเวลา (รับรถ / คืนรถ)
  Future<void> _pickTime(bool isPickup) async {
    final TimeOfDay initial = isPickup
        ? (_pickupTime ?? TimeOfDay.now())
        : (_returnTime ?? TimeOfDay.now());
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      setState(() {
        if (isPickup) {
          _pickupTime = picked;
        } else {
          _returnTime = picked;
        }
      });
    }
  }

  /// ฟังก์ชันกดปุ่ม "ตกลง" => ส่งค่ากลับไปหน้าเดิม
  void _confirmSelection() {
    if (_selectedRange != null &&
        _selectedRange!.startDate != null &&
        _selectedRange!.endDate != null) {
      Navigator.pop(context, {
        'pickupDate': _selectedRange!.startDate,
        'pickupTime': _pickupTime,
        'returnDate': _selectedRange!.endDate,
        'returnTime': _returnTime,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกช่วงวันที่ให้ครบถ้วน')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // คำนวณจำนวนวัน และข้อความสรุป
    int? daysCount;
    String? dateRangeText;
    if (_selectedRange != null &&
        _selectedRange!.startDate != null &&
        _selectedRange!.endDate != null) {
      final start = _selectedRange!.startDate!;
      final end = _selectedRange!.endDate!;
      daysCount = end.difference(start).inDays + 1;
      dateRangeText =
          "คุณทำการเช่ารถ $daysCount วัน\n"
          "จาก ${formatDateThai(start)}\n"
          "ถึง ${formatDateThai(end)}";
    }

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("เลือกวัน-เวลา รับรถ/คืนรถ"),
        centerTitle: true,
        backgroundColor: const Color(0xFF00377E),
      ),
      body: Column(
        children: [
          // ส่วนปฏิทิน (SfDateRangePicker)
          Expanded(
            child: SfDateRangePicker(
              // กำหนด minDate เพื่อไม่ให้เลือกวันที่ในอดีต
              minDate: DateTime(now.year, now.month, now.day),
              maxDate: lastDay,
              headerHeight: 50,
              showNavigationArrow: true,
              allowViewNavigation: true,
              backgroundColor: Colors.white,
              headerStyle: const DateRangePickerHeaderStyle(
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // ปรับ style ของ cell เดือน
              monthCellStyle: DateRangePickerMonthCellStyle(
                weekendTextStyle: const TextStyle(color: Colors.red),
                todayTextStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                todayCellDecoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                // กำหนดสีสำหรับวันที่ที่ถูก disable (ในอดีต)
                disabledDatesDecoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                disabledDatesTextStyle: const TextStyle(color: Colors.black38),
              ),
              selectionMode: DateRangePickerSelectionMode.range,
              onSelectionChanged: (args) {
                if (args.value is PickerDateRange) {
                  setState(() {
                    _selectedRange = args.value;
                  });
                }
              },
              selectionColor: Colors.orange,
              rangeSelectionColor: Colors.orangeAccent.withOpacity(0.3),
              startRangeSelectionColor: Colors.orange,
              endRangeSelectionColor: Colors.orange,
              todayHighlightColor: Colors.blue,
              selectionShape: DateRangePickerSelectionShape.rectangle,
              initialSelectedRange: _selectedRange,
            ),
          ),
          const SizedBox(height: 10),
          if (daysCount != null && dateRangeText != null) ...[
            Text(
              dateRangeText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
          const SizedBox(height: 10),
          // ปุ่มเลือกเวลา (รับรถ / คืนรถ)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _pickTime(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00377E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(
                  _pickupTime != null
                      ? "รับรถ: ${_pickupTime!.format(context)}"
                      : "เวลา รับรถ",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () => _pickTime(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00377E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(
                  _returnTime != null
                      ? "คืนรถ: ${_returnTime!.format(context)}"
                      : "เวลา คืนรถ",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ปุ่ม "ตกลง" ส่งค่ากลับ
          ElevatedButton(
            onPressed: _confirmSelection,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00377E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: const Text(
              "ตกลง",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
