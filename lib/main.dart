import 'package:flutter/material.dart';
import 'package:snakegame/home_page.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
    apiKey: "AIzaSyBlOYUiN7eYiNNZ0dF1jxF0hcOlSromVio",
    authDomain: "snakegame-75ebf.firebaseapp.com",
    projectId: "snakegame-75ebf",
    storageBucket: "snakegame-75ebf.firebasestorage.app",
    messagingSenderId: "712946083428",
    appId: "1:712946083428:web:65c45ff91b6fbe879de171",
    measurementId: "G-WBPHHD0DWW"
    )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
