import 'dart:math';
import 'package:get/get.dart';

enum ConnectivityStatus {
  DISCONNECTED, CONNECTED
}

class ConnectivityService extends GetxService {
  var status = ConnectivityStatus.CONNECTED.obs;

  void checkConnection() {
    var index = Random().nextInt(ConnectivityStatus.values.length);
    status.value = ConnectivityStatus.values[index];
  }
}