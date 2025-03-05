import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final Future<FirebaseApp> _firebaseInitialization = Firebase.initializeApp();
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(); 
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptedTerms = false;

  // ฟังก์ชันสร้าง TextField พร้อมไอคอน
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
          labelText: label,
          labelStyle: TextStyle(color: Colors.black87),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.7),
        ),
        validator: (val) =>
            (val == null || val.trim().isEmpty) ? 'กรุณากรอก $label' : null,
      ),
    );
  }

  // ฟังก์ชันแสดงเงื่อนไขใน overlay dialog
  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("เงื่อนไขการจองรถและการชำระเงิน"),
          content: Container(
            width: double.maxFinite,
            height: 400, // ปรับความสูงตามที่ต้องการ
            child: SingleChildScrollView(
              child: Text(
                """#### **1. เงื่อนไขการจองรถ**

1. **คุณสมบัติของผู้เช่า**
   - ผู้เช่าต้องมีอายุอย่างน้อย **20 ปีบริบูรณ์** (ตามกฎหมายการเช่าทรัพย์ในประเทศไทย)
   - ผู้เช่าต้องมี **ใบอนุญาตขับขี่รถยนต์ที่ออกโดยกรมการขนส่งทางบกของประเทศไทย** และยังไม่หมดอายุ
   - สำหรับชาวต่างชาติ ผู้เช่าต้องมี **ใบอนุญาตขับขี่สากล (International Driving Permit)** หรือ **ใบขับขี่ที่แปลเป็นภาษาไทย** และรับรองจากสถานทูต

2. **ข้อมูลที่ต้องใช้ในการจอง**
   - **ชื่อ-นามสกุลตามบัตรประชาชนหรือหนังสือเดินทาง**
   - หมายเลขบัตรประชาชน (สำหรับคนไทย) หรือหมายเลขพาสปอร์ต (สำหรับชาวต่างชาติ)
   - สำเนาใบอนุญาตขับขี่
   - อีเมลและหมายเลขโทรศัพท์สำหรับติดต่อ
   - รายละเอียดการเดินทาง เช่น วันที่และเวลารับ-คืนรถ

3. **การเลือกรถ**
   - ผู้เช่าสามารถเลือกประเภทและรุ่นรถจากที่มีอยู่ในระบบ

4. **การยืนยันการจอง**
   - การจองจะถือว่าสมบูรณ์เมื่อระบบได้รับเงินค่าจองแล้ว
   - ต้องจองล่วงหน้าไม่น้อยกว่า **3 ชั่วโมง**

5. **การตรวจสอบเอกสารเมื่อรับรถ**
   - ผู้เช่าต้องแสดงบัตรประชาชนหรือหนังสือเดินทาง, ใบอนุญาตขับขี่ และหลักฐานการชำระเงินในวันรับรถ

--- 

#### **2. เงื่อนไขการชำระเงิน**

1. **ประเภทการชำระเงิน**
   - รองรับการชำระเงินผ่านการแสกน QR CODE เท่านั้น

2. **ค่ามัดจำ (Deposit)**
   - ผู้เช่าต้องชำระค่ามัดจำตามที่กำหนด (ขึ้นอยู่กับประเภทรถ)
   - ค่ามัดจำจะคืนให้ภายใน **7 วันทำการ** หลังคืนรถ หากไม่มีความเสียหายหรือค่าปรับเพิ่มเติม

3. **การชำระเงินเต็มจำนวน**
   - ผู้เช่าต้องชำระค่าเช่ารถเต็มจำนวนก่อนการรับรถ
   - หากมีการขยายระยะเวลาการเช่า ผู้เช่าต้องชำระเงินส่วนเพิ่มทันที

4. **ค่าธรรมเนียมเพิ่มเติม**
   - หากคืนรถล่าช้า จะมี **ค่าปรับเป็นรายชั่วโมง (โดยทั่วไป 100–200 บาทต่อชั่วโมง)** หรือ **เต็มวันในกรณีล่าช้าเกิน 4 ชั่วโมง**
   - **ค่าเชื้อเพลิง**: หากไม่คืนรถพร้อมน้ำมันเต็มถัง ผู้เช่าต้องชำระค่าน้ำมันเพิ่มเติมตามอัตราที่ผู้ให้บริการกำหนด
   - หากต้องการอุปกรณ์เสริม เช่น GPS หรือคาร์ซีทเด็ก จะมีค่าธรรมเนียมเพิ่มเติม

5. **การยกเลิกและการคืนเงิน**
   - **ยกเลิกก่อน 48 ชั่วโมง**: ไม่มีค่าธรรมเนียมการยกเลิก และเงินจะคืนภายใน 7 วันทำการ
   - **ยกเลิกภายใน 48 ชั่วโมง**: อาจมีค่าธรรมเนียมการยกเลิกสูงสุด **50% ของยอดจอง**
   - **กรณี No-Show (ไม่มารับรถ)**: ไม่มีการคืนเงิน

6. **ใบเสร็จและหลักฐานการชำระเงิน**
   - ระบบจะส่ง **ใบเสร็จรับเงินทางอีเมล** หลังการชำระเงินสำเร็จ

---

#### **3. ข้อกำหนดเพิ่มเติม (ตามกฎหมายประเทศไทย)**

1. **ประกันภัย**
   - รถเช่าทุกคันต้องมีประกันภัยภาคบังคับ (พ.ร.บ.) และประกันภัยชั้นหนึ่ง
   - ผู้เช่าสามารถซื้อประกันภัยเพิ่มเติมเพื่อลดความรับผิดชอบกรณีเกิดอุบัติเหตุ (Collision Damage Waiver, CDW)

2. **ความเสียหายและอุบัติเหตุ**
   - หากเกิดความเสียหาย ผู้เช่าต้องแจ้งผู้ให้บริการทันที พร้อมรายงานจากตำรวจ (หากเกี่ยวข้องกับอุบัติเหตุ)
   - ผู้เช่าต้องรับผิดชอบค่าความเสียหายส่วนแรกที่ไม่ได้ครอบคลุมในประกัน

3. **การใช้รถตามกฎหมาย**
   - ห้ามใช้รถในกิจกรรมผิดกฎหมาย เช่น การลักลอบขนสิ่งของผิดกฎหมาย
   - ห้ามขับรถออกนอกประเทศไทยโดยไม่ได้รับอนุญาต

---

#### **4. เงื่อนไขการคืนรถ**

1. **เวลาคืนรถ**
   - ผู้เช่าต้องคืนรถตามวันที่และเวลาที่ระบุในเอกสารการจอง
   - หากต้องการขยายเวลาการเช่า ผู้เช่าต้องแจ้งล่วงหน้าไม่น้อยกว่า **6 ชั่วโมง** และชำระเงินส่วนต่างตามอัตราที่กำหนด

2. **สถานที่คืนรถ**
   - รถต้องคืนในสถานที่ที่ได้ตกลงกับเจ้าของรถ
   - การเปลี่ยนสถานที่คืนรถจะขึ้นอยู่กับดุลยพินิจของเจ้าของรถ และอาจมีค่าธรรมเนียมเพิ่มเติม

3. **สภาพรถในขณะคืน**
   - รถต้องคืนในสภาพเดียวกับวันที่รับรถ (ยกเว้นการสึกหรอตามการใช้งานปกติ)
   - ผู้เช่าต้องคืนรถในสภาพสะอาดทั้งภายในและภายนอก หากไม่สะอาด เจ้าของรถสามารถเรียกเก็บค่าทำความสะอาดเพิ่มเติม

4. **น้ำมันเชื้อเพลิง**
   - ผู้เช่าต้องเติมน้ำมันคืนให้เต็มถัง (ตามปริมาณที่ได้รับเมื่อรับรถ)
   - หากน้ำมันไม่เต็มถัง เจ้าของรถสามารถเรียกเก็บค่าน้ำมันตามอัตราที่ตกลงกัน

5. **คืนช้ากว่ากำหนด**
   - หากผู้เช่าคืนรถล่าช้ากว่าที่กำหนด จะมีการเก็บเงินเพิ่มเติมในอัตรารายวัน (ตามเงื่อนไขในส่วน "คืนช้ากว่ากำหนด")
   - ผู้ให้บริการและเจ้าของรถมีสิทธิเรียกคืนรถตามเงื่อนไขในสัญญา

6. **คืนก่อนกำหนด**
   - หากผู้เช่าคืนรถก่อนกำหนด ระบบจะมีปุ่มให้ผู้เช่าแจ้งการคืนรถล่วงหน้า พร้อมคืนเงินตามระยะเวลาที่ไม่ได้ใช้งาน
   - การคืนก่อนกำหนดจะมีการยึดมัดจำ เพราะผู้เช่าไม่ปฏิบัติตามเงื่อนไขที่กำหนด

7. **การตรวจสอบรถก่อนคืน**
   - เจ้าของรถจะตรวจสอบสภาพรถต่อหน้าผู้เช่า โดยตรวจสอบความเสียหายที่เกิดขึ้นและระยะทางที่ใช้ไป
   - ผู้เช่าต้องลงนามในรายงานการตรวจสอบเพื่อยืนยันการคืนรถ

8. **เอกสารและหลักฐานในวันคืนรถ**
   - ผู้เช่าต้องนำเอกสารการจอง, ใบอนุญาตขับขี่ และบัตรประชาชน/พาสปอร์ตมาประกอบการคืนรถ
   - หากมีค่าธรรมเนียมเพิ่มเติม ผู้เช่าต้องชำระเงินก่อนการคืนรถจะเสร็จสมบูรณ์

---

#### **5. เงื่อนไขกรณีรถเกิดอุบัติเหตุหรือความเสียหาย**

1. **การแจ้งเหตุทันที**
   - หากรถเกิดอุบัติเหตุหรือพบปัญหาระหว่างการใช้งาน ผู้เช่าต้องแจ้งเจ้าของรถและฝ่ายบริการของแอปทันที
   - ผู้เช่าต้องแจ้งข้อมูลสำคัญ เช่น วันที่, เวลาที่เกิดเหตุ, สถานที่, ลักษณะความเสียหาย, และภาพถ่ายของเหตุการณ์

2. **กรณีเกิดอุบัติเหตุทางถนน**
   - ผู้เช่าต้องแจ้งตำรวจและดำเนินการตามขั้นตอนทางกฎหมาย
   - ให้ข้อมูลเกี่ยวกับคู่กรณี เช่น ทะเบียนรถ, ประกันภัย และข้อมูลติดต่อ

3. **ความรับผิดชอบของผู้เช่า**
   - ผู้เช่าต้องรับผิดชอบค่าเสียหายที่ไม่ได้ครอบคลุมในประกัน
   - หากรถมีประกัน ผู้เช่าต้องรับผิดชอบส่วนแรก (Deductible)

4. **ความรับผิดชอบของเจ้าของรถ**
   - เจ้าของรถต้องจัดเตรียมเอกสารประกันภัยที่ครอบคลุม
   - ชี้แจงเงื่อนไขประกันภัยและค่าเสียหายส่วนแรกให้ชัดเจน

5. **กรณีปัญหาทางกลไกหรือรถเสีย**
   - หากรถเสียโดยไม่เกิดจากการใช้งานผิดวิธี ผู้ให้บริการต้องรับผิดชอบค่าซ่อมแซมหรือจัดหารถทดแทน
   - หากเกิดจากการใช้งานผิดวิธี ผู้เช่าต้องรับผิดชอบค่าใช้จ่ายในการซ่อมแซม

6. **ค่าชดเชยกรณีรถใช้งานไม่ได้**
   - หากรถเสียจนไม่สามารถใช้งานได้ ผู้เช่าต้องรับผิดชอบค่าชดเชยตามอัตราที่ระบุในสัญญา

7. **ขั้นตอนหลังเหตุการณ์**
   - ผู้เช่าต้องให้ความร่วมมือในการจัดทำเอกสารและใบรับรอง
   - เจ้าของรถและผู้เช่าจะต้องตรวจสอบสภาพรถร่วมกัน

8. **ข้อจำกัดของแอปพลิเคชัน**
   - แอปพลิเคชันเป็นเพียงตัวกลางในการเชื่อมต่อระหว่างผู้เช่าและเจ้าของรถ

---

#### **6. เงื่อนไขการต่อระยะเวลาการเช่า**

1. **การแจ้งขยายระยะเวลาการเช่า**
   - ผู้เช่าต้องแจ้งล่วงหน้าไม่น้อยกว่า **6 ชั่วโมง** ก่อนเวลาสิ้นสุดการเช่า
   - การขยายระยะเวลาจะขึ้นอยู่กับดุลยพินิจของเจ้าของรถ

2. **การชำระเงินเพิ่มเติม**
   - ผู้เช่าต้องชำระเงินส่วนเพิ่มตามอัตราที่ตกลงกัน

3. **อัตราค่าเช่าและเงื่อนไขพิเศษ**
   - ค่าเช่าระหว่างการขยายจะคิดตามอัตราเดิม
   - เจ้าของรถอาจกำหนดเงื่อนไขเพิ่มเติม

4. **การยกเลิกและการคืนเงิน**
   - หากผู้เช่ายกเลิกก่อนกำหนด จะคืนเงินบางส่วนตามเงื่อนไข
   - หากยกเลิกหลังจากเริ่มเช่าแล้ว จะไม่คืนเงิน

5. **การอัปเดตเอกสาร**
   - ระบบจะอัปเดตเอกสารการเช่าและส่งให้ทั้งผู้เช่าและเจ้าของรถ

""",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text("ตกลง", style: TextStyle(color: Colors.blue)),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      },
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("โปรดกรอกข้อมูลให้ครบถ้วน")),
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password กับ Confirm Password ไม่ตรงกัน")),
      );
      return;
    }
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("โปรดยอมรับเงื่อนไขการสมัครก่อน")),
      );
      return;
    }
    try {
      // สร้างผู้ใช้งานด้วย Firebase Auth
      UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
      );

      if (cred.user != null) {
        String formattedPhone = formatThaiPhone(_phoneController.text.trim());
        await FirebaseFirestore.instance.collection("users").doc(cred.user!.uid).set({
          "username": _usernameController.text.trim(),
          "email": _emailController.text.trim().toLowerCase(),
          "password": _passwordController.text,
          "phone": formattedPhone,
          "address": {
            "province": null,
            "district": null,
            "subdistrict": null,
            "postalCode": null,
            "moreinfo": null,
          },
          "image": {},
          "rentedCars": [],
          "ownedCars": [],
        });
        await FirebaseFirestore.instance.collection("payments").doc(cred.user!.uid).set({"mypayment": 0});
        await FirebaseFirestore.instance.collection("otp_codes").doc(formattedPhone).set({
          'otp': "",
          'createdAt': FieldValue.serverTimestamp(),
          'expireAt': null,
          'used': false,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("สมัครสมาชิกสำเร็จ!")),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String msg = "เกิดข้อผิดพลาด";
      if (e.code == 'email-already-in-use') {
        msg = "อีเมลนี้ถูกใช้ไปแล้ว";
      } else if (e.code == 'weak-password') {
        msg = "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร";
      } else if (e.code == 'invalid-email') {
        msg = "อีเมลไม่ถูกต้อง";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: _firebaseInitialization,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(child: Text("${snapshot.error}")),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          body: Stack(
            children: [
              // พื้นหลังเต็มหน้าจอ
              Positioned.fill(
                child: Image.asset(
                  "assets/image/background.png",
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    width: screenWidth * 0.9,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ปุ่มปิด (X) ที่มุมขวาบน
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 30,
                                  color: Colors.black,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          Center(
                            child: Text(
                              "สร้างบัญชี",
                              style: TextStyle(
                                fontSize: screenWidth * 0.07,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(label: "Username", controller: _usernameController, icon: Icons.person),
                          _buildTextField(label: "Gmail", controller: _emailController, keyboard: TextInputType.emailAddress, icon: Icons.email),
                          _buildTextField(label: "Phone", controller: _phoneController, keyboard: TextInputType.phone, icon: Icons.phone),
                          _buildTextField(label: "Password", controller: _passwordController, obscure: true, icon: Icons.lock),
                          _buildTextField(label: "Confirm Password", controller: _confirmPasswordController, obscure: true, icon: Icons.lock_outline),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Checkbox(
                                value: _acceptedTerms,
                                onChanged: (val) {
                                  setState(() {
                                    _acceptedTerms = val ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _showTermsAndConditions,
                                  child: Text(
                                    "ฉันยอมรับข้อกำหนดการใช้งาน",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _signUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00377E),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  "ยืนยัน",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
