
// ignore: unused_import
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});
  @override
  MessagesPageState createState() => MessagesPageState();
}
class MessagesPageState extends State<MessagesPage> {
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0E0800),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.search,
            color: Color(0xFFFFFFFF),
          ),
          onPressed: () {
          },
        ),
        title: Text(
          'Home',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage("assets/images/MyStatus.png"),
            ),
          ),
        ],
      ),
      body:Column(
        children: [
          Container(
            height: 100,
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: ListView(
              scrollDirection: Axis.horizontal,
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                Padding(padding: EdgeInsets.symmetric(vertical: 15.0)),
                // ignore: avoid_unnecessary_containers
                Container(
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage("assets/images/MyStatus.png"),
                            backgroundColor: Colors.transparent,
                          ),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: ArcPainter(
                                startAngle: -0.3,
                                sweepAngle: 2.3,
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: ArcPainter(
                                startAngle: 3.8,
                                sweepAngle: 1.9,
                                color: Color(0xFF797C7B),
                                strokeWidth: 3,
                              ),
                            ),
                          ),
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
                              child:Icon(Icons.add, size: 13, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "My status",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                // ignore: avoid_unnecessary_containers
                Container(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage("assets/images/Adil.png"),
                      ),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                      Text("Adil",
                          style: TextStyle(color: Color(0xFFFFFFFF))
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                // ignore: avoid_unnecessary_containers
                Container(
                  child:Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage("assets/images/Marina.png"),
                      ),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                      Text("Marina",
                          style: TextStyle(color: Color(0xFFFFFFFF))
                      ),
                    ],
                  ),
                ),


                Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                // ignore: avoid_unnecessary_containers
                Container(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage("assets/images/Dean.png"),
                      ),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                      Text("Dean",
                          style: TextStyle(color: Color(0xFFFFFFFF))
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                // ignore: avoid_unnecessary_containers
                Container(
                  child:Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/images/Max.png'),
                      ),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                      Text("Max",
                          style: TextStyle(color: Color(0xFFFFFFFF))
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child:
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child:  ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                    ),
                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Slidable(
                        key: const ValueKey(0),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("More tapped"),
                                  ),
                                );
                              },
                              backgroundColor: Colors.black45,
                              foregroundColor: Colors.white,
                              icon: Icons.more_horiz,
                              label: 'More',
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Delete tapped"),
                                  ),
                                );
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child:ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage('assets/images/AlexLinderson.png'),
                          ),
                          title: Text('Alex Linderson'),
                          subtitle: Text('How are you today?'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '2 min ago',
                                style: TextStyle(color: Color(0x797C7B79)),
                              ),
                              Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: Color(0xf04a4cf04a4c),
                                child: Text(
                                  '3',
                                  style: TextStyle(color: Color(0xFFFFFFFF)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Slidable(
                        // key: ValueKey(0),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("More tapped"),
                                  ),
                                );
                              },
                              backgroundColor: Colors.black45,
                              foregroundColor: Colors.white,
                              icon: Icons.more_horiz,
                              label: 'More',
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Delete tapped"),
                                  ),
                                );
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child:const ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage:
                            AssetImage('assets/images/TeamAlign.jpg'),
                          ),
                          title: Text('TeamAlign'),
                          subtitle: Text('Don’t miss to attend the meeting.'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('2 min ago' , selectionColor: Color(0x797C7B79),),
                              Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                              CircleAvatar(
                                radius: 10,
                                // ignore: use_full_hex_values_for_flutter_colors
                                backgroundColor: Color(0xf04a4cf04a4c),
                                child: Text('4',
                                    style:TextStyle(color: Color(0xFFFFFFFF))),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                    //ignore: avoid_unnecessary_containers
                    Container(
                      child: Slidable(
                        // key: const ValueKey(0),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("More tapped"),
                                  ),
                                );
                              },
                              backgroundColor: Colors.black45,
                              foregroundColor: Colors.white,
                              icon: Icons.more_horiz,
                              label: 'More',
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Delete tapped"),
                                  ),
                                );
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            radius: 25,
                            backgroundImage:
                            AssetImage('assets/images/John.png'),
                          ),
                          title: const Text('John Ahraham'),
                          subtitle: const Text('Hey! Can you join the meeting?'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const <Widget>[
                              Text('2 min ago',
                                  style: TextStyle(color: Color(0x797C7B79))),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 2
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Slidable(
                        key: const ValueKey(0),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("More tapped")),
                                );
                              },
                              backgroundColor: Colors.black45,
                              foregroundColor: Colors.white,
                              icon: Icons.more_horiz,
                              label: 'More',
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Delete tapped")),
                                );
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: const ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage:
                            AssetImage('assets/images/Max.png'),
                          ),
                          title: Text('John Borino'),
                          subtitle: Text('Have a good day 🌸'),
                          trailing: Column(
                            children: [
                              Text('2 min ago' , selectionColor: Color(0x797C7B79),)
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 1
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Slidable(
                        key: const ValueKey(0),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("More tapped"),
                                  ),
                                );
                              },
                              backgroundColor: Colors.black45,
                              foregroundColor: Colors.white,
                              icon: Icons.more_horiz,
                              label: 'More',
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Delete tapped"),
                                  ),
                                );
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: const ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage:
                            AssetImage('assets/images/Max.png'),
                          ),
                          title: Text('John Borino'),
                          subtitle: Text('Have a good day 🌸'),
                          trailing: Column(
                            children: [
                              Text('2 min ago' , selectionColor: Color(0x797C7B79),)
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                    // ignore: avoid_unnecessary_containers
                    Container(
                        child: Slidable(
                          key: const ValueKey(0),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("More tapped"),
                                    ),
                                  );
                                },
                                backgroundColor: Colors.black45,
                                foregroundColor: Colors.white,
                                icon: Icons.more_horiz,
                                label: 'More',
                              ),
                              SlidableAction(
                                onPressed: (context) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Delete tapped"),
                                    ),
                                  );
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: const ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundImage: AssetImage('assets/images/AngelDayna.png'),
                            ),
                            title: Text('AngelDayna'),
                            subtitle: Text('How are you today?'),
                            trailing: Column(
                              children: [
                                Text('2 min ago' , selectionColor: Color(0x797C7B79),)
                              ],
                            ),
                          ),
                        )
                    )
                  ],
                ),
              )
          ),
        ],
      ) ,
    );
  }
}
class ArcPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;
  final Color color;
  final double strokeWidth;
  ArcPainter({
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
