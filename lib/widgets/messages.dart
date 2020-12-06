import 'dart:convert';

import 'package:chat_app/models/user.dart';
import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Messages extends StatelessWidget {
  static const routeName = '/Messages';

  Future fetchMessages() async {
    String url = 'http://192.168.1.7:8000/api/messages';

    http.Response response = await http.get(url);
    List parsed = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return parsed;
    } else {
      throw Exception('Unable to fetch data from the REST API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchMessages(),
      builder: (ctx, snapShot) {
        if (snapShot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        // final docs = snapShot.data.docs;
        final List docs = snapShot.data;
        final userId = Users.id;

        return ListView.builder(
          reverse: true,
          itemCount: docs.length,
          itemBuilder: (ctx, index) => MessageBubble(
            // docs[index]['text'],
            docs[index]['body'],
            // docs[index]['userId'] == user.uid,
            docs[index]['user_id'] == userId,
            // key: ValueKey(docs[index].documentID),
            key: ValueKey(docs[index]['id']),
          ),
        );
      },
    );
  }
}
