import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'semaine';
  final _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text(
          'Tableau de Bord',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: _selectedPeriod,
                      items: ['jour', 'semaine', 'mois']
                          .map((period) => DropdownMenuItem(
                                value: period,
                                child: Text(period.toUpperCase()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPeriod = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Weight Progress Chart
                const Text(
                  'Progression du Poids',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
                const SizedBox(height: 10),
                _buildWeightChart(),
                const SizedBox(height: 30),
                // Activity Progress Chart
                const Text(
                  'Activité Physique',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
                const SizedBox(height: 10),
                _buildActivityChart(),
                const SizedBox(height: 30),
                // Nutrition Progress Chart
                const Text(
                  'Répartition Nutritionnelle',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
                const SizedBox(height: 10),
                _buildNutritionChart(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeightChart() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('health_data')
          .orderBy('timestamp', descending: true)
          .limit(30) // Limite de 30 jours de données
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final docs = snapshot.data!.docs;
        final data = docs.asMap().entries.map((entry) {
          final index = entry.key;
          final weight =
              (entry.value.data() as Map<String, dynamic>)['weight'] ?? 0;
          return ChartSampleData(x: index.toDouble(), y: weight.toDouble());
        }).toList();

        return SfCartesianChart(
          primaryXAxis: NumericAxis(),
          title: ChartTitle(text: 'Poids sur la période'),
          series: <ChartSeries<ChartSampleData, double>>[
            LineSeries<ChartSampleData, double>(
              dataSource: data,
              xValueMapper: (ChartSampleData data, _) => data.x,
              yValueMapper: (ChartSampleData data, _) => data.y,
              color: Colors.pinkAccent,
            ),
          ],
        );
      },
    );
  }

  Widget _buildActivityChart() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('activity_data')
          .orderBy('timestamp', descending: true)
          .limit(30)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final docs = snapshot.data!.docs;
        final data = docs.asMap().entries.map((entry) {
          final index = entry.key;
          final calories =
              (entry.value.data() as Map<String, dynamic>)['calories_burned'] ??
                  0;
          return ChartSampleData(x: index.toDouble(), y: calories.toDouble());
        }).toList();

        return SfCartesianChart(
          primaryXAxis: NumericAxis(),
          title: ChartTitle(text: 'Calories brûlées sur la période'),
          series: <ChartSeries<ChartSampleData, double>>[
            ColumnSeries<ChartSampleData, double>(
              dataSource: data,
              xValueMapper: (ChartSampleData data, _) => data.x,
              yValueMapper: (ChartSampleData data, _) => data.y,
              color: Colors.pinkAccent,
            ),
          ],
        );
      },
    );
  }

  Widget _buildNutritionChart() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('nutrition_data')
          .orderBy('timestamp', descending: true)
          .limit(1) // Dernier repas enregistré
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final total =
            (data['proteins'] ?? 0) + (data['carbs'] ?? 0) + (data['fat'] ?? 0);

        return SfCircularChart(
          title: ChartTitle(text: 'Répartition nutritionnelle'),
          series: <CircularSeries>[
            PieSeries<_PieChartData, String>(
              dataSource: [
                _PieChartData('Protéines', (data['proteins'] ?? 0).toDouble()),
                _PieChartData('Glucides', (data['carbs'] ?? 0).toDouble()),
                _PieChartData('Lipides', (data['fat'] ?? 0).toDouble()),
              ],
              xValueMapper: (_PieChartData data, _) => data.category,
              yValueMapper: (_PieChartData data, _) => data.value,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            )
          ],
        );
      },
    );
  }
}

class ChartSampleData {
  final double x;
  final double y;
  ChartSampleData({required this.x, required this.y});
}

class _PieChartData {
  final String category;
  final double value;
  _PieChartData(this.category, this.value);
}
