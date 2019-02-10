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
        home: /*Login()*/ FutureBuilder(
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
              //get the user role second
              /*Firestore.instance
                  .collection('salesagents')
                  .document(loggedInUserId)
                  .snapshots()
                  .listen((data) {
                SalesAgent loggedInAgent =
                    SalesAgent.fromJson(data.data);
                Widget toRoute;
                if (loggedInAgent.role == 'sales') {
                  toRoute = Sales();
                } else {
                  toRoute = Admin();
                }

                return toRoute;
              })*//*.cancel()*/;

              //return Sales();
            }
            return Login();
          },
        ) //MyHomePage(title: 'Flutter Demo Home Page'),
        );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
