import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'phone_auth_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String phoneNumber;

  const ResetPasswordPage({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool isUpdating = false;

  Future<void> _updatePassword() async {
    setState(() {
      isUpdating = true;
    });
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(_passwordController.text.trim());
        Get.snackbar("Success", "Password changed successfully!");
        Get.offAll(() => const PhoneAuthPage());
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update password: $e");
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            isUpdating
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _updatePassword,
                    child: const Text("Update Password"),
                  ),
          ],
        ),
      ),
    );
  }
}
