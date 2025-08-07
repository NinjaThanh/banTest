import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chatbox_app/splash/c.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization failed: $e");
  }
  bool isDebug = false;
  assert(() {
    isDebug = true;
    return true;
  }());
  if (!isDebug) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: C(),
    );
  }
}
