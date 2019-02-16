import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:suarabiz/models/sales_agent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNewAgent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddNewAgentState();
}

class _AddNewAgentState extends State<AddNewAgent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final SalesAgent _tempAgentDetailsHolder = SalesAgent.emptyObject();

  String fieldValidator(String val) {
    if (val.isEmpty) {
      return 'Cannot be empty';
    }
    return null;
  }

  String passwordValidator(String val) {
    if (val.isEmpty) {
      return 'Cannot be empty';
    }

    if (_tempAgentDetailsHolder.password.isEmpty && val.isNotEmpty) {
      return 'Must type and retype the password';
    }

    if (_tempAgentDetailsHolder.password.compareTo(val) != 0) {
      return 'Password don\'t match';
    }
    return null;
  }

  void saveUser() async {
    try {
      _formKey.currentState.save();

      // below steps should happen if the form is valid
      if (_formKey.currentState.validate()) {
        //create a user in firebase auth first and obtain the uid
        var createdUser = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _tempAgentDetailsHolder.email,
                password: _tempAgentDetailsHolder.password);

        _tempAgentDetailsHolder.id = createdUser.uid;

        //using the obtained uid, store the user in the firestore
        Firestore.instance
            .collection('salesagents')
            .document(_tempAgentDetailsHolder.id)
            .setData(_tempAgentDetailsHolder.toJson());

        //close the screen
        Navigator.of(context).pop(_tempAgentDetailsHolder);
      }
    } catch (error) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(error.message),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Add new Sales Agent'),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 15.0, right: 15.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                validator: fieldValidator,
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (val) {
                  _tempAgentDetailsHolder.name = val;
                },
              ),
              TextFormField(
                validator: fieldValidator,
                decoration: InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (val) {
                  _tempAgentDetailsHolder.email = val;
                },
              ),
              TextFormField(
                validator: fieldValidator,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (val) {
                  _tempAgentDetailsHolder.password = val;
                },
              ),
              TextFormField(
                validator: passwordValidator,
                decoration: InputDecoration(labelText: 'Retype Password'),
                obscureText: true,
              ),
              TextFormField(
                validator: fieldValidator,
                decoration: InputDecoration(labelText: 'Credit Amount'),
                keyboardType: TextInputType.numberWithOptions(
                    decimal: false, signed: false),
                onSaved: (val) {
                  _tempAgentDetailsHolder.credits = val == null || val.trim() == '' ? 0 : int.parse(val);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 15.0, right: 15.0),
        child: RaisedButton(
          color: Theme.of(context).primaryColor,
          onPressed: saveUser,
          child: Text(
            'Save',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
