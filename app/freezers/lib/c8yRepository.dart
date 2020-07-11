
import 'dart:async';

import 'package:freezers/c8yClient.dart';
import 'package:freezers/models/currentUser.dart';
import 'package:meta/meta.dart';

import 'models/device.dart';
import 'models/measurement.dart';


class CumulocityRepository {
  final CumulocityClient c8yClient;

  CumulocityRepository({@required this.c8yClient})
      : assert(c8yClient != null);

  Future<CurrentUser> fetchCurrentUser() async {
    return await c8yClient.currentUser();
  }

  Future<List<Device>> fetchAllDevices() async {
    return await c8yClient.devices();
  }

  Future<Measurement> fetchLastMeasurement(fragment, series, source) async {
    return await c8yClient.lastMeasurement(fragment, series, source);
  }

  void useCredentials(domain, tenant, username, password) {
    c8yClient.setCredentials(domain, tenant, username, password);
  }
}