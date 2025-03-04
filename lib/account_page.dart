import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String username = "Loading...";
  String phone = "Loading...";
  String district = "Loading...";
  String moreinfo = "Loading...";
  String province = "Loading...";

  @override
  void initState() {
    super.initState();
    useData();
  }

  Future<void> useData() async {
    try {
      DocumentSnapshot user = await FirebaseFirestore.instance
          .collection('users') // Ensure correct collection name
          .doc('D3Eh84N0Lcdxpaj9pimtaqIQjRw1') // Replace with actual document ID
          .get();

      if (user.exists) {
        setState(() {
          username = user['rentedCars']['username'] ?? "No username"; // From rentedCars
          phone = user['ownedCars']['phone'] ?? "No phone"; // From ownedCars
          district = user['address']['district'] ?? "No district"; // Correct way
          moreinfo = user['address']['moreinfo'] ?? "No moreinfo"; // Additional data
          province = user['address']['province'] ?? "No province"; // Province data
        });
      } else {
        setState(() {
          username = "User not found";
          phone = "N/A";
          district = "N/A";
          moreinfo = "N/A";
          province = "N/A";
        });
      }
    } catch (e) {
      setState(() {
        username = "Error loading data";
        phone = "Error";
        district = "Error";
        moreinfo = "Error";
        province = "Error";
      });
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Username: $username'),
            Text('Phone: $phone'),
            Text('District: $district'),
            Text('More Info: $moreinfo'),
            Text('Province: $province'),
          ],
        ),
      ),
    );
  }
}
