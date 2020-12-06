import 'dart:convert';

import 'package:chat_app/models/user.dart';
import 'package:chat_app/screens/auth_screen.dart';
import 'package:chat_app/screens/splash_screen.dart';
import 'package:chat_app/widgets/Auth_form.dart';
import 'package:chat_app/widgets/messages.dart';
import 'package:chat_app/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  static const routeName = '/ChatScreen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final fbm = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    subscripeToAdmin();
    fbm.requestNotificationPermissions();
    fbm.configure(
      onMessage: (message) {
        print(message);
        return;
      },
      onResume: (message) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ChatScreen()));
        return;
      },
      onLaunch: (message) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SplashScreens()));
        return;
      },
    );
    fbm.subscribeToTopic('chat');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: <Widget>[
          DropdownButton(
            underline: Container(),
            icon: Icon(Icons.more_vert,
                color: Theme.of(context).primaryIconTheme.color),
            items: [
              DropdownMenuItem(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.exit_to_app),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
                value: 'logout',
              ),
            ],
            onChanged: (item) {
              if (item == 'logout') {
                logout(Users.id)
                    .then((value) =>
                        Navigator.of(context).pushNamed(AuthScreen.routeName))
                    .then((value) {
                  Users.id = null;
                  Users.email = null;
                  Users.userName = null;
                  Users.isLogin = null;
                });
              }
            },
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Messages(),
            ),
            NewMessage(),
          ],
        ),
      ),
    );
  }

  void subscripeToAdmin() {
    fbm.subscribeToTopic('chat');
  }

  Future<Map> logout(int id) async {
    String url = 'http://192.168.1.7:8000/api/users/logout';

    http.Response response = await http.post(url, body: {"id": '$id'});
    if (response.statusCode == 200) {
      // return user;
      // return parsed['user'];
    } else {
      throw Exception('Unable to fetch data from the REST API');
    }
  }
}
