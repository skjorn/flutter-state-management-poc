import 'dart:math';

enum ConnectivityStatus {
  DISCONNECTED, CONNECTED
}

class ConnectivityService {
  ConnectivityStatus status = ConnectivityStatus.CONNECTED;

  void checkConnection(Function(ConnectivityStatus)? callback) {
    var index = Random().nextInt(ConnectivityStatus.values.length);
    status = ConnectivityStatus.values[index];
    callback?.call(status);
  }
}