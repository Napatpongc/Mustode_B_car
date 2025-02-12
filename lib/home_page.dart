import 'package:flutter/material.dart';
import 'calendar_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _pickupDate;
  DateTime? _returnDate;
  TimeOfDay _pickupTime = TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _returnTime = TimeOfDay(hour: 12, minute: 0);
  OverlayEntry? _overlayEntry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildSearchBox(),
                    SizedBox(height: 20),
                    _buildResultsSection(),
                  ],
                ),
              ),
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Home Page', textAlign: TextAlign.center),
      backgroundColor: Color(0xFF00377E),
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () => _showBurgerBar(),
      ),
    );
  }

  // Burger bar show/hide logic
  void _showBurgerBar() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      _overlayEntry = _createOverlay();
      Overlay.of(context)?.insert(_overlayEntry!);
    }
  }

  OverlayEntry _createOverlay() {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,  // Align overlay to the left
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              _overlayEntry?.remove();
              _overlayEntry = null;
            },
            child: Container(
              width: 242,
              height: 956,
              decoration: BoxDecoration(color: Colors.white),
              child: Frame3(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 120,
      color: Color(0xFF00377E),
      alignment: Alignment.center,
      child: Text(
        "เลือกวัน-เวลา รับรถ/คืนรถ",
        style: _textStyle(20, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        children: [
          _dateTimeField(
            label: 'วันเวลาที่รับรถ',
            date: _pickupDate != null ? _formatDate(_pickupDate!) : 'เลือกวันที่',
            time: _pickupTime.format(context),
            onTap: () => _showDateTimePicker(context, true),
          ),
          SizedBox(height: 15),
          _dateTimeField(
            label: 'วันเวลาที่คืนรถ',
            date: _returnDate != null ? _formatDate(_returnDate!) : 'เลือกวันที่',
            time: _returnTime.format(context),
            onTap: () => _showDateTimePicker(context, false),
          ),
        ],
      ),
    );
  }

  void _showDateTimePicker(BuildContext context, bool isPickup) {
    DateTime tempDate = isPickup ? (_pickupDate ?? DateTime.now()) : (_returnDate ?? DateTime.now());
    TimeOfDay tempTime = isPickup ? _pickupTime : _returnTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('เลือกวันที่', style: _textStyle(20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  CalendarDatePicker(
                    initialDate: tempDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                    onDateChanged: (newDate) {
                      setModalState(() {
                        tempDate = newDate;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Text('เลือกเวลา', style: _textStyle(20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: tempTime,
                      );
                      if (pickedTime != null) {
                        setModalState(() {
                          tempTime = pickedTime;
                        });
                      }
                    },
                    child: Text('เลือกเวลา', style: _textStyle(16)),
                  ),
                  SizedBox(height: 10),
                  Text("เวลาที่เลือก: ${tempTime.format(context)}", style: _textStyle(18, color: Colors.blue)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (isPickup) {
                          _pickupDate = tempDate;
                          _pickupTime = tempTime;
                        } else {
                          _returnDate = tempDate;
                          _returnTime = tempTime;
                        }
                      });
                      Navigator.pop(context);
                    },
                    child: Text('ตกลง', style: _textStyle(16)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResultsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFD6EFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text('ผลการค้นหา : รถว่างทั้งหมด', style: _textStyle(24)),
          SizedBox(height: 10),
          Text('พบรถว่าง 3 คัน', style: _textStyle(15, color: Color(0xFF09C000))),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF00377E),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text("Logout", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _dateTimeField({required String label, required String date, required String time, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: _boxDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: _textStyle(16, color: Color(0xFF575454))),
                Text(date, style: _textStyle(18)),
                Text(time, style: _textStyle(18)),
              ],
            ),
            Icon(Icons.calendar_today, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]);
  }

  TextStyle _textStyle(double size, {Color color = Colors.black, FontWeight fontWeight = FontWeight.normal}) {
    return TextStyle(fontSize: size, color: color, fontWeight: fontWeight);
  }
}

class Frame3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 242,
          height: 956,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: -6,
                child: Container(
                  width: 242,
                  height: 164,
                  decoration: BoxDecoration(color: Color(0xFF00377E)),
                ),
              ),
              Positioned(
                left: 86,
                top: 103,
                child: Text(
                  'Young Yuri',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 49,
                top: 217,
                child: Text(
                  'หน้าหลัก',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 49,
                top: 270,
                child: Text(
                  'แผนที่',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 45,
                top: 323,
                child: Text(
                  'รายการเช่าทั้งหมด',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 45,
                top: 374,
                child: Text(
                  'การตั้งค่าบัญชี',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 59,
                top: 890,
                child: Container(
                  width: 124,
                  height: 39,
                  decoration: ShapeDecoration(
                    color: Color(0xFFE83A3A),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 75,
                top: 897,
                child: Text(
                  'ออกจากระบบ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 17,
                top: 87,
                child: Container(
                  width: 57,
                  height: 57,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/57x57"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 11,
                top: 210,
                child: Container(
                  width: 34,
                  height: 32,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/34x32"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 262,
                child: Container(
                  width: 24,
                  height: 33,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/24x33"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 11,
                top: 312,
                child: Container(
                  width: 34,
                  height: 36,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/34x36"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 15,
                top: 365,
                child: Container(
                  width: 26,
                  height: 32,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/26x32"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
