import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab1_water/cubits/water_cubit.dart';
import 'package:lab1_water/cubits/water_state.dart';
import 'package:lab1_water/models/water_record.dart';
import 'package:lab1_water/screens/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _waterController = TextEditingController();

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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00BFFF),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const ProfilePage(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<WaterCubit, WaterState>(
        builder: (BuildContext context, WaterState state) {
          if (state is WaterLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WaterError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is WaterLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: <Widget>[
                  _buildMqttCard(state.currentTemp),
                  const SizedBox(height: 30),
                  Text(
                    '${state.currentIntake} / 2000 ml',
                    style: const TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Daily goal progress',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  _buildWaterInput(context),
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
                  _buildHistoryList(state.history),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMqttCard(String temp) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.thermostat, color: Colors.orange, size: 40),
            const SizedBox(width: 20),
            Column(
              children: <Widget>[
                const Text('Water Temp', style: TextStyle(color: Colors.grey)),
                Text(
                  '$temp°C',
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
  }

  Widget _buildWaterInput(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: _waterController,
          keyboardType: TextInputType.number,
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
            onPressed: () {
              final String text = _waterController.text;
              if (text.isNotEmpty && int.tryParse(text) != null) {
                context.read<WaterCubit>().addWater(int.parse(text));
                _waterController.clear();
              }
            },
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

  Widget _buildHistoryList(List<WaterRecord> list) {
    if (list.isEmpty) {
      return const Center(child: Text('No history found.'));
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
  }
}
