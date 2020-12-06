import 'package:chat_app/screens/auth_screen.dart';
import 'package:chat_app/screens/splash_screen.dart';
import 'package:chat_app/widgets/messages.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import 'screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(SplashScreens());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'chat_app',
      theme: ThemeData(
        primaryColor: Colors.pink,
        backgroundColor: Colors.pink,
        accentColor: Colors.deepPurple,
        accentColorBrightness: Brightness.dark,
        buttonTheme: ButtonTheme.of(context).copyWith(
          buttonColor: Colors.pink,
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: FutureBuilder(
        future: isLogin(null),
        builder: (ctx, snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting) {
            return SplashScreens();
          }
          if (snapShot.hasData) {
            return ChatScreen();
          } else {
            return AuthScreen();
          }
        },
      ),
      routes: {
        '/ChatScreen': (ctx) => ChatScreen(),
        '/AuthScreen': (ctx) => AuthScreen(),
      },
    );
  }

  Future isLogin(String email) async {
    String url = 'http://192.168.1.7:8000/api/users/islogin';
    http.Response response = await http.post(url, body: {"email": email});
    // List parsed = jsonDecode(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      // return parsed;
    } else {
      throw Exception('Unable to fetch data from the REST API');
    }
  }
}
