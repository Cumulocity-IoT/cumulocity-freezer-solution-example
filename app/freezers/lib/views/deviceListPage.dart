import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezers/bloc/bloc.dart';
import 'package:freezers/c8yRepository.dart';
import 'package:freezers/widgets/deviceListEntry.dart';
import 'package:freezers/widgets/mainDrawer.dart';


class DeviceListPage extends StatefulWidget {
  DeviceListPage({Key key, this.title, this.c8yRepository, this.errorText}) : super(key: key);

  final String title;
  final CumulocityRepository c8yRepository;
  final String errorText;

  @override
  _DeviceListPageState createState() => _DeviceListPageState(c8yRepository: c8yRepository);
}

class _DeviceListPageState extends State<DeviceListPage> {
  _DeviceListPageState({this.c8yRepository});

  final CumulocityRepository c8yRepository;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Color(0xFF1876BE),
      ),
      drawer: CumulocityDrawer(),
      body: Container(
        child: BlocProvider(
          create: (context) => CumulocityApiBloc(c8yRepository: c8yRepository),
          child: BlocBuilder<CumulocityApiBloc, CumulocityApiState>(
            builder: (context, state) {
              if (state is DevicesLoading) {
                return Center(
                  child: CircularProgressIndicator()
                );
              }
              if (state is DevicesLoadedError) {
                return Center(
                  child: Text('Could not load devices')
                );
              }
              if (state is DevicesLoadedSuccessful) {
                return new ListView.builder(
                    itemCount: state.devices.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new DeviceListEntry(device: state.devices[index], c8yRepository: c8yRepository);
                    }
                  );
              }
              BlocProvider.of<CumulocityApiBloc>(context).add(LoadAllDevices());
              return Text('');
            }
          )
        )
      ),
    );
  }
}