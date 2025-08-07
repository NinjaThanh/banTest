import 'package:flutter/material.dart';
import 'package:chatbox_app/onboarding/box.dart';

class C extends StatefulWidget {
  const C({super.key});
  @override
  State<C> createState() => _CState();
}

class _CState extends State<C> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Box()),
        );
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset("assets/font/c.png", width: 120),
      ),
    );
  }
}
