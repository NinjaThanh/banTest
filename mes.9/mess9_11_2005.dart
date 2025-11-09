// lib/home/messages_page.dart
// ignore: unused_import
import 'dart:ui' show lerpDouble;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';

/* ===================== DATA MODELS ===================== */

class Story {
  final String id;
  final String name;
  final String avatarUrl;
  final DateTime updatedAt;
  final bool hasNew;
  final double seenProgress;
  final Color ringColor;
  Story({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.updatedAt,
    required this.hasNew,
    required this.seenProgress,
    required this.ringColor,
  });
}

class MyStatus {
  final String name;
  final String? avatarUrl; // network (photoURL) hoặc asset
  MyStatus({this.name = 'My status', this.avatarUrl});
}

class ChatItem {
  final String avatar; // asset path (hoặc có thể là network sau này)
  final String title;
  final String subtitle;
  final String time;
  final int unread;
  ChatItem({
    required this.avatar,
    required this.title,
    required this.subtitle,
    required this.time,
    this.unread = 0,
  });
}

/* ===================== MOCK GENERATOR ===================== */

final _rand = Random();

final _ringPalette = <Color>[
  const Color(0xFFF1C40F),
  const Color(0xFF3498DB),
  const Color(0xFFE67E22),
  const Color(0xFF9B59B6),
  const Color(0xFF2ECC71),
];

final _names = ['Adil', 'Marina', 'Dean', 'Max', 'Hannah', 'Linh', 'An', 'Dũng'];

final _avatarAssets = [
  'assets/images/Adil.png',
  'assets/images/Marina.png',
  'assets/images/Dean.png',
  'assets/images/Max.png',
  'assets/images/John.png',
  'assets/images/AlexLinderson.png',
  'assets/images/AngelDayna.png',
  'assets/images/TeamAlign.jpg',
];

List<Story> generateMockStories({int count = 6}) {
  final now = DateTime.now();
  return List.generate(count, (i) {
    final hasNew = _rand.nextDouble() < 0.7;
    return Story(
      id: 'u$i',
      name: _names[i % _names.length],
      avatarUrl: _avatarAssets[i % _avatarAssets.length],
      updatedAt: now.subtract(
        Duration(hours: _rand.nextInt(24), minutes: _rand.nextInt(60)),
      ),
      hasNew: hasNew,
      seenProgress: hasNew ? 0 : _rand.nextDouble(),
      ringColor: _ringPalette[_rand.nextInt(_ringPalette.length)],
    );
  });
}

List<ChatItem> generateMockChats() {
  // Đồng bộ dùng avatar từ _avatarAssets
  return [
    ChatItem(
      avatar: _avatarAssets[5], // AlexLinderson
      title: 'Alex Linderson',
      subtitle: 'How are you today?',
      time: '2 min ago',
      unread: 3,
    ),
    ChatItem(
      avatar: _avatarAssets[7], // TeamAlign
      title: 'TeamAlign',
      subtitle: 'Don’t miss to attend the meeting.',
      time: '5 min ago',
      unread: 4,
    ),
    ChatItem(
      avatar: _avatarAssets[4], // John
      title: 'John Ahraham',
      subtitle: 'Hey! Can you join the meeting?',
      time: '8 min ago',
      unread: 0,
    ),
    ChatItem(
      avatar: _avatarAssets[3], // Max
      title: 'John Borino',
      subtitle: 'Have a good day 🌸',
      time: '15 min ago',
    ),
    ChatItem(
      avatar: _avatarAssets[6], // AngelDayna
      title: 'Angel Dayna',
      subtitle: 'How are you today?',
      time: '20 min ago',
    ),
  ];
}

/* ===================== PAGE ===================== */

class MessagesPage extends StatefulWidget {
  final User? user; // nhận user từ ngoài
  const MessagesPage({super.key, this.user});

  @override
  MessagesPageState createState() => MessagesPageState();
}

class MessagesPageState extends State<MessagesPage> {
  static const bgDark = Color(0xFF0E0800);
  static const timeColor = Color(0xFF9CA3AF);
  static const badgeColor = Color(0xFFD51B0A);
  late final User? _user;
  late final MyStatus me;
  late final List<Story> stories;
  late final List<ChatItem> chats;

  String _userDisplayName(User? u) {
    final dn = u?.displayName?.trim();
    if (dn != null && dn.isNotEmpty) return dn;
    final em = u?.email;
    if (em != null && em.isNotEmpty) return em.split('@').first;
    return 'My status';
  }

  ImageProvider _imageProviderFrom(String? urlOrAsset) {
    if (urlOrAsset == null || urlOrAsset.isEmpty) {
      return const AssetImage('assets/images/MyStatus.png');
    }
    if (urlOrAsset.startsWith('http')) {
      return NetworkImage(urlOrAsset);
    }
    return AssetImage(urlOrAsset);
  }

  @override
  void initState() {
    super.initState();
    _user = widget.user ?? FirebaseAuth.instance.currentUser;

    // ✅ MyStatus: ưu tiên photoURL, fallback avatar list
    me = MyStatus(
      name: _userDisplayName(_user),
      avatarUrl: _user?.photoURL ?? _avatarAssets[0],
    );

    stories = generateMockStories(count: 8);
    chats = generateMockChats();
  }

  @override
  Widget build(BuildContext context) {
    final actionAvatar = _imageProviderFrom(me.avatarUrl);

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x22121212),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 22),
              onPressed: () {},
            ),
          ),
        ),
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CircleAvatar(backgroundImage: actionAvatar),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: bgDark,
            height: 112,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 1 + stories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, index) {
                if (index == 0) {
                  final myImg = _imageProviderFrom(me.avatarUrl);
                  return _MyStatusBubble(image: myImg, name: me.name);
                }
                final s = stories[index - 1];
                return _StoryBubble(
                  name: s.name,
                  avatarAsset: s.avatarUrl,
                  ringColor: s.hasNew ? s.ringColor : const Color(0xFF9CA3AF),
                );
              },
            ),
          ),

          // ===== Chats =====
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(38),
                  topRight: Radius.circular(38),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Grab handle
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6EAF0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Divider(height: 1, color: Color(0xFFE8EDF3)),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                      itemCount: chats.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        thickness: 0.6,
                        color: Color(0xFFE8EDF3),
                      ),
                      itemBuilder: (context, i) {
                        final c = chats[i];
                        return slidableTile(
                          avatar: c.avatar,
                          title: c.title,
                          subtitle: c.subtitle,
                          time: c.time,
                          unread: c.unread,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget slidableTile({
    required String avatar,
    required String title,
    required String subtitle,
    required String time,
    int unread = 0,
  }) {
    return Slidable(
      key: ValueKey(title),
      closeOnScroll: true,
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.46,
        children: [
          SlidableAction(
            onPressed: (context) =>
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('More on $title'))),
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            icon: Icons.more_horiz,
            label: 'More',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (context) =>
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete $title'))),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(radius: 26, backgroundImage: AssetImage(avatar)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _MyStatusBubble extends StatelessWidget {
  final ImageProvider image;
  final String name;
  const _MyStatusBubble({required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Vòng trắng
              const Positioned.fill(
                child: CustomPaint(
                  painter: ArcPainter(
                    startAngle: -0.3,
                    sweepAngle: 2.3,
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
              // Vòng xám
              const Positioned.fill(
                child: CustomPaint(
                  painter: ArcPainter(
                    startAngle: 3.8,
                    sweepAngle: 1.9,
                    color: Color(0xFF797C7B),
                    strokeWidth: 3,
                  ),
                ),
              ),
              CircleAvatar(radius: 25, backgroundImage: image, backgroundColor: Colors.transparent),
              Positioned(
                bottom: -3,
                right: -3,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black87, width: 1.5),
                  ),
                  child: const Icon(Icons.add, size: 13, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 76,
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
class _StoryBubble extends StatelessWidget {
  final String name;
  final String avatarAsset;
  final Color ringColor; // giữ API cũ cho tương thích
  const _StoryBubble({
    required this.name,
    required this.avatarAsset,
    required this.ringColor,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x5524786D),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                startAngle: 0,
                endAngle: 6.283,
                colors: const [
                  Color(0xFF2ECC71),
                  Color(0xFF3498DB),
                  Color(0xFFE67E22),
                  Color(0xFF9B59B6),
                  Color(0xFF2ECC71),
                ],
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0B1712),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2.5),
              child: CircleAvatar(backgroundImage: AssetImage(avatarAsset)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 76,
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.1,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
class ArcPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;
  final Color color;
  final double strokeWidth;
  const ArcPainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.color,
    required this.strokeWidth,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(3), startAngle, sweepAngle, false, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
