import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:suarabiz/models/vendor_settings.dart';
import 'package:suarabiz/screens/login_screen.dart';

class Sales extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  var _isInitialVisit = true;
  var _isLoading = false;
  var _vendorsList = List<VendorSettings>();
  final TextEditingController _vendorEmailController = TextEditingController();

  void getVendorsByEmail(String email) async {
    Firestore.instance
        .collection('vendorsettings')
        .where('businessName', arrayContains: email)
        .snapshots()
        .listen((data) {
      if (data.documents.length > 0) {
        print('has documents of length ${data.documents.length}');
        var tempVendorsList = List<VendorSettings>();
        for (int i = 0; i < data.documents.length; i++) {
          tempVendorsList.add(VendorSettings.fromJson(data.documents[i]));
        }

        setState(() {
          _vendorsList = tempVendorsList;
          _isLoading = false;
        });
      } else {
        print('no documents');
      }
    }).cancel();
  }

  void signOut(){
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>Login()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _vendorEmailController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _isInitialVisit = false;
                  });
                  getVendorsByEmail(_vendorEmailController.text);
                },
              ),
              hintText: 'Search for vendors...'),
        ),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (val){
              switch (val){
                case 'signout': signOut();break;
              }
            },
            itemBuilder: (context)=>[PopupMenuItem(value: 'signout',child: Text('Sign out'),)],
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _isInitialVisit
              ? Center(
                  child: Text('Start searching for vendors to give credits'),
                )
              : ListView(
                  children: _vendorsList
                      .map((vendor) => ListTile(
                            title: Text(vendor.businessName),
                          ))
                      .toList(),
                ),
    );
  }
}
