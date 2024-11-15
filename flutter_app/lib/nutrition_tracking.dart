import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NutritionTrackingScreen extends StatefulWidget {
  const NutritionTrackingScreen({super.key});

  @override
  _NutritionTrackingScreenState createState() =>
      _NutritionTrackingScreenState();
}

class _NutritionTrackingScreenState extends State<NutritionTrackingScreen> {
  final _mealController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _mealTimeController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _mealController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _mealTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Nutrition Tracker',
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
                            Icons.restaurant,
                            size: 60,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                  _buildTextField(
                    controller: _mealController,
                    label: "Nom du repas (ex: Déjeuner, Dîner)",
                    icon: Icons.restaurant,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _caloriesController,
                    label: "Calories (kcal)",
                    icon: Icons.local_fire_department,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _proteinController,
                    label: "Protéines (g)",
                    icon: Icons.fitness_center,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _carbsController,
                    label: "Glucides (g)",
                    icon: Icons.rice_bowl,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _fatController,
                    label: "Lipides (g)",
                    icon: Icons.opacity,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _mealTimeController,
                    label: "Heure du repas (ex: Petit-déjeuner)",
                    icon: Icons.access_time,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _notesController,
                    label: "Notes sur le repas",
                    icon: Icons.notes,
                  ),
                  const SizedBox(height: 30),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.teal),
                        )
                      : Column(
                          children: [
                            SizedBox(
                              width: 300,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _saveMeal,
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
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 300,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _viewAllMeals,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 10,
                                ),
                                child: const Text(
                                  "Voir tous les repas",
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
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
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

  Future<void> _saveMeal() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
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

      if (_mealController.text.isEmpty ||
          _caloriesController.text.isEmpty ||
          _proteinController.text.isEmpty ||
          _carbsController.text.isEmpty ||
          _fatController.text.isEmpty ||
          _mealTimeController.text.isEmpty) {
        setState(() {
          _errorMessage = "Veuillez remplir tous les champs.";
          _isLoading = false;
        });
        return;
      }

      final mealData = {
        'meal': _mealController.text,
        'calories': int.tryParse(_caloriesController.text) ?? 0,
        'proteins': int.tryParse(_proteinController.text) ?? 0,
        'carbs': int.tryParse(_carbsController.text) ?? 0,
        'fat': int.tryParse(_fatController.text) ?? 0,
        'mealTime': _mealTimeController.text,
        'notes': _notesController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('nutrition')
          .add(mealData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Repas enregistré avec succès!")),
      );

      _mealController.clear();
      _caloriesController.clear();
      _proteinController.clear();
      _carbsController.clear();
      _fatController.clear();
      _mealTimeController.clear();
      _notesController.clear();
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors de l'enregistrement.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _viewAllMeals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final meals = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('nutrition')
        .orderBy('timestamp', descending: true)
        .get();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Liste des repas"),
          content: SingleChildScrollView(
            child: Column(
              children: meals.docs.map((doc) {
                final data = doc.data();
                return ListTile(
                  title: Text(data['meal'] ?? "Nom inconnu"),
                  subtitle: Text("Calories: ${data['calories']} kcal"),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer"),
            ),
          ],
        );
      },
    );
  }
}
