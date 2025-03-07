import 'package:flutter/material.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  static const _headerBackgroundColor = Color(0xFF00377E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            // ใช้ Expanded เพื่อให้ส่วน scrollable ครอบคลุมพื้นที่ที่เหลือ
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PriceRangeSlider(),
                    SizedBox(height: 20),
                    StarRatingFilter(),
                    SizedBox(height: 20),
                    VehicleTypeFilter(),
                    SizedBox(height: 20),
                    TransmissionFilter(),
                    SizedBox(height: 20),
                    SearchResults(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _headerBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/filter_icon.png',
            width: 32,
            height: 39,
          ),
          const Text(
            'ตัวกรอง',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'IBM Plex Sans Thai Looped',
            ),
          ),
          // ใช้ SizedBox เพื่อรักษาความสมดุลของ layout หากไม่มี widget ทางด้านขวา
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}

class PriceRangeSlider extends StatefulWidget {
  const PriceRangeSlider({super.key});

  @override
  _PriceRangeSliderState createState() => _PriceRangeSliderState();
}

class _PriceRangeSliderState extends State<PriceRangeSlider> {
  RangeValues _currentRange = const RangeValues(0, 100000000);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPriceHeader(),
        const SizedBox(height: 12),
        _buildSlider(),
        const SizedBox(height: 12),
        const Text(
          'ช่วงราคา',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPriceHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'ราคา',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          '฿ ${_currentRange.start.round()} - ฿ ${_currentRange.end.round()}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSlider() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.blue,
        inactiveTrackColor: Colors.blue[100],
        thumbColor: Colors.blue,
      ),
      child: RangeSlider(
        values: _currentRange,
        min: 0,
        max: 100000000,
        divisions: 100,
        labels: RangeLabels(
          _currentRange.start.round().toString(),
          _currentRange.end.round().toString(),
        ),
        onChanged: (values) {
          setState(() {
            _currentRange = values;
          });
        },
      ),
    );
  }
}

// Stub สำหรับ widget ที่ยังไม่มีการ implement
class StarRatingFilter extends StatelessWidget {
  const StarRatingFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.amberAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('Star Rating Filter'),
    );
  }
}

class VehicleTypeFilter extends StatelessWidget {
  const VehicleTypeFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('Vehicle Type Filter'),
    );
  }
}

class TransmissionFilter extends StatelessWidget {
  const TransmissionFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.purpleAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('Transmission Filter'),
    );
  }
}

class SearchResults extends StatelessWidget {
  const SearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('Search Results'),
    );
  }
}