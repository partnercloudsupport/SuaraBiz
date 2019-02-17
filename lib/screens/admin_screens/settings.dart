import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:suarabiz/common/common.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  bool _isCreditPolicyEnabled = true;

  void changeCreditPolicy(bool val) {
    Firestore.instance
        .collection('globals')
        .document('vars')
        .updateData({'creditpolicy': val});
  }

  void retrieveCreditPolicy() async {
    var snapShot =
        await Firestore.instance.collection('globals').document('vars').get();
    if (snapShot.exists) {
      var creditPolicyVal = snapShot.data['creditpolicy'];
      setState(() {
        _isCreditPolicyEnabled = creditPolicyVal;
      });
    }
  }

  void removeLocations() async {
    //remove locations node from firebase db
    FirebaseDatabase.instance.reference().child('locations').remove();

    //building a list of IDs that we need the isonline property to be false
    var vendors =
        await Firestore.instance.collection('vendorsettings').getDocuments();
    var vendorIDs = [];

    for (int i = 0; i < vendors.documents.length; i++) {
      vendorIDs.add(vendors.documents[i].documentID);
    }

    //set vendorsettings isonline property to false in firestore
    for(int i=0; i<vendorIDs.length; i++){
      Firestore.instance.collection('vendorsettings').document(vendorIDs[i]).updateData({'isOnline':false});
    }
  }

  @override
  void initState() {
    super.initState();
    retrieveCreditPolicy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Credit Policy Enabled'),
            subtitle: Text('If set to true, new vendors will be affected'),
            trailing: Switch(
              value: _isCreditPolicyEnabled,
              onChanged: (val) {
                changeCreditPolicy(val);
                setState(() {
                  _isCreditPolicyEnabled = val;
                });
              },
            ),
          ),
          ListTile(
            title: Text('Remove location nodes'),
            subtitle: Text('This will affect all the vendors'),
            trailing: RaisedButton(
              onPressed: () async {
                var shouldRemove = await showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) =>
                        locationRemovalConfirmationDialog(context));

                if (shouldRemove) {
                  removeLocations();
                }
              },
              color: Colors.red,
              child: Text(
                'REMOVE',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
