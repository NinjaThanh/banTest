import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chatbox_app/sign/sign.dart';
import 'package:chatbox_app/chatbox_them/them.dart';
import 'package:chatbox_app/home/home.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  bool isLoading = false;
  bool isFormValid = false;
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  void goToHome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Home()),
    );
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
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hoá.';
      case 'user-not-found':
        return 'Không tìm thấy người dùng với email này.';
      case 'wrong-password':
        return 'Mật khẩu không đúng.';
      case 'too-many-requests':
        return 'Bạn thử quá nhiều lần. Vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Không có kết nối mạng. Vui lòng kiểm tra internet.';
      default:
        return 'Đăng nhập thất bại. ($code)';
    }
  }
  Future<void> loginWithEmailAndPassword() async {
    if (isLoading || !(formKey.currentState?.validate() ?? false)) return;
    setState(() => isLoading = true);
    try {
      final email = emailController.text.trim();
      final password = passwordController.text;
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        goToHome();
      } else {
        showErrorDialog('Login Failed', 'User not found.');
      }
    } on FirebaseAuthException catch (e) {
      showErrorDialog('Login Error', mapFirebaseError(e.code));
    } catch (e) {
      showErrorDialog('Login Error', e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
  Future<void> loginWithGoogle() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (mounted) setState(() => isLoading = false);
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCred.user != null) {
        goToHome();
      } else {
        showErrorDialog('Google Login', 'Authentication failed.');
      }
    } on FirebaseAuthException catch (e) {
      showErrorDialog('Google Login Error', mapFirebaseError(e.code));
    } catch (e) {
      showErrorDialog('Google Login Error', e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
  Future<void> loginWithApple() async {
    if (isLoading) return;
    if (!(Platform.isIOS || Platform.isMacOS)) {
      showErrorDialog(
        'Không hỗ trợ',
        'Apple Sign-In chỉ khả dụng trên iOS hoặc macOS.',
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final userCred = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      if (userCred.user != null) {
        goToHome();
      } else {
        showErrorDialog('Apple Login', 'Authentication failed.');
      }
    } on FirebaseAuthException catch (e) {
      showErrorDialog('Apple Login Error', mapFirebaseError(e.code));
    } catch (e) {
      showErrorDialog('Apple Login Error', e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
  Widget socialIcon({required String asset, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Opacity(
        opacity: isLoading ? 0.6 : 1,
        child: Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ChatboxCourseAppTheme.themwhite,
            border: Border.all(
              color: ChatboxCourseAppTheme.thempureBlack,
              width: 1.5,
            ),
          ),
          child: SvgPicture.asset(asset),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: ChatboxCourseAppTheme.themwhite,
      ),
      backgroundColor: ChatboxCourseAppTheme.themwhite,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction, // ✅
          onChanged: () {
            setState(() {
              isFormValid = formKey.currentState?.validate() ?? false;
            });
          },
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(40)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: const Text(
                  'Log in to Chatbox',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ChatboxCourseAppTheme.themmossygreenishblack,
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.all(8)),
              const Text(
                'Welcome back! Sign in using your social account or email to continue us',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const Padding(padding: EdgeInsets.all(15)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(padding: EdgeInsets.all(15)),
                  socialIcon(
                    asset: 'assets/icon/Google.svg',
                    onTap: loginWithGoogle,
                  ),
                  const Padding(padding: EdgeInsets.all(10)),
                  socialIcon(
                    asset: 'assets/icon/Apple.svg',
                    onTap: loginWithApple,
                  ),
                  const Padding(padding: EdgeInsets.all(10)),
                ],
              ),
              const Padding(padding: EdgeInsets.all(5)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: 14,
                          color: ChatboxCourseAppTheme.themLightBlueGray,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(thickness: 1)),
                  ],
                ),
              ),
              const Padding(padding: EdgeInsets.all(5)),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Your Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email cannot be empty!';
                  }
                  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                    return 'Enter a valid email address!';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {
                  isFormValid = formKey.currentState?.validate() ?? false;
                }),
              ),
              const Padding(padding: EdgeInsets.all(15)),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password cannot be empty!';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long!';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  if (isFormValid && !isLoading) loginWithEmailAndPassword();
                },
                onChanged: (_) => setState(() {
                  isFormValid = formKey.currentState?.validate() ?? false;
                }),
              ),
              const Padding(padding: EdgeInsets.all(30)),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                  isFormValid && !isLoading ? loginWithEmailAndPassword : null,
                  style: ElevatedButton.styleFrom(
                    // (Tuỳ chọn) bạn có thể thêm disabledBackgroundColor nếu muốn kiểm soát màu khi disabled
                    backgroundColor:
                    isFormValid ? const Color(0xFF24786D) : const Color(0xFF797C7B),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Log in', style: TextStyle(fontSize: 16)),
                ),
              ),
              const Padding(padding: EdgeInsets.all(15)),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Sign()),
                  );
                },
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
