import 'package:equatable/equatable.dart';

class Measurement extends Equatable {
  final String id;
  final String type;
  final String time;
  final String source;
  final dynamic fragments;

  const Measurement({this.id, this.type, this.time, this.source, this.fragments});

  @override
  List<Object> get props => [type];

  double getMeasurementValue(fragment, series) {
    if (this.fragments[fragment] != null && this.fragments[fragment][series] != null) {
      return this.fragments[fragment][series]['value'];
    }
    return null;
  }

  static Measurement fromJson(dynamic json) {
    String _id = json['id'];
    String _type = json['type'];
    String _time = json['time'];
    String _source = json['source']['id'];
    json.remove('id');
    json.remove('type');
    json.remove('time');
    json.remove('source');
    json.remove('self');
    return Measurement(
      id: _id,
      type: _type,
      time: _time,
      source: _source,
      fragments: json
    );
  }

  @override
  String toString() => 'Measurement { type: $type }';
}