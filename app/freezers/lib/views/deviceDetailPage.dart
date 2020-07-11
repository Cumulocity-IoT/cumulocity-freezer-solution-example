import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezers/bloc/deviceInformationBloc.dart';
import 'package:freezers/bloc/deviceInformationEvent.dart';
import 'package:freezers/bloc/deviceInformationState.dart';
import 'package:freezers/c8yRepository.dart';
import 'package:freezers/models/device.dart';

import 'package:flutter_gauge/flutter_gauge.dart';


class DeviceDetailPage extends StatefulWidget {
  DeviceDetailPage({Key key, this.title, this.device, this.c8yRepository, this.errorText}) : super(key: key);

  final CumulocityRepository c8yRepository;
  final Device device;
  final String title;
  final String errorText;

  @override
  _DeviceDetailPageState createState() => _DeviceDetailPageState(c8yRepository, device);
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  _DeviceDetailPageState(this.c8yRepository, this.device);

  final CumulocityRepository c8yRepository;
  final Device device;

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
        child: BlocProvider(
          create: (context) => DeviceInformationBloc(c8yRepository: c8yRepository),
          child: BlocBuilder<DeviceInformationBloc, DeviceInformationState>(
            builder: (context, state) {
              if (state is MeasurementsLoading) {
                return Center(
                  child: CircularProgressIndicator()
                );
              }
              if (state is MeasurementsLoadedSuccessful) {
                double currentValue = state.measurement.getMeasurementValue('c8y_Temperature', 'T');
                return ListView(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: FlutterGauge(
                        start: 0,
                        end: 10,
                        index: currentValue,
                        handSize: 10,
                        circleColor: Color(0xFF1876BE),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Temperature',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: RaisedButton(
                        child: Text(
                          'Refresh',
                          style: TextStyle(
                            color: Colors.white
                          )
                        ),
                        color: Color(0xFF1876BE),
                        onPressed: () {
                          BlocProvider.of<DeviceInformationBloc>(context)
                            .add(FetchLatestMeasurements(source: device.id, fragment: 'c8y_Temperature', series: 'T'));
                        }
                      ),
                    )
                  ],
                );
              }
              if (state is MeasurementsLoadedError) {
                return Center(
                  child: Text('Error'),
                );
              }
              BlocProvider.of<DeviceInformationBloc>(context).add(FetchLatestMeasurements(source: device.id, fragment: 'c8y_Temperature', series: 'T'));
              return Center();
            }
          )
        ),
      ),
    );
  }
}