import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:suarabiz/models/sales_agent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNewAgent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddNewAgentState();
}

class _AddNewAgentState extends State<AddNewAgent> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypePassController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _creditController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Add new Sales Agent'),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('Name'),
          ),
          ListTile(
            title: Container(
              child: TextField(
                controller: _nameController,
              ),
            ),
          ),
          ListTile(
            title: Text('Email address'),
          ),
          ListTile(
            title: Container(
              child: TextField(
                controller: _emailController,
              ),
            ),
          ),
          ListTile(
            title: Text('Password'),
          ),
          ListTile(
            title: Container(
              child: TextField(
                controller: _passwordController,
              ),
            ),
          ),
          ListTile(
            title: Text('Retype Password'),
          ),
          ListTile(
            title: Container(
              child: TextField(
                controller: _retypePassController,
              ),
            ),
          ),
          ListTile(
            title: Text('Credit Amount'),
          ),
          ListTile(
            title: Container(
              child: TextField(
                keyboardType: TextInputType.number,
                controller: _creditController,
              ),
            ),
          ),
          Expanded(
            child: Container(),
          ),
          ListTile(
            title: RaisedButton(
              color: Theme.of(context).primaryColor,
              onPressed: () async {
                try {
                  var createdUser = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text);
                  var agent = SalesAgent(
                      createdUser.uid,
                      _nameController.text,
                      _emailController.text,
                      _passwordController.text,
                      int.parse(_creditController.text));

                  Firestore.instance
                      .collection('salesagents')
                      .document(agent.id)
                      .setData(agent.toJson());
                  Navigator.of(context).pop(agent);
                } catch (error) {
                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(error.message),
                  ));
                }
              },
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
