// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../post_box.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                  GestureDetector(
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                    },
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
                        "https://img.freepik.com/free-photo/brunette-woman-eating-salad_23-2148173212.jpg?w=1060&t=st=1697380186~exp=1697380786~hmac=99db5651d386b0bfc551eb5271df3548ed7d6c60e93f116db3e055ddf9a724b0",
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
