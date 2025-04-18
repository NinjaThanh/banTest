import 'package:flutter/material.dart';
//import 'dart:ui' as ui;

class GroupCallPage extends StatefulWidget {
  const GroupCallPage({super.key});

  @override
  State<GroupCallPage> createState() => _GroupCallPageState();
}

class _GroupCallPageState extends State<GroupCallPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      fit: StackFit.expand,
      children: [
        generateBluredImage(),
        rectShapeContainer() ,
      ],
    ));
  }
  Widget generateBluredImage(){
     return Padding(padding: EdgeInsets.only(bottom: 160),
       child: Container(
         decoration: BoxDecoration(
           image: DecorationImage(
             image: AssetImage("assets/images/rectebgle1110.png"),
             fit: BoxFit.fitWidth
           )
         ),
         
       ),
     );
  }
  Widget rectShapeContainer() {
    return Padding(padding: EdgeInsets.only(),
        // ignore: avoid_unnecessary_containers
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Meeting with Lora Adom" ,selectionColor: Color(0xFFFFFFFF),
               style: TextStyle(fontSize: 50),
              ),
              // ignore: avoid_unnecessary_containers
              Container(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage("assets/images/marie.png"),
                      ),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                      Column(
                         crossAxisAlignment:CrossAxisAlignment.start,
                      children: [ 
                        Text("Lora Adom" , selectionColor: Color(0xFFFFFFFF),),
                        Text("Meeting organizer" , selectionColor: Color(0xDFE6F3DF),)
                      ],
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.all(80)),
                // ignore: avoid_unnecessary_containers
                Container(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage("assets/images/handsome.png"),
                      ),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                      Column(
                         crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        
                        Text("Dean Ronload" , selectionColor: Color(0xFFFFFFFF),),
                        Text("Sounds resonable" , selectionColor: Color(0xDFE6F3DF),)
                      ],
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.all(5)),
                // ignore: avoid_unnecessary_containers
                Container(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage("assets/images/annei.png"),
                      ),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                      Column(
                         crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        
                        Text("Annei Ellison" , selectionColor: Color(0xFFFFFFFF),),
                        Text("What about our profit?" , selectionColor: Color(0xDFE6F3DF),)
                      ],
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.all(5)),
                // ignore: avoid_unnecessary_containers
                Container(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage("assets/images/johnn.png"),
                      ),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                      Column(
                         crossAxisAlignment:CrossAxisAlignment.start,
                      children: [ 
                        Text("John Borino" , selectionColor: Color(0xFFFFFFFF),),
                        Text("What led you to this thought?" , selectionColor: Color(0xDFE6F3DF),)
                      ],
                      ),
                    ],
                  ),
                ),
              Positioned(
              bottom: 50,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  radius: 30,
                  child: IconButton(
                    icon: Icon(Icons.mic, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 25)),
                CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  radius: 30,
                  child: IconButton(
                    icon: Icon(Icons.volume_up, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 25)),
                CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  radius: 30,
                  child: IconButton(
                    icon: Icon(Icons.videocam, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 25)),
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 30,
                  child: IconButton(
                    icon: Icon(Icons.chat_bubble, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 25)),
                CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 30,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                )
              ],
            ),
          )
            ],
          ),
        );
  }
}
