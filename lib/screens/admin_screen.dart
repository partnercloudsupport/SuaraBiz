import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:suarabiz/common/common.dart';
import 'package:suarabiz/common/creditPolicyAlertBox.dart';
import 'package:suarabiz/models/sales_agent.dart';
import 'package:suarabiz/models/vendor_settings.dart';
import 'package:suarabiz/screens/admin_screens/add_new_agent.dart';
import 'package:suarabiz/screens/admin_screens/settings.dart';
import 'package:suarabiz/screens/login_screen.dart';

class Admin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AdminState();
}

class _AdminState extends State<Admin> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final List<SalesAgent> _salesAgents = [];
  final List<VendorSettings> _vendors = [];
  bool _isLoading = false;
  TabController _tabController;
  bool _shouldShowFloatingActionButton = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    _tabController.addListener(handleTabChanging);
    getSalesAgents();
    getVendors();
  }

  void handleTabChanging() {
    setState(() {
      _shouldShowFloatingActionButton = _tabController.index == 0;
    });
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => Login()));
  }

  void navigateToSettingsPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AdminSettings()));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          floatingActionButton: _shouldShowFloatingActionButton
              ? FloatingActionButton(
                  onPressed: () async {
                    var addedAgent = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => AddNewAgent(),
                            fullscreenDialog: true));

                    if (addedAgent != null) {
                      setState(() {
                        _salesAgents.add(addedAgent);
                      });
                    }
                  },
                  child: Icon(Icons.add),
                  tooltip: 'Add new user',
                )
              : null,
          appBar: AppBar(
            bottom: TabBar(
              controller: _tabController,
              tabs: <Widget>[
                Tab(
                  text: 'SALES AGENTS',
                ),
                Tab(
                  text: 'VENDORS',
                ),
              ],
            ),
            title: Text('Admin'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(
                      context: context, delegate: _tabController.index == 0 ? DataSearchForSalesAgents(_salesAgents) : DataSearchForVendors(_vendors));
                },
              ),
              PopupMenuButton(
                onSelected: (val) {
                  switch (val) {
                    case 'settings':
                      navigateToSettingsPage();
                      break;

                    case 'signout':
                      signOut();
                      break;
                  }
                },
                itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text('Settings'),
                        value: 'settings',
                      ),
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
              : TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    ListView(
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
                                                          BorderRadius.circular(
                                                              5.0)),
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
                                                          hintText:
                                                              'credits amount'),
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      child: Text('DONE'),
                                                      onPressed: () {
                                                        if (_formKey
                                                            .currentState
                                                            .validate()) {
                                                          _formKey.currentState
                                                              .save();
                                                          Firestore.instance
                                                              .collection(
                                                                  'salesagents')
                                                              .document(
                                                                  agent.id)
                                                              .updateData({
                                                            'credits':
                                                                agent.credits
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
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
                                      /*PopupMenuItem(
                                        child: Text('View details'),
                                        value: 'detail',
                                      )*/
                                    ];
                                  },
                                ),
                              ))
                          .toList(),
                    ),

                    //vendors
                    ListView(
                      children: _vendors
                          .map((vendor) => ListTile(
                                title: Text(vendor.businessName),
                                subtitle: Text(vendor.email),
                                trailing: PopupMenuButton(
                                  onSelected: (val) {
                                    switch (val) {
                                      case 'creditpolicy':
                                        showDialog(
                                            context: context,
                                            barrierDismissible: true,
                                            builder: (context) =>
                                                CreditPolicyAlertBox(vendor));
                                    }
                                  },
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                        child: Text(changeCreditPolicy),
                                        value: 'creditpolicy',
                                      ),
                                    ];
                                  },
                                ),
                              ))
                          .toList(),
                    )
                  ],
                )),
    );
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

  void getVendors() async {
    /*setState(() {
      _isLoading = true;
    });*/

    var vendorsList =
        await Firestore.instance.collection('vendorsettings').getDocuments();

    for (int i = 0; i < vendorsList.documents.length; i++) {
      var vendor = VendorSettings.fromJson(vendorsList.documents[i].data);
      setState(() {
        _vendors.add(vendor);
      });
    }
  }
}

class DataSearchForSalesAgents extends SearchDelegate<String> {
  /*final _suggestionList = ['sajad', 'jaward', 'ahamed'];*/
  final List<SalesAgent> _listOfSalesAgents;
  DataSearchForSalesAgents(this._listOfSalesAgents);

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
    final suggestionList = _listOfSalesAgents
        .where((agent) => agent.email.contains(query))
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
            title: Text(suggestionList[index].name),
            subtitle: Text(suggestionList[index].email),
            trailing: PopupMenuButton(
              onSelected: (val) {
                switch (val) {
                  case 'credit':
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          final SalesAgent agent = suggestionList[index];

                          return AlertDialog(
                            shape: BeveledRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            title: Text('${agent.credits} credits remaining'),
                            content: Form(
                              key: _formKey,
                              child: TextFormField(
                                onSaved: (val) {
                                  agent.credits += int.parse(val);
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
                                        .collection('salesagents')
                                        .document(agent.id)
                                        .updateData({'credits': agent.credits});
                                    Navigator.of(context).pop();
                                  }
                                },
                              )
                            ],
                          );
                        });
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
          ),
      itemCount: suggestionList.length,
    );
  }
}



class DataSearchForVendors extends SearchDelegate<String> {
  final List<VendorSettings> _listOfvendors;
  DataSearchForVendors(this._listOfvendors);

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
    final suggestionList = _listOfvendors
        .where((agent) => agent.email.contains(query))
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
            title: Text(suggestionList[index].businessName),
            subtitle: Text(suggestionList[index].email),
            trailing: PopupMenuButton(
              onSelected: (val) {
                switch (val) {
                  case 'creditpolicy':
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          final VendorSettings vendor = suggestionList[index];

                          return CreditPolicyAlertBox(vendor);
                        });
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: Text(changeCreditPolicy),
                    value: 'creditpolicy',
                  )
                ];
              },
            ),
          ),
      itemCount: suggestionList.length,
    );
  }
}
