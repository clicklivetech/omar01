import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        backgroundColor: const Color(0xFF6E58A8),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('صفحة الحساب الشخصي'),
      ),
    );
  }
}
