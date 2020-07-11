import 'package:freezers/models/currentUser.dart';
import 'package:freezers/models/device.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';


abstract class CumulocityApiState extends Equatable {
  const CumulocityApiState();

  @override
  List<Object> get props => [];
}

class AuthenticationMissing extends CumulocityApiState {}

class AuthenticationOngoing extends CumulocityApiState {}

class AuthenticationSuccessful extends CumulocityApiState {
  final CurrentUser currentUser;

  const AuthenticationSuccessful({@required this.currentUser});

  @override
  List<Object> get props => [currentUser];
}

class AuthenticationError extends CumulocityApiState {}

class DevicesLoading extends AuthenticationSuccessful {
  const DevicesLoading({currentUser}) : super(currentUser: currentUser);
}

class DevicesLoadedSuccessful extends AuthenticationSuccessful {
  final List<Device> devices;

  const DevicesLoadedSuccessful({@required this.devices, currentUser}) : super(currentUser: currentUser);

  @override
  List<Object> get props => [devices];
}

class DevicesLoadedError extends AuthenticationSuccessful {
  const DevicesLoadedError({currentUser}) : super(currentUser: currentUser);
}