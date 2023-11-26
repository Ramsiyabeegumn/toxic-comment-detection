import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class RejectedMessages extends StatefulWidget {
  const RejectedMessages({super.key});

  @override
  State<RejectedMessages> createState() => _RejectedMessagesState();
}

class _RejectedMessagesState extends State<RejectedMessages> {
  Future<List<Map<String, dynamic>>> getComments() async {
    final documentSnapshot = await FirebaseFirestore.instance
        .collection('comments')
        .doc('rejected')
        .get();

    final commentData = documentSnapshot.data();
    print(commentData);

    if (commentData != null) {
      return [commentData];
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
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
        ],
      ),
    );
  }
}
