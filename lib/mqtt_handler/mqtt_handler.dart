import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_mqtt_location_tracker/models/device_location.dart';
import 'package:flutter_mqtt_location_tracker/utils/get_device_info.dart';
import 'package:flutter_mqtt_location_tracker/utils/password_utils.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
//import '../api/api_requests.dart' if (dart.library.html) 'browser.dart' as mqttsetup;
import 'package:flutter_mqtt_location_tracker/models/envvars.dart';
import 'package:flutter_mqtt_location_tracker/models/firebase_auth_user.dart';
import 'package:flutter_mqtt_location_tracker/services/service_locator.dart';
import 'package:flutter_mqtt_location_tracker/utils/keys.dart';
import 'package:get_it/get_it.dart';

class MqttHandler with ChangeNotifier {
  final ValueNotifier<String> data = ValueNotifier<String>(
      "No Data Received - Grant Location Permission and start streaming");
  late MqttServerClient client;
  final generalBox = GetIt.I<GeneralBox>();
  static const TOPIC_LOCATION_UPDATES_PREFIX = 'LU';
  late String topicLocationUpdates;
  late String clientId;

  Future<Object> connect() async {
    final authUser = generalBox.get(Keys.firebaseAuthUser) as FirebaseAuthUser;
    final deviceInfo = await getDeviceInfo(customHashPrefix: authUser.uid);

    final deviceHash = deviceInfo[Keys.deviceHash] as String;
    final envVars = generalBox.get(Keys.envVars) as EnvVars;
    topicLocationUpdates = '$TOPIC_LOCATION_UPDATES_PREFIX/${authUser.email}';
    clientId = '${authUser.email}/$deviceHash';
    final username = authUser.email;
    client = MqttServerClient.withPort(
        envVars.MQTT_SERVER_IP, //#"mqtt.eclipseprojects.io"# 'broker.emqx.io',
        clientId,
        18883);

    final property = MqttUserProperty();
    property.pairName = 'ExampleName';
    property.pairValue = 'Example value';
    client.logging(on: false);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onUnsubscribed = onUnsubscribed;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;
    client.keepAlivePeriod = 60;

    //client.logging(on: true);
    //client.websocketProtocols = ['mqtt5', 'tcp', 'mqtt5ws'];

    /// Set the correct MQTT protocol for mosquito
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        //.withWillTopic('willtopic')
        .startClean()
        .withUserProperties([property])
        .authenticateAs(
            username,
            decryptWithEncrypt(envVars.EMAIL_PASSWORD_HASH_KEY,
                generalBox.get(Keys.passwordHash) as String))
        //.withWillMessage('My Will message')
        .withWillQos(MqttQos.atLeastOnce);

    // final connMess = MqttConnectMessage()
    // .withClientIdentifier('MQTT5DartClient')
    // .startClean() // Or startSession() for a persistent session
    // .withUserProperties([property]);

    print('MQTT_LOGS::Mosquitto client connecting....');

    //client.connectionMessage = connMessage;
    try {
      //provide your mqtt broker username and password
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT_LOGS::Mosquitto client connected');
    } else {
      print(
          'MQTT_LOGS::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      return -1;
    }

    client.subscribe(topicLocationUpdates, MqttQos.atMostOnce);

    client.updates.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final vals = c!.map((e) => [e.topic, e.payload.toString()]).toList();
      final recMess = c![0].payload as MqttPublishMessage;
      // MqttPublishPayload.fromByteBuffer(recMess.payload.message!);
      // recMess.payload.
      // final pt = recMess.
      //     MqttPublishPayload.fromByteBuffer(recMess.payload.message);
      final stringMessage = utf8.decode(recMess.payload.message!);
      final jsonData = jsonDecode(stringMessage);
      print(jsonData);
      print(stringMessage);
      data.value = stringMessage;
      notifyListeners();
      print(
          'MQTT_LOGS:: New data arrived: topic is <${c[0].topic}>, payload is ${c[0].payload}');
      print('');
    });

    return client;
  }

  void subscribeToLocation() {
    // client.subscribe(topicLocationUpdates, MqttQos.atMostOnce);
    // client.subscribe(topicTemperature, MqttQos.atMostOnce);
  }

  void onConnected() {
    print('MQTT_LOGS:: Connected successfully');
  }

  void onDisconnected() {
    print('MQTT_LOGS:: Disconnected');
  }

  void onSubscribed(topic) {
    print('MQTT_LOGS:: Subscribed topic: $topic');
  }

  void onSubscribeFail(topic) {
    print('MQTT_LOGS:: Failed to subscribe $topic');
  }

  void onUnsubscribed(MqttSubscription? topic) {
    print('MQTT_LOGS:: Unsubscribed topic: $topic');
  }

  void pong() {
    print('MQTT_LOGS:: Ping response client callback invoked');
  }

  DeviceLocation? publishDeviceLocation(
      Map<String, dynamic> rawDeviceLocation) {
    final builder = MqttPayloadBuilder();
    rawDeviceLocation['timestamp'] =
        DateTime.now().toUtc().millisecondsSinceEpoch;
    rawDeviceLocation['clientId'] = clientId;
    rawDeviceLocation['topic'] = topicLocationUpdates;
    rawDeviceLocation['lat'] = rawDeviceLocation['latitude'];
    rawDeviceLocation['lon'] = rawDeviceLocation['longitude'];
    rawDeviceLocation.remove('latitude');
    rawDeviceLocation.remove('longitude');
    rawDeviceLocation.removeWhere((key, value) => (value == null));

    final stringMessage = jsonEncode(rawDeviceLocation);
    builder.addString(jsonEncode(stringMessage));
    int? publishOutcome = null;
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      publishOutcome = client.publishMessage(
          topicLocationUpdates, MqttQos.atMostOnce, builder.payload!,
          retain: true);
      print(
          'Outcome of publishing $stringMessage to $topicLocationUpdates is $publishOutcome');
      return DeviceLocation.fromJson(rawDeviceLocation);
    } else {
      return null;
    }
  }

  DeviceLocation? getDeviceLocation(Map<String, dynamic> rawDeviceLocation) {
    rawDeviceLocation['timestamp'] =
        DateTime.now().toUtc().millisecondsSinceEpoch;
    rawDeviceLocation['clientId'] = clientId;
    rawDeviceLocation['topic'] = topicLocationUpdates;
    rawDeviceLocation['lat'] = rawDeviceLocation['latitude'];
    rawDeviceLocation['lon'] = rawDeviceLocation['longitude'];
    rawDeviceLocation.remove('latitude');
    rawDeviceLocation.remove('longitude');
    rawDeviceLocation.removeWhere((key, value) => (value == null));
    return DeviceLocation.fromJson(rawDeviceLocation);
  }

  // void publishMessage(String message, {String topic = TOPIC_LOCATION_UPDATES}) {
  //   final builder = MqttClientPayloadBuilder();
  //   builder.addString(message);

  //   if (client.connectionStatus?.state == MqttConnectionState.connected) {
  //     final rc =
  //         client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  //     print('Outcome of publishing $message to $topic is $rc');
  //   }
  // }
}
