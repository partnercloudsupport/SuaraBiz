import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:suarabiz/models/vendor_settings.dart';
import 'package:suarabiz/screens/login_screen.dart';
import 'package:suarabiz/common/common.dart';

class Sales extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  var _isLoading = false;
  var _vendorsList = List<VendorSettings>();
  final TextEditingController _vendorEmailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    getVendors();
  }

  void getVendors() async {
    var vendorsList =
        await Firestore.instance.collection('vendorsettings').getDocuments();
    if (vendorsList.documents.length > 0) {
      for (int i = 0; i < vendorsList.documents.length; i++) {
        var vendor = VendorSettings.fromJson(vendorsList.documents[i].data);
        setState(() {
          _vendorsList.add(vendor);
        });
      }
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => Login()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Agents'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch(_vendorsList));
            },
          ),
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
                    value: 'signout',
                    child: Text('Sign out'),
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
              children: _vendorsList
                  .map((vendor) => ListTile(
                        title: Text(vendor.businessName),
                        subtitle: Text(vendor.email),
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
                                              '${vendor.credits} remaining'),
                                          content: Form(
                                            key: _formKey,
                                            child: TextFormField(
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      decimal: false,
                                                      signed: false),
                                              onSaved: (val) {
                                                vendor.credits +=
                                                    int.parse(val);
                                              },
                                              validator: (val) {
                                                if (val.isEmpty) {
                                                  return 'Cannot be empty';
                                                }
                                              },
                                              autofocus: true,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text('DONE'),
                                              onPressed: () {
                                                if (_formKey.currentState
                                                    .validate()) {
                                                  _formKey.currentState.save();
                                                  Firestore.instance
                                                      .collection(
                                                          'vendorsettings')
                                                      .document(vendor.uid)
                                                      .updateData({
                                                    'credits': vendor.credits
                                                  });
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                            )
                                          ],
                                        ));
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: Text(giveCreditsText),
                                  value: 'credit',
                                )
                              ],
                        ),
                      ))
                  .toList(),
            ),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final List<VendorSettings> _vendorsList;
  DataSearch(this._vendorsList);

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        )
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        },
      );

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey();
    final suggestionList =
        _vendorsList.where((vendor) => vendor.email.contains(query)).toList();
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) => ListTile(
            title: Text(suggestionList[index].businessName),
            subtitle: Text(suggestionList[index].email),
            trailing: PopupMenuButton(
              onSelected: (val) {
                switch (val) {
                  case 'credit':
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          final VendorSettings vendor = suggestionList[index];

                          return AlertDialog(
                            shape: BeveledRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            title: Text('${vendor.credits} credits remaining'),
                            content: Form(
                              key: _formKey,
                              child: TextFormField(
                                onSaved: (val) {
                                  vendor.credits += int.parse(val);
                                },
                                validator: (val) {
                                  if (val.isEmpty) {
                                    return 'Cannot be empty';
                                  }
                                },
                                autofocus: true,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: false, signed: false),
                                decoration:
                                    InputDecoration(hintText: 'credits amount'),
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('DONE'),
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    Firestore.instance
                                        .collection('vendorsettings')
                                        .document(vendor.uid)
                                        .updateData(
                                            {'credits': vendor.credits});
                                    Navigator.of(context).pop();
                                  }
                                },
                              )
                            ],
                          );
                        });
                    break;
                }
              },
              itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text(giveCreditsText),
                      value: 'credit',
                    )
                  ],
            ),
          ),
    );
  }
}
