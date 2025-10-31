// lib/settings/settings_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsPage extends StatefulWidget {
  final User user;
  const SettingsPage({super.key, required this.user});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool uploading = false;
  final picker = ImagePicker();

  User? get _currentUser => FirebaseAuth.instance.currentUser ?? widget.user;

  String _contentTypeFromExt(String ext) {
    switch (ext.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
  Future<void> changeAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Chụp ảnh'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
    if (source == null) return;
    await pickAndUpload(source);
  }

  Future<void> pickAndUpload(ImageSource source) async {
    try {
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 92,
        maxWidth: 2000,
        maxHeight: 2000,
      );
      if (picked == null) return;

      final user = _currentUser;
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa đăng nhập — không thể cập nhật avatar.')),
        );
        return;
      }
      setState(() => uploading = true);
      final Uint8List bytes = await picked.readAsBytes();
      final uid = user.uid;
      final ext = (picked.name.split('.').last).toLowerCase();
      final contentType = _contentTypeFromExt(ext);

      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final ref = FirebaseStorage.instance.ref('avatars/$uid/$fileName');
      final task = await ref.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );
      final url = await task.ref.getDownloadURL();

      await user.updatePhotoURL(url);
      await user.reload();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật avatar thành công!')),
      );

      setState(() {}); // rebuild để nạp ảnh mới
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải ảnh: [${e.code}] ${e.message ?? ''}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi không xác định: $e')),
      );
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  Future<void> editDisplayName() async {
    final user = _currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa đăng nhập — không thể đổi tên.')),
      );
      return;
    }

    final controller = TextEditingController(text: user.displayName ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đổi tên hiển thị'),
        content: TextField(
          controller: controller,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            hintText: 'Tên của bạn',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => Navigator.pop(context, true),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Lưu')),
        ],
      ),
    );
    if (ok != true) return;
    final newName = controller.text.trim();
    if (newName.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên không được để trống.')),
      );
      return;
    }
    try {
      await user.updateDisplayName(newName);
      await user.reload();
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật tên hiển thị')),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật tên lỗi: ${e.message ?? e.code}')),
      );
    }
  }
  void _open(String route) => Navigator.of(context).pushNamed(route);
  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    final avatar = user?.photoURL;
    final cacheBust = avatar == null
        ? null
        : '$avatar${avatar.contains('?') ? '&' : '?'}v=${DateTime.now().millisecondsSinceEpoch}';
    return Scaffold(
      backgroundColor: const Color(0xFF091C14),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF091C14),
        foregroundColor: Colors.white,
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 56,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Header user
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: const Color(0xFFE8EDF3),
                              backgroundImage:
                              cacheBust != null ? NetworkImage(cacheBust) : null,
                              child: cacheBust == null
                                  ? const Icon(Icons.person,
                                  size: 34, color: Color(0xFF9CA3AF))
                                  : null,
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: uploading ? null : changeAvatar,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0A7C66),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    uploading
                                        ? Icons.hourglass_bottom
                                        : Icons.camera_alt_outlined,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: GestureDetector(
                            onTap: editDisplayName,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.displayName ?? 'No name',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? 'Never give up 💪',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.qr_code_2_rounded, color: Color(0xFF0A7C66)),
                          tooltip: 'Mã QR',
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF3F4F6),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.manage_accounts_outlined,
                                    color: Color(0xFF0F172A), size: 22),
                              ),
                              title: const Text('Account',
                                  style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              subtitle: const Text(
                                'Privacy, security, change number',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded,
                                  color: Color(0xFF9CA3AF), size: 22),
                              onTap: () => _open('/account'),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 80),
                              child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                            ),
                            ListTile(
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF3F4F6),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.chat_bubble_outline_rounded,
                                    color: Color(0xFF0F172A), size: 22),
                              ),
                              title: const Text('Chat',
                                  style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              subtitle: const Text(
                                'Chat history, theme, wallpapers',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded,
                                  color: Color(0xFF9CA3AF), size: 22),
                              onTap: () => _open('/chat'),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 80),
                              child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                            ),
                            ListTile(
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF3F4F6),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.notifications_none_rounded,
                                    color: Color(0xFF0F172A), size: 22),
                              ),
                              title: const Text('Notifications',
                                  style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              subtitle: const Text(
                                'Messages, group and others',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded,
                                  color: Color(0xFF9CA3AF), size: 22),
                              onTap: () => _open('/notifications'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset('assets/icon/Help.svg',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                              ),
                            ),
                            title: const Text(
                              'Help',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: const Text(
                              'Help center, contact us, privacy policy',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF9CA3AF),
                              size: 22,
                            ),
                            // onTap: () => _open('/help'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: uploading
                            ? null
                            : () async {
                          try {
                            await FirebaseAuth.instance.signOut();
                            if (!context.mounted) return;
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/', (_) => false);
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đăng xuất thất bại: $e')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A7C66),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                        label: const Text('Đăng xuất',
                            style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (uploading)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withOpacity(0.08),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
