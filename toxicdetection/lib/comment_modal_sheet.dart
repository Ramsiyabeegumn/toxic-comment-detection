// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, must_be_immutable

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommentModalSheet extends StatefulWidget {
  final String name;
  bool isOn = true;
  String dpurl;
  bool isLoading = false;
  List<Map<String, String>> comments = [];
  CommentModalSheet({super.key, required this.name, required this.dpurl});

  @override
  State<CommentModalSheet> createState() => _CommentModalSheetState();
}

class _CommentModalSheetState extends State<CommentModalSheet> {
  final TextEditingController commentText = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;

  Future<List<Map<String, dynamic>>> getComments() async {
    final documentSnapshot = await FirebaseFirestore.instance
        .collection('comments')
        .doc('comments')
        .get();

    final commentData = documentSnapshot.data();
    print(commentData);

    if (commentData != null) {
      return [commentData];
    } else {
      return [];
    }
  }

  void addComment() async {
    bool result = true;
    showDialog(
      context: context,
      barrierDismissible:
          false, // Dialog cannot be dismissed by clicking on the screen
      builder: (BuildContext context) {
        return CommentDialog();
      },
    );
    print('calling query');
    String url = 'http://10.0.2.2:5000/api?query=${commentText.text.trim()}';
    try {
      final res = await http.get(Uri.parse(url));
      print('result');
      print(jsonDecode(res.body));
      result = jsonDecode(res.body) == 'toxic' ? true : false;
    } catch (e) {
      print(e);
    }
    print(result);
    if (!result) {
      print('can be posted');

      final comment = {
        "user_name": widget.name,
        "comment_text": commentText.text,
        "dp_url": widget.dpurl,
      };

      try {
        await FirebaseFirestore.instance
            .collection("comments")
            .doc('comments')
            .set({
          "comments": FieldValue.arrayUnion(
            [comment],
          ),
        }, SetOptions(merge: true));
      } catch (e) {
        e.toString();
      }
      commentText.clear();
    } else {
      final comment = {
        "user_name": widget.name,
        "comment_text": commentText.text,
        "dp_url": widget.dpurl,
      };

      try {
        await FirebaseFirestore.instance
            .collection("comments")
            .doc('rejected')
            .set({
          "comments": FieldValue.arrayUnion(
            [comment],
          ),
        }, SetOptions(merge: true));
      } catch (e) {
        e.toString();
      }
      commentText.clear();
    }

    Navigator.of(context).pop();
    Navigator.of(context).pop();
    if (!result) {
      final snackBar = SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'yay',
          message: 'Your comment is added.',

          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.success,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    } else {
      final snackBar = SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'uh oh',
          message: 'That\'s a bad comment',

          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(children: [
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Row(
                  children: [
                    Text(
                      'Comments',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                  ],
                ),
              ),
              Row(children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (widget.isOn) {
                        widget.isOn = false;
                      } else {
                        widget.isOn = true;
                      }
                    });
                    final snackBar = SnackBar(
                      content: Text(
                          'Toxic comment detection is ${widget.isOn ? "On" : "Off"}'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: widget.isOn
                      ? Icon(
                          Icons.toggle_on_outlined,
                          color: Colors.green[600],
                        )
                      : Icon(Icons.toggle_off_outlined),
                ),
                const SizedBox(
                  width: 5,
                ),
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close)),
              ])
            ],
          ),
          const Divider(
            color: Color.fromARGB(255, 143, 143, 143),
          ),
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.dpurl),
                child: Container(
                  height: 20,
                  width: 20,
                  child: Text(''),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextField(
                  controller: commentText,
                  decoration: InputDecoration(
                    hintText: 'Add comment',
                    hintStyle: TextStyle(fontSize: 13),
                    border: InputBorder.none,
                  ),
                ),
              ),
              GestureDetector(
                  onTap: () {
                    addComment();
                  },
                  child: Icon(Icons.send)),
            ],
          ),
          const Divider(
            color: Color.fromARGB(255, 143, 143, 143),
          ),

          //here
          FutureBuilder<List<Map<String, dynamic>>>(
            future: getComments(),
            builder: (BuildContext context,
                AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (!snapshot.hasData || snapshot.data == []) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text('No comments found.'),
                    ),
                  ],
                );
              } else {
                print("found data");
                print(snapshot.data);
                if (snapshot.data!.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text('No comments found.'),
                      ),
                    ],
                  );
                } else {
                  return Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data![0]['comments'].length,
                            itemBuilder: (BuildContext context, int index) {
                              final comment =
                                  snapshot.data![0]['comments'][index];

                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 20,
                                  child: ClipOval(
                                    child: FadeInImage.memoryNetwork(
                                      placeholder: kTransparentImage,
                                      image: comment['dp_url'],
                                      fit: BoxFit.cover,
                                      width: 36,
                                      height: 36,
                                    ),
                                  ),
                                ),
                                title: Text(comment['user_name']),
                                subtitle: Text(comment['comment_text']),
                              );
                              //

                              //
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
          //
        ]),
      ),
    );
  }
}

class CommentDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16.0),
            Text('Let me check the comment first.'),
          ],
        ),
      ),
    );
  }
}
