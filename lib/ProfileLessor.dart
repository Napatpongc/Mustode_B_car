import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ProfileRenter.dart';

class ProfileLessor extends StatefulWidget {
  @override
  _ProfileLessorState createState() => _ProfileLessorState();
}

class _ProfileLessorState extends State<ProfileLessor> {
  Future<String?> _editDialog(String label, String? value) async {
    final ctrl = TextEditingController(text: value ?? "");
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("แก้ไข$label"),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("ยกเลิก")),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text), child: Text("บันทึก")),
        ],
      ),
    );
  }

  Widget _whiteBox(Widget child) => Container(
        width: MediaQuery.of(context).size.width * 0.9,
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Scaffold(body: Center(child: Text("ไม่พบผู้ใช้ที่ login")));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00377E),
        title: Text("บัญชี (ผู้ปล่อยเช่า)"),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (_, snap) {
          if (snap.hasError) return Center(child: Text("เกิดข้อผิดพลาด"));
          if (snap.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snap.hasData || !snap.data!.exists) return Center(child: Text("ไม่พบข้อมูลผู้ใช้งาน"));

          var data = snap.data!.data() as Map<String, dynamic>;
          String? username = data['username'];
          String? email = data['email'];
          String? phone = data['phone'];
          var addr = data['address'] as Map<String, dynamic>?;
          String? province = addr?['province'];
          String? district = addr?['district'];
          String? subdistrict = addr?['subdistrict'];
          String? postal = addr?['postalCode'];
          String? more = addr?['moreinfo'];

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 30, backgroundColor: Colors.grey[300], child: Icon(Icons.person, size: 40)),
                      SizedBox(width: 16),
                      Expanded(child: Text(username ?? "ไม่มีชื่อ", style: TextStyle(fontSize: 24))),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          String? newVal = await _editDialog("ชื่อผู้ใช้", username);
                          if (newVal != null) {
                            FirebaseFirestore.instance.collection('users').doc(user.uid).update({'username': newVal});
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  title: Text("ผู้เช่า / ผู้ปล่อยเช่า (ผู้ปล่อยเช่า)"),
                  value: false,
                  onChanged: (val) {
                    if (val) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileRenter()));
                  },
                ),

                // ------------------ รายได้วันนี้ ------------------
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('payments').doc(user.uid).snapshots(),
                  builder: (_, paySnap) {
                    if (paySnap.hasError) return Center(child: Text("เกิดข้อผิดพลาดในการโหลดรายได้"));
                    if (paySnap.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                    if (!paySnap.hasData || !paySnap.data!.exists) {
                      return _incomeBox(0);
                    }
                    var payData = paySnap.data!.data() as Map<String, dynamic>;
                    num income = payData['mypayment'] ?? 0;
                    return _incomeBox(income);
                  },
                ),

                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0x9ED6EFFF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ข้อมูลส่วนตัว", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      _whiteBox(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ที่อยู่:", style: TextStyle(fontSize: 18)),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(child: Text("จังหวัด : ${province ?? "ไม่มีข้อมูล"}")),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () async {
                                        String? newVal = await _editDialog("จังหวัด", province);
                                        if (newVal != null) {
                                          FirebaseFirestore.instance.collection('users').doc(user.uid).update({'address.province': newVal});
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(child: Text("อำเภอ : ${district ?? "ไม่มีข้อมูล"}")),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () async {
                                        String? newVal = await _editDialog("อำเภอ", district);
                                        if (newVal != null) {
                                          FirebaseFirestore.instance.collection('users').doc(user.uid).update({'address.district': newVal});
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(child: Text("ตำบล : ${subdistrict ?? "ไม่มีข้อมูล"}")),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () async {
                                        String? newVal = await _editDialog("ตำบล", subdistrict);
                                        if (newVal != null) {
                                          FirebaseFirestore.instance.collection('users').doc(user.uid).update({'address.subdistrict': newVal});
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(child: Text("รหัสไปรษณีย์ : ${postal ?? "ไม่มีข้อมูล"}")),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () async {
                                        String? newVal = await _editDialog("รหัสไปรษณีย์", postal);
                                        if (newVal != null) {
                                          FirebaseFirestore.instance.collection('users').doc(user.uid).update({'address.postalCode': newVal});
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(child: Text("เพิ่มเติม : ${more ?? "ไม่มีข้อมูล"}")),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () async {
                                        String? newVal = await _editDialog("เพิ่มเติม", more);
                                        if (newVal != null) {
                                          FirebaseFirestore.instance.collection('users').doc(user.uid).update({'address.moreinfo': newVal});
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                      _whiteBox(Row(
                        children: [
                          Expanded(child: Text("เบอร์โทรศัพท์: ${phone ?? "ไม่มีข้อมูล"}", style: TextStyle(fontSize: 16))),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              String? newVal = await _editDialog("เบอร์โทรศัพท์", phone);
                              if (newVal != null) {
                                FirebaseFirestore.instance.collection('users').doc(user.uid).update({'phone': newVal});
                              }
                            },
                          ),
                        ],
                      )),
                      _whiteBox(Row(
                        children: [
                          Expanded(child: Text("อีเมล: $email", style: TextStyle(fontSize: 16))),
                        ],
                      )),
                      _whiteBox(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('รูปใบขับขี่', style: TextStyle(fontSize: 18)),
                          SizedBox(height: 5),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.upload),
                            label: Text('เลือกรูป'),
                          ),
                          SizedBox(height: 20),
                          Text('รูปใบประชาชน', style: TextStyle(fontSize: 18)),
                          SizedBox(height: 5),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.upload),
                            label: Text('เลือกรูป'),
                          ),
                          SizedBox(height: 20),
                          Text('สัญญาปล่อยเช่า (จำเป็น)', style: TextStyle(fontSize: 18)),
                          SizedBox(height: 5),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.upload),
                            label: Text('เลือกรูป'),
                          ),
                        ],
                      )),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("บันทึกข้อมูลเรียบร้อย")));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            child: Text("บันทึก", style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // รวม widget “รายได้วันนี้” ไว้ในไฟล์เดียวกันเลย (ตัดคอมเมนต์ออก)
  Widget _incomeBox(num myPayment) {
    final String incomeText = myPayment.toStringAsFixed(2);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("รายได้วันนี้", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text("฿ $incomeText", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700])),
        ],
      ),
    );
  }
}
