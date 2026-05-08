import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flashlight_plugin/my_flashlight_plugin.dart';
import 'package:lab1_water/cubits/water_cubit.dart';
import 'package:lab1_water/cubits/water_state.dart';
import 'package:lab1_water/services/mqtt_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MqttService _mqttService = MqttService();

  @override
  void initState() {
    super.initState();
    _mqttService.connect();
  }

  @override
  void dispose() {
    _mqttService.disconnect();
    super.dispose();
  }

  void _secretFlashlightToggle(BuildContext context) async {
    try {
      await MyFlashlightPlugin.toggleLight();
    } catch (e) {
      if (context.mounted) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Warning'),
            content: const Text('Platform not supported (Only Android)'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: GestureDetector(
          onLongPress: () => _secretFlashlightToggle(context),
          child: const Text(
            'AquaBalance',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent, Colors.white],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            StreamBuilder<String>(
              stream: _mqttService.tempStream,
              builder: (context, snapshot) {
                return Card(
                  margin: const EdgeInsets.all(20),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        const Text(
                          'Current Temperature',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          snapshot.hasData ? '${snapshot.data}°C' : '--°C',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: BlocBuilder<WaterCubit, WaterState>(
                builder: (context, state) {
                  return const Center(
                    child: Text('Your Water Statistics will be here'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your logic here
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
