import 'package:flutter/material.dart';
import 'package:suarabiz/screens/admin_screen.dart';
import 'package:suarabiz/screens/sales_screen.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailTextController = new TextEditingController(text: 'admin');
  TextEditingController _passwordTextController = new TextEditingController(text: '123');
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 50.0, right: 50.0),
          child: Form(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 40.0),
                ),
                Image.network(
                  'https://www.designevo.com/res/templates/thumb_small/fresh-green-leaf.png',
                  width: 120.0,
                  height: 120.0,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 40.0),
                ),
                TextField(
                  controller: _emailTextController,
                  decoration: InputDecoration(
                      labelText: 'Email', prefixIcon: Icon(Icons.email)),
                ),
                TextField(
                  controller: _passwordTextController,
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                ),
                _isLoading
                    ? Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                height: 20.0,
                                width: 20.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                ),
                              ),
                              Text('Please wait...')
                            ],
                          ),
                        ),
                      ),
                    )
                    : Container(),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: 150.0,
                            child: RaisedButton(
                              color: Theme.of(context).accentColor,
                              child: Text(
                                'Login',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                if(_emailTextController.text == 'admin' && _passwordTextController.text == '123'){
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>Admin()));
                                }else if(_emailTextController.text =='sales' && _passwordTextController.text == '123'){
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>Sales()));
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
