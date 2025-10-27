import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatbox_app/chatbox_them/them.dart';

class Sign extends StatefulWidget {
  const Sign({super.key});
  @override
  SignState createState() => SignState();
}
class SignState extends State<Sign> {
  final form = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool validate = false;
  bool isLoading = false;
  bool showPass = false;
  bool showConfirm = false;
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
  void showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  String mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
      case 'auth/email-already-in-use':
        return 'Email đã được sử dụng.';
      case 'invalid-email':
      case 'auth/invalid-email':
        return 'Email không hợp lệ.';
      case 'weak-password':
      case 'auth/weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
      case 'operation-not-allowed':
      case 'auth/operation-not-allowed':
        return 'Phương thức đăng ký đang bị vô hiệu hóa.';
      case 'network-request-failed':
      case 'auth/network-request-failed':
        return 'Lỗi mạng. Vui lòng kiểm tra kết nối.';
      default:
        return 'Đăng ký thất bại. ($code)';
    }
  }
  Future<void> saveForm() async {
    if (isLoading) return;
    if (!(form.currentState?.validate() ?? false)) {
      setState(() => validate = true);
      return;
    }
    setState(() => isLoading = true);
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final pass = passwordController.text;
    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);
      await cred.user?.updateDisplayName(name);

      // 3) (Tuỳ chọn) gửi email xác minh
      // await cred.user?.sendEmailVerification();

      // 4) (Tuỳ chọn) lưu thông tin user vào Firestore
      //    -> chỉ dùng nếu bạn đã thêm cloud_firestore
      // import 'package:cloud_firestore/cloud_firestore.dart';
      // await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
      //   'fullName': name,
      //   'email': email,
      //   'createdAt': FieldValue.serverTimestamp(),
      // });

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Đăng ký thành công'),
          content: const Text('Bạn có thể đăng nhập bằng tài khoản vừa tạo.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      Navigator.pop(context); // ← trở về màn Login
    } on FirebaseAuthException catch (e) {
      showErrorDialog('Đăng ký lỗi', mapFirebaseError(e.code));
    } catch (e) {
      showErrorDialog('Đăng ký lỗi', e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
  InputDecoration inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFCDD1D0),
        fontSize: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: ChatboxCourseAppTheme.themGrayishGreenishGray,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: ChatboxCourseAppTheme.themDarkjadegreen,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: ChatboxCourseAppTheme.thembrightorange,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: ChatboxCourseAppTheme.thembrightorange,
          width: 2,
        ),
      ),
      suffixIcon: suffixIcon,
    );
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: ChatboxCourseAppTheme.themmossygreenishblack,
          onPressed: isLoading ? null : () => Navigator.pop(context),
        ),
        backgroundColor: ChatboxCourseAppTheme.themwhite,
      ),
      backgroundColor: ChatboxCourseAppTheme.themwhite,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 20),
        child: SingleChildScrollView(
          child: Form(
            key: form,
            autovalidateMode:
            validate ? AutovalidateMode.always : AutovalidateMode.disabled,
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
                    color: ChatboxCourseAppTheme.themGrayishGreenishGray,
                  ),
                ),
                Padding(padding:EdgeInsets.all(30)),
                TextFormField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
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
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  decoration: inputDecoration("Your Email"),
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
                  textInputAction: TextInputAction.next,
                  obscureText: !showPass,
                  decoration: inputDecoration(
                    "Password",
                    suffixIcon: IconButton(
                      icon: Icon(showPass ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => showPass = !showPass),
                    ),
                  ),
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
                  textInputAction: TextInputAction.done,
                  obscureText: !showConfirm,
                  onFieldSubmitted: (_) => saveForm(),
                  decoration: inputDecoration(
                    "Confirm Password",
                    suffixIcon: IconButton(
                      icon: Icon(showConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => showConfirm = !showConfirm),
                    ),
                  ),
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
                Padding(padding:EdgeInsets.all(16)),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : saveForm,
                    style: ElevatedButton.styleFrom(
                      // disabled vẫn theo theme của bạn (màu xám)
                      backgroundColor: isLoading
                          ? ChatboxCourseAppTheme.themWhiteGray
                          : ChatboxCourseAppTheme.themDarkjadegreen, // màu xanh chủ đạo
                    ),
                    child: isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text(
                      'Create an account',
                      style: TextStyle(
                        color: ChatboxCourseAppTheme.themwhite,
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
