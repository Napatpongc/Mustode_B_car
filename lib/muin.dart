import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase
import 'package:myproject/display.dart';
import 'rgb_text.dart';
import 'formscream.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure proper initialization
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
   int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: TabBarView(
          children: [Formscream(), DisplayScreen()],
        ),
        backgroundColor: Colors.black,
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(
              child: RGBText(
                text: "SAVE",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Tab(
              child: RGBText(text: "DOO", style: TextStyle(fontSize: 20)),
            )
          ],
        ),
      ),
    );
  }
}
