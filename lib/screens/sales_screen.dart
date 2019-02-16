import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:suarabiz/models/sales_agent.dart';
import 'package:suarabiz/models/vendor_settings.dart';
import 'package:suarabiz/screens/login_screen.dart';
import 'package:suarabiz/common/common.dart';

class Sales extends StatefulWidget {
  final SalesAgent _salesAgent;

  Sales(this._salesAgent);

  @override
  State<StatefulWidget> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  var _isLoading = false;
  var _vendorsList = List<VendorSettings>();
  final GlobalKey<FormState> _formKey = GlobalKey();
  int creditTypedByAgent = 0;

  @override
  void initState() {
    super.initState();
    getVendors();
  }

  void getVendors() async {
    var vendorsList = await Firestore.instance
        .collection('vendorsettings')
        .where('creditPolicy', isEqualTo: true)
        .getDocuments();
    if (vendorsList.documents.length > 0) {
      for (int i = 0; i < vendorsList.documents.length; i++) {
        var vendor = VendorSettings.fromJson(vendorsList.documents[i].data);
        setState(() {
          _vendorsList.add(vendor);
        });
      }
    } else {
      setState(() {
        _vendorsList = [];
      });
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => Login()));
  }

  Future<void> refreshListView() {
    _vendorsList = [];
    getVendors();
    return Future.value();
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
              showSearch(
                  context: context,
                  delegate: DataSearch(_vendorsList, widget._salesAgent));
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
          : RefreshIndicator(
              onRefresh: refreshListView,
              child: ListView(
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
                                            title: Flex(
                                              direction: Axis.horizontal,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                remainingCreditsWidget(
                                                    vendor.credits,
                                                    'Vendor has'),
                                                remainingCreditsWidget(
                                                    widget._salesAgent.credits,
                                                    'You have'),
                                              ],
                                            ),
                                            content: Form(
                                              key: _formKey,
                                              child: TextFormField(
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: false,
                                                        signed: false),
                                                onSaved: (val) {
                                                  creditTypedByAgent =
                                                      int.parse(val);
                                                  vendor.credits +=
                                                      int.parse(val);
                                                },
                                                validator: (val) {
                                                  if (val.isEmpty) {
                                                    return 'Cannot be empty';
                                                  }

                                                  if (int.parse(val) < 0 ||
                                                      int.parse(val) == 0) {
                                                    return 'Please enter a valid amount';
                                                  }

                                                  if (int.parse(val) >
                                                      widget._salesAgent
                                                          .credits) {
                                                    return 'Cannot give more than credits you got';
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
                                                    _formKey.currentState
                                                        .save();
                                                    //create db refs
                                                    final Firestore fIns =
                                                        Firestore.instance;
                                                    var agentRef = fIns
                                                        .collection(
                                                            'salesagents')
                                                        .document(widget
                                                            ._salesAgent.id);
                                                    var venderRef = fIns
                                                        .collection(
                                                            'vendorsettings')
                                                        .document(vendor.uid);

                                                    widget._salesAgent
                                                            .credits -=
                                                        creditTypedByAgent;

                                                    agentRef.updateData({
                                                      'credits': (widget
                                                          ._salesAgent.credits)
                                                    });
                                                    venderRef.updateData({
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
            ),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final SalesAgent _salesAgent;
  final List<VendorSettings> _vendorsList;
  DataSearch(this._vendorsList, this._salesAgent);
  int creditTypedByAgent = 0;

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
  Widget buildResults(BuildContext context) => buildSuggestions(context);

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
                            title: Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                remainingCreditsWidget(
                                    vendor.credits, 'Vendor has'),
                                remainingCreditsWidget(
                                    _salesAgent.credits, 'You have'),
                              ],
                            ),
                            content: Form(
                              key: _formKey,
                              child: TextFormField(
                                onSaved: (val) {
                                  creditTypedByAgent = int.parse(val);
                                  vendor.credits += int.parse(val);
                                },
                                validator: (val) {
                                  if (val.isEmpty) {
                                    return 'Cannot be empty';
                                  }

                                  if (int.parse(val) < 0 ||
                                      int.parse(val) == 0) {
                                    return 'Please enter a valid amount';
                                  }

                                  if (int.parse(val) > _salesAgent.credits) {
                                    return 'Cannot give more than credits you got';
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
                                onPressed: () async {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    //create db refs
                                    final Firestore fIns = Firestore.instance;
                                    var agentRef = fIns
                                        .collection('salesagents')
                                        .document(_salesAgent.id);
                                    var venderRef = fIns
                                        .collection('vendorsettings')
                                        .document(vendor.uid);

                                    _salesAgent.credits -= creditTypedByAgent;

                                    agentRef.updateData(
                                        {'credits': (_salesAgent.credits)});
                                    venderRef.updateData(
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
