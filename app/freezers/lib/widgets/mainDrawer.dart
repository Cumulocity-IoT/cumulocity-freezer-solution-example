import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezers/bloc/bloc.dart';

class CumulocityDrawer extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    Drawer myDrawer =  Drawer(
      child: ListView(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.2,
            child: DrawerHeader(
              child: Center(
                child: Text(
                  'Freezers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30
                  )
                )
              ),
              decoration: BoxDecoration(
                color: Color(0xFF1876BE),
              ),
            ),
          ),
          ListTile(
            title: Text('Device list'),
            onTap: () {
              BlocProvider.of<CumulocityApiBloc>(context).add(LoadAllDevices());
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Logout'),
            onTap: () {
              BlocProvider.of<CumulocityApiBloc>(context).add(Logout());
              Navigator.pop(context);
            },
          )
        ]
      )
    );
    return myDrawer;
  }
}