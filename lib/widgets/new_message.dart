import 'dart:convert';

import 'package:chat_app/models/user.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/widgets/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

class NewMessage extends StatefulWidget {
  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = TextEditingController();
  String _enteredMessage = '';

  Future _sendMessage() async {
    FocusScope.of(context).unfocus();
    String url = 'http://192.168.1.7:8000/api/messages/create';
    http.Response response = await http
        .post(url, body: {"user_id": '${Users.id}', "body": _enteredMessage});
    // Map parsed = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // return parsed;
    } else {
      throw Exception('Unable to fetch data from the REST API');
    }
    _controller.clear();
    setState(() {
      _enteredMessage = '';
    });
    // FirebaseFirestore.instance.collection('chat').add({
    //   'text': _enteredMessage,
    //   'createdAt': Timestamp.now(),
    //   'userId': user.uid,
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              autocorrect: true,
              enableSuggestions: true,
              textCapitalization: TextCapitalization.sentences,
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Send a message...',
              ),
              onChanged: (ch) {
                _enteredMessage = ch;
              },
              autofocus: true,
              onTap: () => _enteredMessage = '',
            ),
          ),
          IconButton(
              autofocus: true,
              color: Theme.of(context).primaryColor,
              icon: Icon(Icons.send),
              onPressed: () {
                setState(() {
                  _enteredMessage.trim().isEmpty
                      ? null
                      : _sendMessage().then((value) => Navigator.of(context)
                          .pushNamed(ChatScreen.routeName));
                });
              }),
        ],
      ),
    );
  }
}
