import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:suarabiz/common/common.dart';
import 'package:suarabiz/models/sales_agent.dart';
import 'package:suarabiz/screens/admin_screens/add_new_agent.dart';
import 'package:suarabiz/screens/login_screen.dart';

class Admin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final List<SalesAgent> _salesAgents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getSalesAgents();
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => Login()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var addedAgent = await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddNewAgent(), fullscreenDialog: true));

            if (addedAgent != null) {
              setState(() {
                _salesAgents.add(addedAgent);
              });
            }
          },
          child: Icon(Icons.add),
          tooltip: 'Add new user',
        ),
        appBar: AppBar(
          title: Text('Admin'),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(20),
            child: TextField(),
          ),
          actions: <Widget>[
            PopupMenuButton(
              onSelected: (val) {
                switch (val) {
                  case 'signout':
                    signOut();
                    break;
                }
              },
              itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text('Sign out'),
                      value: 'signout',
                    )
                  ],
            )
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: _salesAgents
                    .map((agent) => ListTile(
                          title: Text(agent.name),
                          subtitle: Text(agent.email),
                          trailing: PopupMenuButton(
                            onSelected: (val) {
                              switch (val) {
                                case 'credit':
                                  showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (context) => AlertDialog(
                                            shape: BeveledRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0)),
                                            title: Text(
                                                '${agent.credits} credits remaining'),
                                            content: Form(
                                              key: _formKey,
                                              child: TextFormField(
                                                onSaved: (val) {
                                                  agent.credits +=
                                                      int.parse(val);
                                                },
                                                validator: (val) {
                                                  if (val.isEmpty) {
                                                    return 'Cannot be empty';
                                                  }
                                                },
                                                autofocus: true,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: false,
                                                        signed: false),
                                                decoration: InputDecoration(
                                                    hintText: 'credits amount'),
                                              ),
                                            ),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text('DONE'),
                                                onPressed: () {
                                                  if (_formKey.currentState
                                                      .validate()) {
                                                    _formKey.currentState
                                                        .save();
                                                    Firestore.instance
                                                        .collection(
                                                            'salesagents')
                                                        .document(agent.id)
                                                        .updateData({
                                                      'credits': agent.credits
                                                    });
                                                    Navigator.of(context).pop();
                                                  }
                                                },
                                              )
                                            ],
                                          ));
                              }
                            },
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  child: Text(giveCreditsText),
                                  value: 'credit',
                                ),
                                PopupMenuItem(
                                  child: Text('View details'),
                                  value: 'detail',
                                )
                              ];
                            },
                          ),
                        ))
                    .toList(),
              ));
  }

  void getSalesAgents() {
    setState(() {
      _isLoading = true;
    });

    var subscription = Firestore.instance
        .collection('salesagents')
        .snapshots()
        .listen((data) {});

    subscription.onData((data) {
      if (data.documents.length > 0) {
        for (int i = 0; i < data.documents.length; i++) {
          var agent = SalesAgent.fromJson(data.documents[i].data);
          setState(() {
            _salesAgents.add(agent);
          });
        }
        setState(() {
          _isLoading = false;
        });
      }
      subscription.cancel();
    });

    subscription.onError((error) {
      setState(() {
        _isLoading = false;
      });
      subscription.cancel();
    });
  }
}
