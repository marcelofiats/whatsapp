import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/RouteGeneration.dart';
import 'package:whatsapp/login.dart';

void main() async {
  //INICIANDO FIRESTORE
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseFirestore.instance;
  //     .collection("usuarios")
  //     .doc("001")
  //     .set({"nome": "Marcelo"});

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Login(),
    theme: ThemeData(
      primaryColor: Color(0xff075e54),
      accentColor: Color(0xff25d366),
    ),
    initialRoute: "/",
    onGenerateRoute: RouteGeneration.generationRoute,
  ));
}
