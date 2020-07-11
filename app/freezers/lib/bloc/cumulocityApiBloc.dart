import 'package:freezers/c8yRepository.dart';
import 'package:freezers/models/device.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:freezers/bloc/cumulocityApiEvent.dart';
import 'package:freezers/bloc/cumulocityApiState.dart';
import 'package:freezers/models/currentUser.dart';

class CumulocityApiBloc extends Bloc<CumulocityApiEvent, CumulocityApiState> {
  final CumulocityRepository c8yRepository;
  CurrentUser currentUser;

  CumulocityApiBloc({@required this.c8yRepository}) : assert(c8yRepository != null);

  @override
  CumulocityApiState get initialState => AuthenticationMissing();

  @override
  Stream<CumulocityApiState> mapEventToState(CumulocityApiEvent event) async* {
    if (event is Logout) {
      yield AuthenticationMissing();
    }
    if (event is LoginWithUsername) {
      yield AuthenticationOngoing();
      try {
        c8yRepository.useCredentials(event.domain, event.tenant, event.user, event.password);
        this.currentUser = await c8yRepository.fetchCurrentUser();
        yield AuthenticationSuccessful(currentUser: this.currentUser);
      } catch (_) {
        yield AuthenticationError();
      }
    }
    if (event is LoadAllDevices) {
      yield DevicesLoading(currentUser: this.currentUser);
      try {
        final List<Device> devices = await c8yRepository.fetchAllDevices();
        yield DevicesLoadedSuccessful(devices: devices, currentUser: this.currentUser);
      } catch (_) {
        yield DevicesLoadedError(currentUser: this.currentUser);
      }
    }
  }
}