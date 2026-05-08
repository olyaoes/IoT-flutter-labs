import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart'; 

class MqttService {
  MqttServerClient? client;
  final StreamController<String> _tempController =
      StreamController<String>.broadcast();

  Stream<String> get tempStream => _tempController.stream;

  Future<void> connect() async {
    final String clientId = 'aqua_${DateTime.now().millisecondsSinceEpoch}';
    
    debugPrint('MQTT: Connecting to broker.hivemq.com...');
    
    client = MqttServerClient(
      'broker.hivemq.com',
      clientId,
    );
    client!.port = 1883; 
    client!.setProtocolV311();
    client!.keepAlivePeriod = 20;

    final MqttConnectMessage connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client!.connectionMessage = connMessage;

    try {
      await client!.connect();
      if (client?.connectionStatus?.state == MqttConnectionState.connected) {
        debugPrint('MQTT: Connection established successfully');
        
        client!.subscribe(
          'aquatracker/sensor/temperature',
          MqttQos.atMostOnce,
        );
        
        client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
          final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
          final String payload = MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message,
          );
        
          debugPrint('MQTT: Received temp data: $payload');
          _tempController.add(payload);
        });
      }
    } catch (e) {
      debugPrint('MQTT Error: $e');
    }
  }

  void disconnect() {
    debugPrint('MQTT: Disconnecting...');
    client?.disconnect();
    _tempController.close();
  }
}
