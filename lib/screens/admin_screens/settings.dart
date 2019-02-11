import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
          )
        ],
      ),
    );
  }
}
