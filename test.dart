import 'package:flutter/material.dart';

class MesteamPage extends StatelessWidget {
  const MesteamPage({super.key});

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
                'assets/images/1.jpg',
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Team Align',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '8 members, 5 online',
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
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.videocam),
            color: Colors.black,
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20),
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
                    'Hafizur Rahman',
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
                      "Have a great working week!!",
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
          Padding(
            padding: EdgeInsets.symmetric(vertical: 3),
          ),

          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 160),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(
                    'assets/images/mu.png',
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Majharul Haque',
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
                      "Look at my work man!!",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  // ignore: avoid_unnecessary_containers
                  Container(
                    child: Row(
                      children: [
                        Padding(padding: EdgeInsets.symmetric(horizontal: 12)),
                        Image(image: AssetImage("assets/images/2.png"))
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 130),
                    child: Text(
                      '09:25 AM',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 3),
          ),
          
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 110),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/aneiellison.png'),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anei Ellison',
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
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow),
                        Image(
                            image: AssetImage('assets/images/rectangle1.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle2.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle3.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle4.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle5.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle6.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle7.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle8.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle9.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle10.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle11.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle12.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle13.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle14.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle15.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle16.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle17.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle18.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle19.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle20.png')),
                        Image(
                            image: AssetImage('assets/images/rectangle21.png')),
                        const Text(
                          '00:16',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 150),
                    child: Text(
                      '09:25 AM',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),

          Padding(padding: EdgeInsets.symmetric(vertical: 3)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'You',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24))),
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Hello ! Jhon abraham",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 125),
                child: Text(
                  '09:25 AM',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.attach_file_sharp),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey[200],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.file_copy),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.camera_alt_rounded),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.mic),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
# banTest
