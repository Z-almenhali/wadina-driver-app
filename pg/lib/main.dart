import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  runApp(MyApp(
      firestore: firestore,
      firebaseAuth: firebaseAuth,
      firebaseStorage: firebaseStorage));
}

class MyApp extends StatelessWidget {
  MyApp(
      {required this.firestore,
      required this.firebaseAuth,
      required this.firebaseStorage});
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final FirebaseStorage firebaseStorage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(fontFamily: 'Microsoft_PhagsPa'),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        firestore: firestore,
        firebaseAuth: firebaseAuth,
        firebaseStorage: firebaseStorage,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage(
      {Key? key,
      required this.title,
      required this.firestore,
      required this.firebaseAuth,
      required this.firebaseStorage})
      : super(key: key);

  final String title;
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final FirebaseStorage firebaseStorage;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Icon customIcon = const Icon(Icons.search);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF536DFE),
        bottomOpacity: 0.0,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Center(
          child: Login(
              firestore: widget.firestore,
              firebaseAuth: widget.firebaseAuth,
              firebaseStorage: widget.firebaseStorage)),
    );
  }
}
