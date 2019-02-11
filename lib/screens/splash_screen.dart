import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) =>Scaffold(
    body: Center(
      child: FittedBox(
        child: Column(
          children: <Widget>[
            Image.asset('images/app_logo.png',width: 250.0,height: 250.0,color: Colors.green,),
            Text('Please wait...'),
            Padding(padding: EdgeInsets.only(top: 20.0),),
            CircularProgressIndicator(),
          ],
        ),
      ),
    ),
  );

}