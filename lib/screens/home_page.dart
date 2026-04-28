import 'package:flutter/material.dart';
import 'package:lab1_water/models/water_record.dart';
import 'package:lab1_water/repositories/water_repository.dart';
import 'package:lab1_water/services/mqtt_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MqttService _mqtt = MqttService();
  final WaterRepository _repository = WaterRepository();
  final TextEditingController _waterController = TextEditingController();

  late Future<List<WaterRecord>> _historyFuture;
  final int _currentWater = 213;

  @override
  void initState() {
    super.initState();
    _mqtt.connect();
    _historyFuture = _repository.getWaterHistory();
  }

  @override
  void dispose() {
    _waterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      appBar: AppBar(
        title: const Text(
          'AquaTracker',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF00BFFF),
        centerTitle: false,
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: <Widget>[
            _buildMqttCard(),
            const SizedBox(height: 30),
            Text(
              '$_currentWater / 2000 ml',
              style: const TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Last log: +213 ml',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),
            _buildWaterInput(),
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'History (Offline Mode):',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildApiHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildMqttCard() {
    return StreamBuilder<String>(
      stream: _mqtt.tempStream,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.thermostat, color: Colors.orange, size: 40),
                const SizedBox(width: 20),
                Column(
                  children: <Widget>[
                    const Text(
                      'Water Temp',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '${snapshot.data ?? '21'}°C',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaterInput() {
    return Column(
      children: <Widget>[
        TextField(
          controller: _waterController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Enter amount (ml)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'LOG WATER',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApiHistory() {
    return FutureBuilder<List<WaterRecord>>(
      future: _historyFuture,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<WaterRecord>> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<WaterRecord> list = snapshot.data ?? <WaterRecord>[];
        if (list.isEmpty) {
          return const Text('No history found.');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (BuildContext context, int i) => Card(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: ListTile(
              leading: const Icon(Icons.history, color: Colors.blue),
              title: Text('${list[i].amount} ml'),
              subtitle: Text(list[i].time),
            ),
          ),
        );
      },
    );
  }
}
