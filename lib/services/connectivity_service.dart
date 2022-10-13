import 'dart:async';

// import 'package:connectivity/connectivity.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';
import 'package:exchangilymobileapp/enums/connectivity_status.dart';

class ConnectivityService {
  // Create our public controller
  StreamController<ConnectivityStatus> connectionStatusController =
      StreamController<ConnectivityStatus>();

  ConnectivityService() {
    bool isConnected;
    StreamSubscription subscription;
    SimpleConnectionChecker _connectionChecker = SimpleConnectionChecker()
      ..setLookUpAddress('exchangily.com');
    subscription = _connectionChecker.onConnectionChange.listen((connected) {
      isConnected = connected;
    });

    // use _getStatusFromResult to get the status from the result
    connectionStatusController.add(_getStatusFromResult(isConnected));
  }

  // Convert from the third part enum to our own enum
  ConnectivityStatus _getStatusFromResult(bool isConnected) {
    return isConnected ? ConnectivityStatus.Online : ConnectivityStatus.Offline;
  }
}
