// user_profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProfilePage extends StatefulWidget {
  final User user;
  const UserProfilePage({super.key, required this.user});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  // ===== Theme
  static const darkBg = Color(0xFF07130E);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF6B7280);
  static const brand = Color(0xFF24786D);

  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;

  // Demo media (thay bằng dữ liệu thật)
  List<String> media = <String>[
    // 'https://images.unsplash.com/photo-1502741338009-cac2772e18bc?w=400',
    // 'https://images.unsplash.com/photo-1518779578993-ec3579fee39f?w=400',

  ];
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
  Future<void> _pickAndUploadOne() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        imageQuality: 92,
      );
      if (file == null) return;

      setState(() => _uploading = true);

      final path = file.path;
      final dot = path.lastIndexOf('.');
      final ext =
      (dot != -1 && dot < path.length - 1) ? path.substring(dot + 1) : 'jpg';

      final uid = widget.user.uid;
      final objectName =
          'users/$uid/media/${DateTime.now().millisecondsSinceEpoch}.$ext';
      final ref = FirebaseStorage.instance.ref(objectName);

      await ref.putFile(
        File(path),
        SettableMetadata(contentType: _contentTypeFromExt(ext)),
      );
      final url = await ref.getDownloadURL();

      if (!mounted) return;
      setState(() => media.insert(0, url));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload thành công!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload lỗi: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }
  Future<void> _pickAndUploadMany() async {
    try {
      final files =
      await _picker.pickMultiImage(maxWidth: 2048, imageQuality: 92);
      if (files.isEmpty) return;
      setState(() => _uploading = true);
      final uid = widget.user.uid;
      final List<String> newUrls = [];
      for (final file in files) {
        final path = file.path;
        final dot = path.lastIndexOf('.');
        final ext =
        (dot != -1 && dot < path.length - 1) ? path.substring(dot + 1) : 'jpg';
        final objectName =
            'users/$uid/media/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        final ref = FirebaseStorage.instance.ref(objectName);
        await ref.putFile(
          File(path),
          SettableMetadata(contentType: _contentTypeFromExt(ext)),
        );
        final url = await ref.getDownloadURL();
        newUrls.add(url);
      }

      if (!mounted) return;
      setState(() => media.insertAll(0, newUrls));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tải lên ${newUrls.length} ảnh!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload lỗi: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  // ===== Gallery bottom sheet (mở tất cả ảnh)
  Future<void> _openGallery({int initialIndex = 0}) async {
    if (media.isEmpty) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, controller) {
              final _scrollCtrl = ScrollController(
                // ước lượng đưa gần vị trí ảnh
                initialScrollOffset: (initialIndex / 3).floor() * 120,
              );
              return Column(
                children: [
                  Container(
                    width: 38,
                    height: 4,
                    margin: const EdgeInsets.only(top: 10, bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Text(
                    'All Media (${media.length})',
                    style: const TextStyle(
                      color: brand,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // nút thêm nhiều ảnh
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: brand.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: _uploading ? null : _pickAndUploadMany,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_uploading)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: brand),
                                )
                              else
                                const Icon(Icons.add, color: brand),
                              const SizedBox(width: 8),
                              Text(
                                _uploading ? 'Đang tải lên...' : 'Thêm nhiều ảnh',
                                style: const TextStyle(
                                  color: brand,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: GridView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: media.length,
                      itemBuilder: (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(media[i], fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    final displayName =
    (user.displayName != null && user.displayName!.trim().isNotEmpty)
        ? user.displayName!.trim()
        : 'User';
    final email = user.email ?? '—';
    final phone = user.phoneNumber ?? '(not set)';
    final handle = '@${(user.email ?? displayName).split('@').first}';
    final String? photoUrl = user.photoURL;

    // Grid preview (3 ô/ hàng)
    const double hPad = 20;
    const double spacing = 12;

    final int n = media.length;
    final bool showViewAll = n > 0; // cho bấm khi có ít nhất 1 ảnh

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: darkBg,
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9D27D),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(3),
                    child: CircleAvatar(
                      backgroundImage: photoUrl != null
                          ? NetworkImage(photoUrl)
                          : const AssetImage('assets/avatar.png') as ImageProvider,
                      child: photoUrl == null
                          ? const Icon(Icons.person, color: Colors.white70)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 4),
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    handle,
                    style: const TextStyle(
                      color: Color(0xFFBBD1C8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0E1E18),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.more_horiz, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                transform: Matrix4.translationValues(0, -20, 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: hPad, vertical: 30),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const Text(
                      'Display Name',
                      style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      displayName,
                      style: const TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Email Address',
                      style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email,
                      style: const TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Address',
                      style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '33 street west subidbazar, sylhet',
                      style: TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Phone Number',
                      style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      phone,
                      style: const TextStyle(
                          color: textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Media Shared',
                            style: TextStyle(
                                color: textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (showViewAll)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => _openGallery(initialIndex: 0),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 6),
                                child: Text(
                                  'View All',
                                  style: TextStyle(
                                      color: brand,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // === PREVIEW GRID (3 cột) – luôn 2 ảnh đầu + ô “+x” nếu n≥3
                    GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      childAspectRatio: 1,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: () {
                        final tiles = <Widget>[];
                        Widget tappableImage(String url, int index) => Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _openGallery(initialIndex: index),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(url, fit: BoxFit.cover),
                            ),
                          ),
                        );
                        Widget addTile() => Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: _uploading ? null : _pickAndUploadOne,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: brand, width: 1.5),
                              ),
                              alignment: Alignment.center,
                              child: _uploading
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: brand),
                              )
                                  : const Icon(Icons.add,
                                  size: 28, color: brand),
                            ),
                          ),
                        );
                        final n = media.length;
                        if (n == 0) {
                          tiles.add(addTile());
                        } else if (n == 1) {
                          tiles..add(tappableImage(media[0], 0))..add(addTile());
                        } else if (n == 2) {
                          tiles
                            ..add(tappableImage(media[0], 0))
                            ..add(tappableImage(media[1], 1))
                            ..add(addTile());
                        } else {
                          
                          tiles.addAll([
                            tappableImage(media[0], 0),
                            tappableImage(media[1], 1),
                            Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => _openGallery(initialIndex: 2),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Image.network(
                                          media[2], fit: BoxFit.cover),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.55),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '+${n - 2}',
                                        style:TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            addTile(),
                          ]);
                        }
                        return tiles
                            .map(
                              (w) => ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: SizedBox.expand(child: w),
                          ),
                        )
                            .toList();
                      }(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
