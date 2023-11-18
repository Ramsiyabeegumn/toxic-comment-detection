// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable

import 'package:boxicons/boxicons.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'comment_modal_sheet.dart';
import 'show_more.dart';

class PostBox extends StatefulWidget {
  PostBox({
    super.key,
    required this.name,
    required this.location,
    required this.imageurl,
    required this.dpurl,
    required this.bio,
  });
  final String name;
  final String location;
  final String imageurl;
  final String bio;
  final String dpurl;
  bool isLiked = true;

  @override
  State<PostBox> createState() => _PostBoxState();
}

class _PostBoxState extends State<PostBox> {
  @override
  Widget build(BuildContext context) {
    Widget _buildListItem(String title) {
      return Column(
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(child: Text(title)),
                ],
              ),
            ),
          ),
          const Divider(height: 0.5),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 236, 236, 236),
                spreadRadius: 3,
                blurRadius: 4,
              )
            ]),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        child: ClipOval(
                          child: FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: widget.dpurl,
                            fit: BoxFit.cover,
                            width: 36,
                            height: 36,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.name),
                          Text(
                            widget.location,
                            style: TextStyle(
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // GestureDetector(
                  //     onTap: () {
                  //       _showListAlert(context);
                  //     },
                  //     child: Icon(Boxicons.bx_dots_horizontal)),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                height: 400,
                child: GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(MaterialPageRoute(
                    //     builder: (_) => ReccomenadtionsScreen(
                    //           postId: pid,
                    //         )));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: widget.imageurl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      //herre
                      Column(
                        children: [
                          IconButton(
                            onPressed: () {
                              print('clicked');
                              print(widget.isLiked);
                              setState(() {
                                if (widget.isLiked) {
                                  widget.isLiked = false;
                                } else {
                                  widget.isLiked = true;
                                }
                              });
                              print(widget.isLiked);
                            },
                            icon: Icon(
                              Boxicons.bx_heart,
                              color: widget.isLiked ? Colors.red : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 16,
                      ),

                      Column(
                        children: [
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  context: context,
                                  builder: (context) {
                                    return Padding(
                                      padding:
                                          MediaQuery.of(context).viewInsets,
                                      child: CommentModalSheet(
                                        dpurl: widget.dpurl,
                                        name: widget.name,
                                      ),
                                    );
                                  });
                            },
                            icon: Icon(Boxicons.bx_comment),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              ExpandableShowMoreWidget(
                text: widget.bio,
                height: 80,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBarIcon extends StatelessWidget {
  const AppBarIcon({
    super.key,
    required this.iconData,
    required this.color,
    required this.iconColor,
  });
  final IconData iconData;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 236, 236, 236),
            spreadRadius: 3,
            blurRadius: 4,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          iconData,
          color: iconColor,
        ),
      ),
    );
  }
}
