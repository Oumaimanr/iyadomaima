import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:io' show Platform, File;
import 'package:flutter_animate/flutter_animate.dart';

class PdfSummaryScreen extends StatefulWidget {
  const PdfSummaryScreen({super.key});

  @override
  _PdfSummaryScreenState createState() => _PdfSummaryScreenState();
}

class _PdfSummaryScreenState extends State<PdfSummaryScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? _healthInfo;
  Map<String, dynamic>? _nutritionInfo;
  List<Map<String, dynamic>> _activityInfo = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      if (_user == null) {
        setState(() {
          _errorMessage = "Utilisateur non connecté.";
          _isLoading = false;
        });
        return;
      }

      // Fetch health information
      final healthSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .collection('health_data')
          .limit(1)
          .get();

      if (healthSnapshot.docs.isNotEmpty) {
        _healthInfo = healthSnapshot.docs.first.data();
      }

      // Fetch nutrition information
      final nutritionSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .collection('nutrition')
          .get();

      if (nutritionSnapshot.docs.isNotEmpty) {
        _nutritionInfo = {
          'calories': nutritionSnapshot.docs
              .fold<int>(0, (sum, doc) => sum + (doc['calories'] ?? 0) as int),
          'proteins': nutritionSnapshot.docs
              .fold<int>(0, (sum, doc) => sum + (doc['proteins'] ?? 0) as int),
          'carbs': nutritionSnapshot.docs
              .fold<int>(0, (sum, doc) => sum + (doc['carbs'] ?? 0) as int),
          'fat': nutritionSnapshot.docs
              .fold<int>(0, (sum, doc) => sum + (doc['fat'] ?? 0) as int),
        };
      }

      // Fetch activity information
      final activitySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .collection('activity_data')
          .orderBy('timestamp', descending: true)
          .get();

      _activityInfo = activitySnapshot.docs.map((doc) => doc.data()).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors du chargement des données: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFA7FFEB), Color(0xFF1DE9B6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Résumé de Suivi de Santé',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade700, Colors.teal.shade300],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.summarize,
                        size: 80,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_healthInfo != null)
                                  _buildInfoCard(
                                    'Informations de Santé',
                                    _buildHealthInfo(),
                                  ).animate().slideX(
                                      begin: -50,
                                      duration: 600.ms,
                                      delay: 300.ms),
                                const SizedBox(height: 20),
                                if (_nutritionInfo != null)
                                  _buildInfoCard(
                                    'Informations Nutritionnelles',
                                    _buildNutritionInfo(),
                                  ).animate().slideX(
                                      begin: 50,
                                      duration: 600.ms,
                                      delay: 600.ms),
                                const SizedBox(height: 20),
                                if (_activityInfo.isNotEmpty)
                                  _buildInfoCard(
                                    'Historique des Activités',
                                    _buildActivityInfo(),
                                  ).animate().slideY(
                                      begin: 50,
                                      duration: 600.ms,
                                      delay: 900.ms),
                                const SizedBox(height: 40),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: _generatePdf,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.teal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 40),
                                    ),
                                    child: const Text(
                                      "Télécharger le Rapport",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                                    .animate()
                                    .scale(duration: 600.ms, delay: 1200.ms),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, Widget content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.teal,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }

  Widget _buildHealthInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Poids: ${_healthInfo!['weight']} kg"),
        Text("Taille: ${_healthInfo!['height']} cm"),
        Text("Objectif de Poids: ${_healthInfo!['goal_weight']} kg"),
      ],
    );
  }

  Widget _buildNutritionInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Calories Totales: ${_nutritionInfo!['calories']} kcal"),
        Text("Protéines Totales: ${_nutritionInfo!['proteins']} g"),
        Text("Glucides Totaux: ${_nutritionInfo!['carbs']} g"),
        Text("Lipides Totaux: ${_nutritionInfo!['fat']} g"),
      ],
    );
  }

  Widget _buildActivityInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._activityInfo.map(
          (activity) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Type d'activité: ${activity['activity_type']}"),
                Text("Durée: ${activity['duration']} minutes"),
                Text("Calories Brûlées: ${activity['calories_burned']}"),
                Text("Distance: ${activity['distance']} km"),
                Text("Intensité: ${activity['intensity']}"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _generatePdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Rapport de Suivi de Santé',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal,
                  )),
              pw.SizedBox(height: 20),
              if (_healthInfo != null) _buildPdfHealthInfo(),
              pw.SizedBox(height: 20),
              if (_nutritionInfo != null) _buildPdfNutritionInfo(),
              pw.SizedBox(height: 20),
              if (_activityInfo.isNotEmpty) _buildPdfActivityInfo(),
            ],
          ),
        ),
      );

      // Use platform-specific directory selection
      final directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      if (directory == null) {
        throw Exception("Impossible de trouver un répertoire valide");
      }

      final file = File("${directory.path}/rapport_suivi_sante.pdf");
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Rapport enregistré avec succès: ${file.path}")),
      );
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors de la génération du rapport: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  pw.Widget _buildPdfHealthInfo() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Informations de Santé',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal,
            )),
        pw.SizedBox(height: 10),
        pw.Text("Poids: ${_healthInfo!['weight']} kg"),
        pw.Text("Taille: ${_healthInfo!['height']} cm"),
        pw.Text("Objectif de Poids: ${_healthInfo!['goal_weight']} kg"),
      ],
    );
  }

  pw.Widget _buildPdfNutritionInfo() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Informations Nutritionnelles',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal,
            )),
        pw.SizedBox(height: 10),
        pw.Text("Calories Totales: ${_nutritionInfo!['calories']} kcal"),
        pw.Text("Protéines Totales: ${_nutritionInfo!['proteins']} g"),
        pw.Text("Glucides Totaux: ${_nutritionInfo!['carbs']} g"),
        pw.Text("Lipides Totaux: ${_nutritionInfo!['fat']} g"),
      ],
    );
  }

  pw.Widget _buildPdfActivityInfo() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Historique des Activités',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal,
            )),
        pw.SizedBox(height: 10),
        ..._activityInfo.map(
          (activity) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Type d'activité: ${activity['activity_type']}"),
              pw.Text("Durée: ${activity['duration']} minutes"),
              pw.Text("Calories Brûlées: ${activity['calories_burned']}"),
              pw.Text("Distance: ${activity['distance']} km"),
              pw.Text("Intensité: ${activity['intensity']}"),
              pw.SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}
