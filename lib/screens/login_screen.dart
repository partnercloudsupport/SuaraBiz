import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:suarabiz/models/sales_agent.dart';
import 'package:suarabiz/screens/admin_screen.dart';
import 'package:suarabiz/screens/sales_screen.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final TextEditingController _emailTextController =
      new TextEditingController();
  final TextEditingController _passwordTextController =
      new TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 50.0, right: 50.0),
          child: Form(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 40.0),
                ),
                Image.network(
                  'https://www.designevo.com/res/templates/thumb_small/fresh-green-leaf.png',
                  width: 120.0,
                  height: 120.0,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 40.0),
                ),
                TextField(
                  controller: _emailTextController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Email', prefixIcon: Icon(Icons.email)),
                ),
                TextField(
                  controller: _passwordTextController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                ),
                _isLoading
                    ? Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(top: 40.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  height: 20.0,
                                  width: 20.0,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                ),
                                Text('Please wait...')
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: 150.0,
                            child: RaisedButton(
                              color: Theme.of(context).accentColor,
                              child: Text(
                                'Login',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                try {
                                  //get the user id first
                                  var loggedInUser = await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                          email: _emailTextController.text,
                                          password:
                                              _passwordTextController.text);

                                  //get the user role second
                                  var userSnapshot = await Firestore.instance
                                      .collection('salesagents')
                                      .document(loggedInUser.uid)
                                      .get();
                                  if (userSnapshot.data != null) {
                                    SalesAgent loggedInAgent =
                                        SalesAgent.fromJson(userSnapshot.data);
                                    Widget toRoute;
                                    if (loggedInAgent.role == 'sales') {
                                      toRoute = Sales(loggedInAgent);
                                    } else {
                                      toRoute = Admin();
                                    }

                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) => toRoute));
                                  }
                                } catch (error) {
                                  _scaffoldKey.currentState
                                      .showSnackBar(SnackBar(
                                    content: Text(error.message),
                                    backgroundColor: Colors.red,
                                  ));
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
