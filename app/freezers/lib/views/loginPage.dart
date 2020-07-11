import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezers/bloc/bloc.dart';
import 'package:freezers/c8yRepository.dart';


class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title, this.c8yRepository, this.errorText}) : super(key: key);

  final String title;
  final CumulocityRepository c8yRepository;
  final String errorText;

  @override
  _LoginPageState createState() => _LoginPageState(c8yRepository: c8yRepository);
}

class _LoginPageState extends State<LoginPage> {
  _LoginPageState({this.c8yRepository});

  final CumulocityRepository c8yRepository;
  final baseUrl = 'http://solutiondemo.eu-latest.cumulocity.com';
  final tenant = 't116686231';
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  List<Widget> buildChildren() {
    List<Widget> widgets = [
      TextField(
        controller: usernameController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Username',
        )
      ),
      SizedBox(height: 10),
      TextField(
        controller: passwordController,
        obscureText: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Password',
        )
      ),
      RaisedButton(
        onPressed: () {
          BlocProvider.of<CumulocityApiBloc>(context)
            .add(LoginWithUsername(baseUrl, tenant, usernameController.text, passwordController.text));
        },
        child: Text(
          'Login',
          style: TextStyle(fontSize: 20)
        ),
      ),
      BlocProvider(
        create: (context) => CumulocityApiBloc(c8yRepository: c8yRepository),
        child: BlocBuilder<CumulocityApiBloc, CumulocityApiState>(
          builder: (context, state) {
            if (state is AuthenticationOngoing) {
              return CircularProgressIndicator();
            }
            if (state is AuthenticationError) {
              return Text('Authentication Error');
            }
            return Text('');
          }
        )
      )
    ];
    return widgets;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        
        backgroundColor: Color(0xFF1876BE),
      ),
      body: Container(
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.2, 
          right: MediaQuery.of(context).size.width * 0.2
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buildChildren()
          ),
        ),
      ),
    );
  }
}