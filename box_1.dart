import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:chatbox_app/login/login.dart';
import 'package:flutter_svg/flutter_svg.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
final GoogleSignIn _googleSign = GoogleSignIn(scopes: ['email']);
class Box extends StatefulWidget {
  const Box({super.key});
  @override
  State<Box> createState() => _BoxState();
}
class _BoxState extends State<Box> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          Positioned(
            top: -(w / 3),
            right: 50,
            child: Transform.rotate(
              angle: 50 * math.pi / 180,
              child: Container(
                height: w * 1.5,
                width: w / 5 * 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(200),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 100,
                      spreadRadius: 10,
                      color: const Color(0xFF43116A).withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image(
                            image: AssetImage('assets/font/box.png'),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                      Padding(padding:EdgeInsets.all(10)),
                      Text('Connect', style: TextStyle(fontSize: 60, color: Colors.white)),
                      Text('friends', style: TextStyle(fontSize: 60, color: Colors.white)),
                      Text('easily &',
                          style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('quickly',
                          style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white)),
                      Padding(padding:EdgeInsets.all(20)),
                      Text(
                        'Our chat app is the perfect way to stay\nconnected with friends and family.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Color(0xB9C1C1BE)),
                      ),
                      Padding(padding:EdgeInsets.all(16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialIcon(asset: 'assets/icon/facebook.svg', onTap: _loginWithFacebook),
                          Padding(padding:EdgeInsets.all(20)),
                          _socialIcon(asset: 'assets/icon/google.svg', onTap: _loginWithGoogle),
                          Padding(padding:EdgeInsets.all(20)),
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
                      Padding(padding:EdgeInsets.all(10)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                                color: Color(0xFFD6E4E0), thickness: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFD6E4E0),
                                  decoration: TextDecoration.none),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                                color: Color(0xFFD6E4E0), thickness: 1),
                          ),
                        ],
                      ),
                      Padding(padding:EdgeInsets.all(5)),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _signInWithGoogle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Sign up with Google',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Existing account? ',
                            style: TextStyle(color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => login()),
                              );
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(padding:EdgeInsets.all(50)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
  Widget _socialIcon({required String asset, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }
  Future<void> _signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      print(" Signed in as: ${userCredential.user?.displayName}");
    } catch (e) {
      print(" Google Sign-In Error: $e");
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
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        _goToHome();
      } else {
        _showErrorDialog("Google Login", "Authentication failed.");
      }
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
        final accessToken = result.accessToken;
        final credential = FacebookAuthProvider.credential(accessToken!.token);

        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        if (userCredential.user != null) {
          _goToHome();
        } else {
          _showErrorDialog("Facebook Login", "Authentication failed.");
        }
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

      final userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      if (userCredential.user != null) {
        _goToHome();
      } else {
        _showErrorDialog("Apple Login", "Authentication failed.");
      }
    } catch (e) {
      _showErrorDialog("Apple Login Error", e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }
  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Text("Đăng nhập thành công!", style: TextStyle(fontSize: 24)),
          ),
        ),
      ),
    );
  }
}
