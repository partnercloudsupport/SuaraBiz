import 'package:flutter/material.dart';

final int initialCredit = 3;

final double bottomNavBarIconSize = 25.0;

SnackBar buildErrorIndicatorSnackBar(String content) => SnackBar(
      content: Text(content),
      backgroundColor: Colors.red,
    );

final String giveCreditsText = 'Give credits';
final String changeCreditPolicy = 'Change credit policy';

Widget remainingCreditsWidget(int remainingCreditAmount, String text) =>
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey.shade200,
      ),
      padding: EdgeInsets.all(10.0),
      child: SizedBox(
        width: 80.0,
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 30.0,
              child: Text('$remainingCreditAmount'),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
            ),
            Text(
              text,
              style: TextStyle(fontSize: 15.0),
            )
          ],
        ),
      ),
    );

AlertDialog locationRemovalConfirmationDialog(BuildContext context) =>
    AlertDialog(
      title: Text('Are you sure?'),
      content: Text('This process cannot be undone'),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'CANCEL',
            style: TextStyle(color: Colors.grey),
          ),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        FlatButton(
          child: Text('REMOVE'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
