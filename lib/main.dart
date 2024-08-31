import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:willow/child/child_login_screen.dart';
import 'dart:io';


void main() async
{
  WidgetsFlutterBinding.ensureInitialized();

  if(Platform.isAndroid)
    {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyBNQVyVuUwOpx3CMn2bFN6rk2BBT-dK1CI",
            authDomain: "willow-7c049.firebaseapp.com",
            projectId: "willow-7c049",
            storageBucket: "willow-7c049.appspot.com",
            messagingSenderId: "211912579911",
            appId: "1:211912579911:web:1b627ae2dc0acae57f4a62",
            measurementId: "G-RXNBG41ED3"
        )
      );
    }
    else
    {
      await Firebase.initializeApp();
    }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.firaSansTextTheme(
          Theme.of(context).textTheme,
        ),
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  const LoginScreen()
    );
  }
}






