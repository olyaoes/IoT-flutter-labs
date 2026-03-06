import 'package:flutter/material.dart';

void main() {
  runApp(const AquaBalanceAeroApp());
}

class AquaBalanceAeroApp extends StatelessWidget {
  const AquaBalanceAeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AquaBalance IoT',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007BFF),
          surface: const Color(0xFFFFFFFF),
        ),
      ),
      home: const WaterTrackerHome(),
    );
  }
}

class WaterTrackerHome extends StatefulWidget {
  const WaterTrackerHome({super.key});

  @override
  State<WaterTrackerHome> createState() => _WaterTrackerHomeState();
}

class _WaterTrackerHomeState extends State<WaterTrackerHome> {
  static const Color _aeroBlue = Color(0xFF00C6FF);
  static const Color _mintGreen = Color(0xFF0072FF);
  static const Color _darkSlate = Color(0xFF1A1A1A);

  final TextEditingController _amountController = TextEditingController();
  final int _dailyGoal = 2000;

  int _currentWater = 100;
  String _statusNote = 'Last log: +100 ml';

  void _handleDataInput() {
    setState(() {
      final String rawInput = _amountController.text.trim();

      if (rawInput.toLowerCase() == 'avada kedavra') {
        _currentWater = 0;
        _statusNote = 'Magic reset! Water is gone.';
      } else {
        final int? parsedValue = int.tryParse(rawInput);
        if (parsedValue != null && parsedValue > 0) {
          _currentWater += parsedValue;
          _statusNote = 'Added $parsedValue ml. Keep drinking!';
        } else {
          _statusNote = 'Error: Use a positive number.';
        }
      }
      _amountController.clear();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Colors.white, Color(0xFFE0F7FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 60,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildGlossyIcon(),
                  const SizedBox(height: 50),
                  _buildProgressText(),
                  const SizedBox(height: 10),
                  Text(
                    _statusNote,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 70),
                  _buildInputField(),
                  const SizedBox(height: 35),
                  _buildLogButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlossyIcon() {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: <Color>[Colors.white, _aeroBlue, _mintGreen],
          stops: <double>[0, 0.4, 1],
          center: Alignment(-0.2, -0.2),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _mintGreen.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
      ),
      child: const SizedBox(
        width: 150,
        height: 150,
        child: Center(
          child: Icon(
            Icons.water_drop,
            size: 90,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressText() {
    return Text(
      '$_currentWater / $_dailyGoal ml',
      style: const TextStyle(
        fontSize: 44,
        fontWeight: FontWeight.bold,
        color: _darkSlate,
        letterSpacing: -1,
      ),
    );
  }

  Widget _buildInputField() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _amountController,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18),
        decoration: const InputDecoration(
          hintText: 'Enter mL from sensor',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 22),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildLogButton() {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: <Color>[_aeroBlue, _mintGreen],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 65,
        child: ElevatedButton(
          onPressed: _handleDataInput,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: const Text(
            'LOG WATER',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
