import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myproject/rgb_text.dart';
import 'Student.dart';
import 'package:firebase_core/firebase_core.dart';

class Formscream extends StatefulWidget {
  const Formscream({super.key});

  @override
  State<Formscream> createState() => _FormscreamState();
}

class _FormscreamState extends State<Formscream> {
  final formKey = GlobalKey<FormState>();
  Student myData = Student(
    fname: "",
    lname: "",
    email: "",
    score: "",
  );
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  CollectionReference _studentcollection =
      FirebaseFirestore.instance.collection("students");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Save Score"),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RGBText(
                  text: "First Name",
                  style: TextStyle(fontSize: 30),
                ),
                TextFormField(
                  onSaved: (String? fname) {
                    myData.fname = fname ?? "";
                  },
                ),
                SizedBox(height: 15),
                RGBText(
                  text: "Last Name",
                  style: TextStyle(fontSize: 30),
                ),
                TextFormField(
                  onSaved: (String? lname) {
                    myData.lname = lname ?? "";
                  },
                ),
                SizedBox(height: 15),
                RGBText(
                  text: "Email",
                  style: TextStyle(fontSize: 30),
                ),
                TextFormField(
                  onSaved: (String? email) {
                    myData.email = email ?? "";
                  },
                ),
                SizedBox(height: 15),
                RGBText(
                  text: "Score",
                  style: TextStyle(fontSize: 30),
                ),
                TextFormField(
                  onSaved: (String? score) {
                    myData.score = score ?? "";
                  },
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: RGBText(
                      text: "Submit",
                      style: TextStyle(fontSize: 40),
                    ),
                    onPressed: () async {
                      if (formKey.currentState != null) {
                        formKey.currentState!.save();
                        try {
                          await _studentcollection.add({
                            "fname": myData.fname,
                            "lname": myData.lname,
                            "Email": myData.email,
                            "score": myData.score,
                          });
                          formKey.currentState?.reset();
                          print("Document added successfully");
                        } catch (e) {
                          print("Error: $e");
                        }
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
