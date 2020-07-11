import 'package:flutter/material.dart';
import 'package:freezers/c8yRepository.dart';
import 'package:freezers/models/device.dart';
import 'package:freezers/views/deviceDetailPage.dart';

class DeviceListEntry extends StatefulWidget {
  final Device device;
  final CumulocityRepository c8yRepository;

  DeviceListEntry({this.device, this.c8yRepository}) : assert(device != null && c8yRepository != null);

  @override
  _DeviceListEntryState createState() => _DeviceListEntryState(device: device, c8yRepository: c8yRepository);
  
}

class _DeviceListEntryState extends State<DeviceListEntry> {

  final Device device;
  final CumulocityRepository c8yRepository;

  _DeviceListEntryState({this.device, this.c8yRepository}) : assert(device != null && c8yRepository != null);
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.1,
        child: Align(
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.1,
                child:Icon(
                  Icons.ac_unit,
                  color: device.availablity == 'AVAILABLE' ? Colors.green : device.availablity == 'UNMANAGED' ? Colors.grey : Colors.red,
                  size: 24.0,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Align(
                  child: Text(device.name),
                  alignment: Alignment.centerLeft,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Align(
                  child: ListView(
                    reverse: true,
                    scrollDirection: Axis.horizontal,
                    children:[
                      Icon(
                        Icons.warning,
                        color: Color(0xFF1C8CE2),
                        size: 20.0,
                      ),
                      Center(child: Text(device.warningAlarms.toString())),
                      Icon(
                        Icons.warning,
                        color: Color(0xFFFF801E),
                        size: 20.0,
                      ),
                      Center(child: Text(device.minorAlarms.toString())),
                      Icon(
                        Icons.warning,
                        color: Color(0xFFE66404),
                        size: 20.0,
                      ),
                      Center(child: Text(device.majorAlarms.toString())),
                      Icon(
                        Icons.warning,
                        color: Color(0xFFE00310),
                        size: 20.0,
                      ),
                      Center(child: Text(device.criticalAlarms.toString())),
                    ]
                  ),
                  alignment: Alignment.centerRight
                ),
              )
            ]
          ),
          alignment: Alignment.centerLeft,
        )
      ),
      onTap: () => navigateToDetailsPage(context)
    );
  }

  void navigateToDetailsPage(BuildContext context) {
    print(this.c8yRepository);
    print(this.device);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeviceDetailPage(title: this.device.name, c8yRepository: this.c8yRepository, device: this.device,)),
    );
  }
  
}