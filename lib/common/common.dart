import 'package:flutter/material.dart';

final int initialCredit = 3;

final double bottomNavBarIconSize = 25.0;

SnackBar buildErrorIndicatorSnackBar(String content) => SnackBar(
      content: Text(content),
      backgroundColor: Colors.red,
    );


final String giveCreditsText = 'Give credits';