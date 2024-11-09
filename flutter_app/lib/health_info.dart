import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter_app/activity_tracking.dart';

class HealthInfoScreen extends StatefulWidget {
  const HealthInfoScreen({super.key});

  @override
  _HealthInfoScreenState createState() => _HealthInfoScreenState();
}

class _HealthInfoScreenState extends State<HealthInfoScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _goalController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _healthDataDocId;

  @override
  void initState() {
    super.initState();
    _fetchHealthInfo();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Health Tracker',
          style: TextStyle(
            color: Colors.teal,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                MediaQuery.of(context).padding.top,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFA7FFEB), Color(0xFF1DE9B6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Header Image and Title
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.white, Colors.teal],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.health_and_safety,
                            size: 60,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                  // Input Fields
                  _buildTextField(
                    controller: _weightController,
                    label: "Poids (kg)",
                    icon: Icons.monitor_weight,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _heightController,
                    label: "Taille (cm)",
                    icon: Icons.height,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _goalController,
                    label: "Objectif de poids (kg)",
                    icon: Icons.flag,
                  ),
                  const SizedBox(height: 30),
                  // Display Error Message if Any
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  // Save Button
                  _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : SizedBox(
                          width: 300,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveHealthInfo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 10,
                            ),
                            child: const Text(
                              "Enregistrer",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
    );
  }

  Future<void> _fetchHealthInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = "Utilisateur non connecté.";
          _isLoading = false;
        });
        return;
      }

      final healthDataSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('health_data')
          .limit(1)
          .get();

      if (healthDataSnapshot.docs.isNotEmpty) {
        final healthDataDoc = healthDataSnapshot.docs.first;
        final healthData = healthDataDoc.data();
        _healthDataDocId = healthDataDoc.id;
        _weightController.text = (healthData['weight'] ?? '').toString();
        _heightController.text = (healthData['height'] ?? '').toString();
        _goalController.text = (healthData['goal_weight'] ?? '').toString();
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            "Une erreur est survenue lors du chargement des données.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveHealthInfo() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Validate inputs
      if (_weightController.text.isEmpty ||
          _heightController.text.isEmpty ||
          _goalController.text.isEmpty) {
        setState(() {
          _errorMessage = "Veuillez entrer toutes les informations.";
          _isLoading = false;
        });
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = "Utilisateur non connecté.";
          _isLoading = false;
        });
        return;
      }

      final healthData = {
        'weight': double.tryParse(_weightController.text) ?? 0,
        'height': double.tryParse(_heightController.text) ?? 0,
        'goal_weight': double.tryParse(_goalController.text) ?? 0,
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (_healthDataDocId != null) {
        // Update existing document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('health_data')
            .doc(_healthDataDocId)
            .update(healthData);
      } else {
        // Create new document
        final newDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('health_data')
            .add(healthData);
        _healthDataDocId = newDoc.id;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Informations de santé enregistrées avec succès!")),
      );
    } catch (e) {
      setState(() {
        _errorMessage = "Une erreur est survenue. Veuillez réessayer.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
