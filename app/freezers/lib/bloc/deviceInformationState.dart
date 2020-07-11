import 'package:freezers/models/currentUser.dart';
import 'package:freezers/models/device.dart';
import 'package:freezers/models/measurement.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';


abstract class DeviceInformationState extends Equatable {
  const DeviceInformationState();

  @override
  List<Object> get props => [];
}

class MeasurementsNotLoaded extends DeviceInformationState {}

class MeasurementsLoading extends DeviceInformationState {}

class MeasurementsLoadedSuccessful extends DeviceInformationState {
  final Measurement measurement;

  const MeasurementsLoadedSuccessful({@required this.measurement});

  @override
  List<Object> get props => [measurement];
}

class MeasurementsLoadedError extends DeviceInformationState {}