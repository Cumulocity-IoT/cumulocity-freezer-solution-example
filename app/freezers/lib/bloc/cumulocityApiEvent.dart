import 'package:equatable/equatable.dart';

abstract class CumulocityApiEvent extends Equatable {

  const CumulocityApiEvent();
}

class LoginWithUsername extends CumulocityApiEvent {

  final String domain;
  final String tenant;
  final String user;
  final String password;

  const LoginWithUsername(this.domain, this.tenant, this.user, this.password);

  @override
  List<Object> get props => [];
}

class Logout extends CumulocityApiEvent {
  const Logout();

  @override
  List<Object> get props => [];
}

class LoadAllDevices extends CumulocityApiEvent {
  const LoadAllDevices();

  @override
  List<Object> get props => [];
}