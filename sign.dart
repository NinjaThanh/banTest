import 'package:flutter/material.dart';
import 'package:chatbox_app/chatbox_them/them.dart';

class Sign extends StatefulWidget {
  const Sign({super.key});
  @override
  SignState createState() => SignState();
}
class SignState extends State<Sign> {
  final form = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool validate = false;
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
  void saveForm() {
    if (form.currentState?.validate() ?? false) {
      print('Name: ${nameController.text}');
      print('Email: ${emailController.text}');
      print('Password: ${passwordController.text}');
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
    } else {
      setState(() {
        validate = true;
      });
    }
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFCDD1D0),
        fontSize: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(  color:ChatboxCourseAppTheme.themGrayishGreenishGray, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color:ChatboxCourseAppTheme.themDarkjadegreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color:ChatboxCourseAppTheme.thembrightorange, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color:ChatboxCourseAppTheme.thembrightorange, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: ChatboxCourseAppTheme.themmossygreenishblack,
            onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: ChatboxCourseAppTheme.themwhite,
      ),
      backgroundColor: ChatboxCourseAppTheme.themwhite,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 20),
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Sign up with Email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ChatboxCourseAppTheme.themmossygreenishblack,
                  ),
                ),
                Padding(padding:EdgeInsets.all(8)),
                const Text(
                  'Get chatting with friends and family today by signing up for our chat app!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: ChatboxCourseAppTheme.themGrayishGreenishGray
                  ),
                ),
                Padding(padding:EdgeInsets.all(30)),
                TextFormField(
                  controller: nameController,
                  decoration: inputDecoration("Your Name"),
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Name cannot be empty!';
                    }
                    if (text.length < 5) {
                      return 'Valid name (min 5 characters).';
                    }
                    return null;
                  },
                ),
                Padding(padding:EdgeInsets.all(16)),
                TextFormField(
                  controller: emailController,
                  decoration: inputDecoration("Your Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Email cannot be empty!';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(text)) {
                      return 'Valid email address!';
                    }
                    return null;
                  },
                ),
                Padding(padding:EdgeInsets.all(16)),
                TextFormField(
                  controller: passwordController,
                  decoration: inputDecoration("Password"),
                  obscureText: true,
                  validator: (password) {
                    if (password == null || password.isEmpty) {
                      return 'Password cannot be empty!';
                    }
                    if (password.length < 6) {
                      return 'Password must be at least 6 characters long!';
                    }
                    return null;
                  },
                ),
                Padding(padding:EdgeInsets.all(16)),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: inputDecoration("Confirm Password"),
                  obscureText: true,
                  validator: (confirmPassword) {
                    if (confirmPassword == null || confirmPassword.isEmpty) {
                      return 'Confirm Password cannot be empty!';
                    }
                    if (confirmPassword != passwordController.text) {
                      return 'Passwords do not match!';
                    }
                    return null;
                  },
                ),
                Padding(padding:EdgeInsets.all(40)),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ChatboxCourseAppTheme.themWhiteGray,
                    ),
                    child: const Text(
                      'Create an account',
                      style: TextStyle(
                        color: ChatboxCourseAppTheme.themGrayishGreenishGray,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
