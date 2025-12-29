import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  final User user;
  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final photo = user.photoURL;
    final name = (user.displayName ?? 'No name').trim();
    final email = (user.email ?? '').trim();

    return Scaffold(
      backgroundColor: const Color(0xFF091C14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF091C14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // ====== Header ======
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: const Color(0xFFFACC15),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFFE8EDF3),
                      backgroundImage: photo != null ? NetworkImage(photo) : null,
                      child: photo == null
                          ? const Icon(Icons.person, size: 40, color: Color(0xFF9CA3AF))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    name.isEmpty ? 'No name' : name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    email.isEmpty ? '@username' : '@${_toHandle(email)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.65),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ====== Bottom Sheet ======
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    _field(label: 'Display Name', value: name.isEmpty ? 'No name' : name),
                    const SizedBox(height: 16),
                    _field(label: 'Email Address', value: email.isEmpty ? '-' : email),
                    const SizedBox(height: 16),

                    // Bạn có thể thay 2 field này bằng dữ liệu Firestore sau:
                    _field(label: 'Address', value: '—'),
                    const SizedBox(height: 16),
                    _field(label: 'Phone Number', value: '—'),

                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const Text(
                          'Media Shared',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: Color(0xFF0A7C66),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 10),
                    SizedBox(
                      height: 78,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: i == 2
                              ? Center(
                                  child: Text(
                                    '255+',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black.withOpacity(0.75),
                                    ),
                                  ),
                                )
                              : const Icon(Icons.image_outlined, color: Color(0xFF6B7280)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _field({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF111827),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  static String _toHandle(String email) {
    final part = email.split('@').first;
    return part.isEmpty ? 'username' : part;
  }
}
