import 'dart:convert';

import 'package:freezers/models/measurement.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:freezers/models/currentUser.dart';

import 'models/device.dart';

class CumulocityClient {
  final Codec<String, String> stringToBase64 = utf8.fuse(base64);
  final http.Client httpClient;
  String authentication;
  Map<String, String> defaultHeaders;
  String baseUrl;

  CumulocityClient({ 
    @required this.httpClient 
  }): assert(httpClient != null);

  void setCredentials(domain, tenant, username, password) {
    this.baseUrl = domain;
    this.authentication =  stringToBase64.encode(tenant + '/' + username + ':' + password);
    defaultHeaders = { 'Authorization': 'Basic ' + this.authentication };
  }
  
  Future<CurrentUser> currentUser() async {
    final url = '$baseUrl/user/currentUser';
    
    final response = await this.httpClient.get(url, headers: defaultHeaders);

    if (response.statusCode != 200) {
      throw new Exception('error getting current user');
    }

    final json = jsonDecode(response.body);
    return CurrentUser.fromJson(json);
  }

  Future<List<Device>> devices() async {
    final url = '$baseUrl/inventory/managedObjects?fragmentType=c8y_IsDevice&type=c8y_PythonModbusAgent&pageSize=2000';
    
    final response = await this.httpClient.get(url, headers: defaultHeaders);

    if (response.statusCode != 200) {
      throw new Exception('error getting devices');
    }

    final json = jsonDecode(response.body);
    List<Device> devices = [];
    json['managedObjects'].forEach(
      (entry) => devices.add(Device.fromJson(entry))
    );
    return devices;
  }

  Future<Measurement> lastMeasurement(fragment, series, source) async {
    final url = '$baseUrl/measurement/measurements?valueFragmentType=$fragment&valueFragementSeries=$series&source=$source&dateFrom=1970-01-01&pageSize=1&revert=true';
    
    final response = await this.httpClient.get(url, headers: defaultHeaders);

    if (response.statusCode != 200) {
      throw new Exception('error getting devices');
    }

    final json = jsonDecode(response.body);
    if (json['measurements'].length == 0) {
      throw new Exception('No measurement for "$fragment" and "$series"');
    }
    return Measurement.fromJson(json['measurements'][0]);
  }
}