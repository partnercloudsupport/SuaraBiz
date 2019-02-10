import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:suarabiz/models/sales_agent.dart';
import 'package:suarabiz/screens/admin_screen.dart';
import 'package:suarabiz/screens/login_screen.dart';
import 'package:suarabiz/screens/sales_screen.dart';

void main() => runApp(SuaraBizApp());

class SuaraBizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: FutureBuilder(
          future: FirebaseAuth.instance.currentUser(),
          builder: (context, snapShot) {
            if (snapShot.hasData) {
              String loggedInUserId = snapShot.data.uid;
              return FutureBuilder(
                future: Firestore.instance.collection('salesagents').document(loggedInUserId).get(),
                builder: (context,snapShot){
                  SalesAgent loggedInAgent = SalesAgent.fromJson(snapShot.data);
                  Widget screenToRender;
                  if(loggedInAgent.role == 'sales'){
                    screenToRender = Sales();
                  }else{
                    screenToRender = Admin();
                  }
                  return screenToRender;
                },
              );
            }
            return Login();
          },
        )
        );
  }
}