import 'package:flutter/material.dart';

class Sales extends StatefulWidget{
  @override
  State<StatefulWidget> createState() =>_SalesState();
}

class _SalesState extends State<Sales>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(Icons.search,color: Colors.white,),
              onPressed: (){},
            ),
            hintText: 'Search for vendors...'
          ),
        ),

      ),
      body: Center(child: Text('data'),),
    );
  }

}