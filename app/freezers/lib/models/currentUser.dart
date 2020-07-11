import 'package:equatable/equatable.dart';

class CurrentUser extends Equatable {
  final String userName;
  final String firstName;
  final String lastName;

  const CurrentUser({this.userName, this.firstName, this.lastName});

  @override
  List<Object> get props => [userName, firstName, lastName];

  static CurrentUser fromJson(dynamic json) {
    return CurrentUser(
      userName: json['userName'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }

  @override
  String toString() => 'CurrentUser { id: $userName }';
}