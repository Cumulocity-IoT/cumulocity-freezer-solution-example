import 'package:equatable/equatable.dart';

abstract class DeviceInformationEvent extends Equatable {

  const DeviceInformationEvent();
}

class FetchLatestMeasurements extends DeviceInformationEvent {
  final String source;
  final String fragment;
  final String series;
  
  const FetchLatestMeasurements({this.source, this.fragment, this.series});

  @override
  List<Object> get props => [];
}