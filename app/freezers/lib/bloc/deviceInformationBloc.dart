import 'package:freezers/bloc/deviceInformationEvent.dart';
import 'package:freezers/bloc/deviceInformationState.dart';
import 'package:freezers/c8yRepository.dart';
import 'package:freezers/models/measurement.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';


class DeviceInformationBloc extends Bloc<DeviceInformationEvent, DeviceInformationState> {
  final CumulocityRepository c8yRepository;

  DeviceInformationBloc({@required this.c8yRepository}) : assert(c8yRepository != null);

  @override
  DeviceInformationState get initialState => MeasurementsNotLoaded();

  @override
  Stream<DeviceInformationState> mapEventToState(DeviceInformationEvent event) async* {
    if (event is FetchLatestMeasurements) {
      yield MeasurementsLoading();
      try {
        final Measurement measurement = await c8yRepository.fetchLastMeasurement(event.fragment, event.series, event.source);
        yield MeasurementsLoadedSuccessful(measurement: measurement);
      } catch (_) {
        print(_);
        yield MeasurementsLoadedError();
      }
    }
  }
}