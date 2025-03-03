import 'package:flutter/material.dart';

class MessteamPage extends StatelessWidget {
  const MessteamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(
                'assets/images/Adil2.jpg',
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jhon Abraham',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Active now',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call),
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.videocam),
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: Column(children: [
        ElevatedButton(
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 80),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(
                        'assets/images/jhon.jpg',
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Have a great working week!!',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Hello! Jhon abraham",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 180),
                        child: Text(
                          '09:25 AM',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return SizedBox(
                  height: 800,
                  child: Column(
                    children: [
                      ElevatedButton(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(Icons.crop_3_2)),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 180),
                                  child: Text(
                                    "Share Content",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                      // ignore: avoid_unnecessary_containers
                      Container(
                          child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.camera_alt_rounded)),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                          Column(
                            children: [
                              Text(
                                "Camera",
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          )
                        ],
                      )),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                      // ignore: avoid_unnecessary_containers
                      Container(
                          child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.document_scanner_outlined)),
                          Column(
                            children: [
                              Text(
                                "Documents",
                                style: TextStyle(fontSize: 20),
                              ),
                              Text("Share your files"),
                            ],
                          )
                        ],
                      )),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                      // ignore: avoid_unnecessary_containers
                      Container(
                          child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.add_chart_sharp)),
                          // Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                child: Text(
                                  "Create a poll",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              Text("Create a poll for any querry"),
                            ],
                          )
                        ],
                      )),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                      // ignore: avoid_unnecessary_containers
                      Container(
                          child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.perm_media_sharp)),
                          // Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                          Column(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Media", style: TextStyle(fontSize: 20)),
                              Text("Share photos and videos"),
                            ],
                          )
                        ],
                      )),
                      Container()
                    ],
                  ),
                );
              },
            );
          },
        ),
      ]),
    );
  }
}
