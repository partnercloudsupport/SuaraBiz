import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:suarabiz/models/vendor_settings.dart';

class CreditPolicyAlertBox extends StatefulWidget {
  final VendorSettings _vendorSettings;

  CreditPolicyAlertBox(this._vendorSettings);

  @override
  State<StatefulWidget> createState() => _CreditPolicyAlertBoxState();
}

class _CreditPolicyAlertBoxState extends State<CreditPolicyAlertBox> {
  VendorSettings _vendorSettings;

  @override
  void initState() {
    super.initState();
    setState(() {
      _vendorSettings = widget._vendorSettings;
    });
  }

  void changeCreditPolicy(String uid, bool value) {
    Firestore.instance
        .collection('vendorsettings')
        .document(uid)
        .updateData({'creditPolicy': value});
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        title: Text('Change credit policy'),
        content: FittedBox(
          child: Container(
            width: 200.0,
            height: 50.0,
            child: ListTile(
              title: Text('Set to'),
              trailing: Switch(
                value: _vendorSettings.creditPolicy,
                onChanged: (val) {
                  changeCreditPolicy(_vendorSettings.uid, val);
                  setState(() {
                    _vendorSettings.creditPolicy = val;
                  });
                },
              ),
            ),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('CLOSE'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
}
