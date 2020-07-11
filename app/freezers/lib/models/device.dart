import 'package:equatable/equatable.dart';

class Device extends Equatable {
  final String id;
  final String name;
  final String availablity;
  final num criticalAlarms;
  final num majorAlarms;
  final num minorAlarms;
  final num warningAlarms;

  const Device({this.id, this.name, this.availablity, this.criticalAlarms, this.majorAlarms, this.minorAlarms, this.warningAlarms});

  @override
  List<Object> get props => [name];

  static Device fromJson(dynamic json) {
    return Device(
      id: json['id'],
      name: json['name'],
      availablity: json['c8y_Availability'] != null ? json['c8y_Availability']['status'] : 'UNMANAGED',
      criticalAlarms: json['c8y_ActiveAlarmsStatus']['critical'] != null ? json['c8y_ActiveAlarmsStatus']['critical'] : 0,
      majorAlarms: json['c8y_ActiveAlarmsStatus']['major'] != null ? json['c8y_ActiveAlarmsStatus']['major'] : 0,
      minorAlarms: json['c8y_ActiveAlarmsStatus']['minor'] != null ? json['c8y_ActiveAlarmsStatus']['minor'] : 0,
      warningAlarms: json['c8y_ActiveAlarmsStatus']['warning'] != null ? json['c8y_ActiveAlarmsStatus']['warning'] : 0
    );
  }

  @override
  String toString() => 'Device { id: $id, name: $name }';
}