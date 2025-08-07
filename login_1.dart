import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chatbox_app/login/sign.dart';
class login extends StatefulWidget {
  const login({super.key});
  @override
  State<login> createState() => _loginState();
}
class _loginState extends State<login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _googleSignIn = GoogleSignIn();
  bool _isLoading = false;
  bool _isFormValid = false;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const login()),
    );
  }
  Widget _socialIcon({required String asset, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(8),
        child: SvgPicture.asset(asset),
      ),
    );
  }
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }
  Future<void> _loginWithEmailAndPassword() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      userCredential.user != null
          ? _goToHome()
          : _showErrorDialog("Login Failed", "User not found.");
    } on FirebaseAuthException catch (e) {
      _showErrorDialog("Login Error", e.message ?? "Unknown error occurred.");
    } catch (e) {
      _showErrorDialog("Login Error", e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }
  Future<void> _loginWithGoogle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      userCredential.user != null
          ? _goToHome()
          : _showErrorDialog("Google Login", "Authentication failed.");
    } catch (e) {
      _showErrorDialog("Google Login Error", e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }
  Future<void> _loginWithFacebook() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final credential =
        FacebookAuthProvider.credential(result.accessToken!.token);
        final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

        userCredential.user != null
            ? _goToHome()
            : _showErrorDialog("Facebook Login", "Authentication failed.");
      } else {
        _showErrorDialog("Facebook Login", result.message ?? 'Login failed');
      }
    } catch (e) {
      _showErrorDialog("Facebook Login Error", e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithApple() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      userCredential.user != null
          ? _goToHome()
          : _showErrorDialog("Apple Login", "Authentication failed.");
    } catch (e) {
      _showErrorDialog("Apple Login Error", e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
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
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          onChanged: () {
            setState(() {
              _isFormValid = _formKey.currentState?.validate() ?? false;
            });
          },
          child: Column(
            children: [
              Padding(padding:EdgeInsets.all(40)),
              const Text(
                'Log in to Chatbox',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Padding(padding:EdgeInsets.all(8)),
              const Text(
                'Welcome back! Sign in using your social account or email to continue us',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Padding(padding:EdgeInsets.all(20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialIcon(asset: 'assets/icon/facebook.svg', onTap: _loginWithFacebook),
                  Padding(padding:EdgeInsets.all(15)),
                  _socialIcon(asset: 'assets/icon/google.svg', onTap: _loginWithGoogle),
                  Padding(padding:EdgeInsets.all(15)),
                  _socialIcon(
                    asset: 'assets/icon/apple.svg',
                    onTap: () {
                      if (Platform.isIOS || Platform.isMacOS) {
                        _loginWithApple();
                      } else {
                        _showErrorDialog("Không hỗ trợ", "Apple Sign-In chỉ khả dụng trên iOS hoặc macOS.");
                      }
                    },
                  ),
                ],
              ),
              Padding(padding:EdgeInsets.all(5)),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('OR', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ),
                    Expanded(child: Divider(thickness: 1)),
                  ],
                ),
              ),
              Padding(padding:EdgeInsets.all(5)),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Your Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email cannot be empty!';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) return 'Enter a valid email address!';
                  return null;
                },
              ),
              Padding(padding:EdgeInsets.all(15)),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration:InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Password cannot be empty!';
                  if (value.length < 6) return 'Password must be at least 6 characters long!';
                  return null;
                },
              ),
              Padding(padding:EdgeInsets.all(30)),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isFormValid ? _loginWithEmailAndPassword : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid ? Color(0xFF24786D) :Color(0xFF797C7B),
                  ),
                  child: _isLoading
                      ?  CircularProgressIndicator(color: Colors.white)
                      :  Text('Log in', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              Padding(padding:EdgeInsets.all(15)),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => sign()),
                  );
                },
                child: Text(
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
