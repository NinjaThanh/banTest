import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B3A2F),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              "Settings",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration:BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Container(
                        width: 56,
                        height: 4,
                        decoration: BoxDecoration(
                          color:Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      SizedBox(height: 18),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: AssetImage('assets/images/MyStatus.png'),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Nazrul Islam",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Never give up 💪",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color:Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding:EdgeInsets.all(6),
                              child: Icon(
                                Icons.qr_code_2_rounded,
                                color: Color(0xFF0F172A),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding:EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration:BoxDecoration(
                                color: Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              child:Icon(Icons.vpn_key_outlined,
                                  color: Color(0xFF0F172A), size: 22),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Account",
                                      style: TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(height: 3),
                                  Text("Privacy, security, change number",
                                      style: TextStyle(
                                          color: Color(0xFF9CA3AF), fontSize: 13)),
                                ],
                              ),
                            ),
                             Icon(Icons.chevron_right_rounded,
                                color: Color(0xFF9CA3AF), size: 22),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 80),
                        child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration:BoxDecoration(
                                color: Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.chat_bubble_outline,
                                  color: Color(0xFF0F172A), size: 22),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Chat",
                                      style: TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(height: 3),
                                  Text("Chat history, theme, wallpapers",
                                      style: TextStyle(
                                          color: Color(0xFF9CA3AF), fontSize: 13)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 22),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 80),
                        child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                      ),

                      Padding(
                        padding:EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration:BoxDecoration(
                                color: Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              child:Icon(Icons.notifications_none_rounded,color: Color(0xFF0F172A), size: 22),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Notifications",
                                      style: TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(height: 3),
                                  Text("Messages, group and others",
                                      style: TextStyle(
                                          color: Color(0xFF9CA3AF), fontSize: 13)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 22),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 80),
                        child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                      ),
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration:BoxDecoration(
                                color: Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.trending_up_rounded, color: Color(0xFF0F172A), size: 22),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Storage and data",
                                      style: TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(height: 3),
                                  Text("Network usage, storage usage",
                                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 22),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 80),
                        child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                      ),
                      Padding(
                        padding:EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              child:Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF0F172A), size: 22),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text("Invite a friend",
                                  style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                            Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 22),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 80),
                        child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
