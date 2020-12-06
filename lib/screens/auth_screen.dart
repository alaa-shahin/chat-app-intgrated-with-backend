import 'dart:convert';
import 'dart:io';
import 'package:chat_app/exceptions/custom_exception.dart';
import 'package:chat_app/models/user.dart';

import 'package:chat_app/widgets/Auth_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'chat_screen.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/AuthScreen';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;

  Future<Map> login(String email, String password) async {
    String url = 'http://192.168.1.7:8000/api/users/login';

    http.Response response =
        await http.post(url, body: {"email": email, "password": password});
    var parsed = jsonDecode(response.body);
    if (parsed['status'] == true) {
      Users.email = parsed['user'][0]['email'];
      Users.id = parsed['user'][0]['id'];
      Users.userName = parsed['user'][0]['username'];
      Users.isLogin = (parsed['user'][0]['is_login'] == '0') ? false : true;
    }
    return parsed;
  }

  Future<Map> register(
      String email, String password, String userName, File image) async {
    String url = 'http://192.168.1.7:8000/api/users/register';

    http.Response response = await http.post(url, body: {
      "email": email,
      "password": password,
      "username": userName,
      "image": image
    });
    Map parsed = jsonDecode(response.body);
    if (parsed['status'] == true) {
      Users.email = parsed['user']['email'];
      Users.id = parsed['user']['id'];
      Users.userName = parsed['user']['username'];
      Users.isLogin = (parsed['user']['is_login'] == '0') ? false : true;
    }
    return parsed;
  }

  void _submitAuthForm(
    String email,
    String password,
    String userName,
    File image,
    bool isLogin,
    BuildContext ctx,
  ) async {
    String message = '';
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        Future<Map> result = login(email, password);
        result.then((value) {
          value.forEach((key, value) {
            if (key == 'status' && value == true) {
              Navigator.of(context).pushNamed(ChatScreen.routeName);
            } else {
              if (key == 'code' && value == 'user-not-found') {
                message = 'No user found for that email';
              }
              if (key == 'code' && value == 'wrong-password') {
                message = 'Wrong password provided for that user';
              }
            }
          });
          Scaffold.of(ctx).showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(ctx).errorColor,
          ));
        });
      } else {
        Future<Map> result = register(email, password, userName, image);
        result.then((value) {
          value.forEach((key, value) {
            if (key == 'status' && value == true) {
              Navigator.of(context).pushNamed(ChatScreen.routeName);
            } else {
              if (key == 'code' && value == 'email-already-in-use') {
                message = 'The account already exists for that email';
              }
              if (key == 'code' && value == 'weak-password') {
                message = 'The password provided is too weak';
              }
            }
          });
          Scaffold.of(ctx).showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(ctx).errorColor,
          ));
        });
      }
    } on CustomException catch (e) {
      String m = 'Error Occurred';
      if (e.message == 'weak-password') {
        m = 'The password provided is too weak';
      } else if (e.message == 'email-already-in-use') {
        m = 'The account already exists for that email';
      } else if (e.message == 'user-not-found') {
        m = 'No user found for that email';
      } else if (e.message == 'wrong-password') {
        m = 'Wrong password provided for that user';
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(
        _submitAuthForm,
        _isLoading,
      ),
    );
  }
}
