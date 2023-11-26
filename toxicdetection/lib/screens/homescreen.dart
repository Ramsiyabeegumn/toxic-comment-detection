// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toxicdetection/screens/rejectedMessages.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import '../post_box.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<ItemModel> menuItems;
  CustomPopupMenuController _controller = CustomPopupMenuController();

  @override
  void initState() {
    menuItems = [
      ItemModel('Messages', Icons.chat_bubble),
      ItemModel('Logout', Icons.group_add),
    ];
    super.initState();
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<Map<String, dynamic>> getUserProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Reference to the Firestore collection
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      try {
        // Get the user's document
        DocumentSnapshot documentSnapshot = await users.doc(user.uid).get();

        // Extract the image URL from the document data
        // String imageUrl = documentSnapshot['img'];
        String username = documentSnapshot['name'];
        String imageUrl = documentSnapshot['img'];

        return {'imageUrl': imageUrl, 'username': username};
      } catch (e) {
        // Handle errors, e.g., user not found, Firestore error, etc.
        print('Error fetching user data: $e');
        throw e;
      }
    } else {
      // Handle the case where the user is not authenticated
      throw 'User not authenticated';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: getUserProfileData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // If the Future is still running, show a loading indicator
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            // If an error occurred, show an error message
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            String imageUrl = snapshot.data!['imageUrl'];
            String username = snapshot.data!['username'];
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                title: Text('Hello $username'),
                actions: [
                  // GestureDetector(
                  //   onTap: () {
                  //     FirebaseAuth.instance.signOut();
                  //   },
                  //   child: CircleAvatar(
                  //     radius: 20,
                  //     child: ClipOval(
                  //       child: FadeInImage.memoryNetwork(
                  //         placeholder: kTransparentImage,
                  //         image: imageUrl,
                  //         fit: BoxFit.cover,
                  //         width: 36,
                  //         height: 36,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  CustomPopupMenu(
                    child: Container(
                      child: CircleAvatar(
                        radius: 20,
                        child: ClipOval(
                          child: FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: imageUrl,
                            fit: BoxFit.cover,
                            width: 36,
                            height: 36,
                          ),
                        ),
                      ),
                      // padding: EdgeInsets.all(20),
                    ),
                    menuBuilder: () => ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        color: const Color(0xFF4C4C4C),
                        child: IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: menuItems
                                .map(
                                  (item) => GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        print("onTap");
                                        if (item.title == 'Logout') {
                                          FirebaseAuth.instance.signOut();
                                        } else {
                                          if (item.title == 'Messages') {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        RejectedMessages()));
                                          }
                                        }
                                        _controller.hideMenu();
                                      },
                                      child: item.title == 'Messages'
                                          ? FirebaseAuth.instance.currentUser!
                                                      .uid ==
                                                  'ZKdxIXM5C0gDRim3qnQzxgRiqvI2'
                                              ? Container(
                                                  height: 40,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Icon(
                                                        item.icon,
                                                        size: 15,
                                                        color: Colors.white,
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 10),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 10),
                                                          child: Text(
                                                            item.title,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Container()
                                          : Container(
                                              height: 40,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20),
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(
                                                    item.icon,
                                                    size: 15,
                                                    color: Colors.white,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 10),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10),
                                                      child: Text(
                                                        item.title,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    pressType: PressType.singleClick,
                    verticalMargin: -10,
                    controller: _controller,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
              body: ListView.builder(
                cacheExtent: 30,
                itemCount: 1,
                itemBuilder: (context, index) {
                  return PostBox(
                    // pid: post['postId'],
                    dpurl: imageUrl,
                    bio:
                        "Ignorance is blis✨. Find what you love. Do what you love.",
                    imageurl:
                        "https://img.freepik.com/free-photo/animal-lizard-nature-multi-colored-close-up-generative-ai_188544-9072.jpg?w=1380&t=st=1700300478~exp=1700301078~hmac=9636dd086da947eb91d51a9d91118bf5bd17605166ac603971a5fe82a6b6afb9",
                    location: "Transalvania",
                    name: username,
                  );
                },
              ),
            );
          }
        });
  }
}

class ItemModel {
  String title;
  IconData icon;

  ItemModel(this.title, this.icon);
}
