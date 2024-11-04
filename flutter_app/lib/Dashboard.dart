/*import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
        final spots = docs.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value.data() as Map<String, dynamic>;
          return FlSpot(index.toDouble(), (data['weight'] ?? 0).toDouble());
        }).toList();
        return LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.pinkAccent),
            ),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: Colors.pinkAccent,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
                spots: spots,
              ),
            ],
          ),
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
        final bars = docs.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value.data() as Map<String, dynamic>;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (data['calories_burned'] ?? 0).toDouble(),
                color: Colors.pinkAccent,
                width: 10, // Vous pouvez ajuster la largeur du rod ici
                borderRadius:
                    BorderRadius.circular(4), // Pour ajouter un bord arrondi
              ),
            ],
          );
        }).toList();
        return BarChart(
          BarChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.pinkAccent),
            ),
            barGroups: bars,
          ),
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
        return PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                value: (data['proteins'] ?? 0).toDouble(),
                color: Colors.blue,
                title: 'Protéines',
              ),
              PieChartSectionData(
                value: (data['carbs'] ?? 0).toDouble(),
                color: Colors.orange,
                title: 'Glucides',
              ),
              PieChartSectionData(
                value: (data['fat'] ?? 0).toDouble(),
                color: Colors.red,
                title: 'Lipides',
              ),
            ],
            sectionsSpace: 2,
            centerSpaceRadius: 40,
          ),
        );
      },
    );
  }
}
*/