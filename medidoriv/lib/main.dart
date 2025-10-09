import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:medidoriv/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
///  Aplicación Flutter para medir y graficar corriente y voltaje eficaces
/// 2200515 - Daniel Jeshua Morelos Villamizar
/// 2204654 - Kevin Rafael Roa Garcia
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final database = FirebaseDatabase.instance.ref("mediciones");

Future<void> enviarDatos(double voltaje, double corriente) async {
  try {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await database.child("$timestamp").set({
      "voltaje": voltaje,
      "corriente": corriente,
    });
    debugPrint(" Datos enviados: V=$voltaje, I=$corriente");
  } catch (e) {
    debugPrint(" Error al enviar datos: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medidor de Corriente y Voltaje Eficaces',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, double>> _samples = [];

  ///  Función: cargar últimos 100 datos desde Firebase
  Future<void> _loadSamplesFromFirebase() async {
    final snapshot = await database.limitToLast(100).get();
    
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final sortedKeys = data.keys.map((k) => int.parse(k)).toList()..sort();
      final List<Map<String, double>> newSamples = [];

      for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i].toString();
      final value = Map<String, dynamic>.from(data[key]);
      newSamples.add({
        't': i.toDouble(), // tiempo relativo (0,1,2...)
        'Vrms': (value["voltaje"] as num).toDouble(),
        'Irms': (value["corriente"] as num).toDouble(),
      });
    }
      setState(() {
        _samples.clear();
        _samples.addAll(newSamples);
      });
      
    } else {
      debugPrint("No hay datos en Firebase todavía");
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medidor de Corriente y Voltaje Eficaces'),
        titleTextStyle: const TextStyle(fontSize: 26,color: Colors.black,),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // scroll para toda la app
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSamplesFromFirebase,

            child: const Text('Cargar 100 muestras de Firebase', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),//selectionColor: Color.fromARGB(255, 0, 0, 0),),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              for (int i = 0; i < 100; i++) {
                final voltaje = 120 + Random().nextDouble() * 4 - 2;
                final corriente = 0.01 + Random().nextDouble() * (10 - 0.01);
                await enviarDatos(voltaje, corriente);
                await Future.delayed(const Duration(milliseconds: 10));
              }
              debugPrint("100 datos enviados a Firebase");
            },
            child: const Text("Subir 100 datos de prueba", 
            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
          ),
          const SizedBox(height: 16),
          //  Tabla de datos
          if (_samples.isEmpty)
            const Center(),
          if (_samples.isNotEmpty)
            SizedBox(
              height: 300, // altura visible de la tabla
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical, // scroll vertical interno
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowHeight: 40,
                    columns: const [
                      DataColumn(label: Text('Tiempo (s)')),
                      DataColumn(label: Text('Vrms (V)')),
                      DataColumn(label: Text('Irms (A)')),
                    ],
                    rows: List.generate(_samples.length, (index) {
                      final s = _samples[index];
                      return DataRow(cells: [
                        DataCell(Text(s['t']!.toStringAsFixed(0))),
                        DataCell(Text(s['Vrms']!.toStringAsFixed(2))),
                        DataCell(Text(s['Irms']!.toStringAsFixed(3))),
                      ]);
                    }),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
         //  Gráfica de Voltaje
          if (_samples.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Gráfica de Voltaje (Vrms) vs Tiempo (s)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 20,
                          getTitlesWidget: (value, meta) =>
                              Text("${value.toInt()}s"),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) =>
                              Text(value.toStringAsFixed(0)),
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: false,
                        spots: _samples
                            .map((s) => FlSpot(s['t']!, s['Vrms']!))
                            .toList(),
                        dotData: FlDotData(show: false),
                        color: Colors.blue,
                        barWidth: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Gráfica de Corriente (Irms) vs Tiempo (s)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 20,
                          getTitlesWidget: (value, meta) =>
                              Text("${value.toInt()}s"),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) =>
                              Text(value.toStringAsFixed(0)),
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: false,
                        spots: _samples
                            .map((s) => FlSpot(s['t']!, s['Irms']!))
                            .toList(),
                        dotData: FlDotData(show: false),
                        color: Colors.red,
                        barWidth: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          //  Pie de página con logo
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Desarrollado por:\n'
                  'Daniel Jeshua Morelos Villamizar - 2200515\n'
                  'Kevin Rafael Roa Garcia - 2204654\n'
                  'Profesor: Jaime Guillermo Barrero Pérez\n'
                  'Universidad Industrial de Santander - 2025',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Image.asset(
                  'assets/uis.png',
                  height: 40,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  }
}
