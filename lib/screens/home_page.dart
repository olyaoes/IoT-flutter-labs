import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lab1_water/models/user_model.dart';
import 'package:lab1_water/repositories/shared_prefs_user_repository.dart';
import 'package:mqtt_client/mqtt_browser_client.dart'; // ЗМІНЕНО ДЛЯ ВЕБУ
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _waterController = TextEditingController();
  final SharedPrefsUserRepository _repo = SharedPrefsUserRepository();

  late MqttBrowserClient _client; // ЗМІНЕНО ДЛЯ ВЕБУ
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  String _temp = '--';
  bool _isOnline = true;
  String? _currentUserEmail;
  int _dailyGoal = 2000;
  int _currentWater = 0;
  int _lastLog = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupConnectivity();
    _setupMqtt();
  }

  void _setupConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> result) {
        if (!mounted) return;
        setState(() {
          _isOnline = !result.contains(ConnectivityResult.none);
        });
      },
    );
  }

  Future<void> _setupMqtt() async {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final String clientId = 'flutter_client_$timestamp';

    // ЗМІНЕНО ДЛЯ ВЕБУ: Використовуємо WebSockets і порт 8000
    _client = MqttBrowserClient('ws://broker.hivemq.com/mqtt', clientId);
    _client.port = 8000; 
    _client.keepAlivePeriod = 20;
    _client.onDisconnected = () => debugPrint('MQTT: Disconnected');

    final MqttConnectMessage connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    _client.connectionMessage = connMessage;

    try {
      await _client.connect();
      if (_client.connectionStatus!.state == MqttConnectionState.connected) {
        debugPrint('MQTT: Connected');
        _client.subscribe(
          'aquatracker/sensor/temperature',
          MqttQos.atMostOnce,
        );

        _client.updates!.listen(
          (List<MqttReceivedMessage<MqttMessage>> messages) {
            if (!mounted) return;

            final MqttPublishMessage recMess =
                messages[0].payload as MqttPublishMessage;

            final String payload = MqttPublishPayload.bytesToStringAsString(
              recMess.payload.message,
            );

            setState(() {
              _temp = payload;
            });
          },
        );
      }
    } catch (e) {
      debugPrint('MQTT Exception: $e');
    }
  }

  Future<void> _loadData() async {
    final UserModel? user = await _repo.getUser();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      if (user != null) {
        _currentUserEmail = user.email;
        _dailyGoal = user.dailyGoal;
        _currentWater = prefs.getInt('current_water_${user.email}') ?? 0;
        _lastLog = prefs.getInt('last_log_${user.email}') ?? 0;
      }
      _isLoading = false;
    });
  }

  Future<void> _logWater() async {
    if (_currentUserEmail == null) {
      return;
    }

    final String input = _waterController.text.trim();
    final int? amount = int.tryParse(input);

    if (amount == null || amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid amount'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int newWater = _currentWater + amount;

    await prefs.setInt('current_water_$_currentUserEmail', newWater);
    await prefs.setInt('last_log_$_currentUserEmail', amount);

    if (!mounted) return;

    setState(() {
      _currentWater = newWater;
      _lastLog = amount;
      _waterController.clear();
    });
  }

  @override
  void dispose() {
    _waterController.dispose();
    _connectivitySubscription.cancel();
    _client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      appBar: AppBar(
        backgroundColor: _isOnline ? const Color(0xFF00BFFF) : Colors.grey,
        title: Text(
          _isOnline ? 'AquaTracker' : 'Offline Mode',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile').then((_) {
                _loadData();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (!_isOnline)
            const ColoredBox(
              color: Colors.redAccent,
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'No Internet Connection',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: <Widget>[
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            const Icon(
                              Icons.thermostat,
                              color: Colors.orange,
                              size: 40,
                            ),
                            Column(
                              children: <Widget>[
                                const Text(
                                  'Water Temp',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  '$_temp°C',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      '$_currentWater / $_dailyGoal ml',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Last log: +$_lastLog ml',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 40),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: _waterController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Enter amount (ml)',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _logWater,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BFFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'LOG WATER',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
