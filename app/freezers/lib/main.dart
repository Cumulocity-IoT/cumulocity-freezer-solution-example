import 'package:flutter/material.dart';
import 'package:freezers/bloc/bloc.dart';
import 'package:freezers/c8yClient.dart';
import 'package:freezers/c8yRepository.dart';
import 'package:freezers/views/deviceListPage.dart';
import 'package:freezers/views/loginPage.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  CumulocityClient c8yClient = CumulocityClient(httpClient: http.Client());
  CumulocityRepository c8yRepository = CumulocityRepository(c8yClient: c8yClient);
  runApp(MyApp(c8yRepository: c8yRepository));
}

class MyApp extends StatelessWidget {

  MyApp({this.c8yRepository}) : assert(c8yRepository != null);

  final CumulocityRepository c8yRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market Viewer',
      theme: ThemeData(
        primaryColor: Color(0xFF1876BE),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocProvider(
        create: (context) => CumulocityApiBloc(c8yRepository: c8yRepository),
        child: BlocBuilder<CumulocityApiBloc, CumulocityApiState>(
          builder: (context, state) {
            if (state is AuthenticationSuccessful) {
              return Center(
                child: DeviceListPage(title: 'Freezers', c8yRepository: c8yRepository),
              );
            }
            return LoginPage(title: 'Login', c8yRepository: c8yRepository);
          }
        )
      ),
    );
  }
}