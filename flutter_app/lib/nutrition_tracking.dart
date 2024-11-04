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
        backgroundColor: Colors.pinkAccent,
        title: const Text(
          'Suivi Nutritionnel',
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
              children: [
                const SizedBox(height: 20),
                // Meal Input
                _buildTextField(
                  controller: _mealController,
                  label: "Nom du repas (ex: Déjeuner, Dîner)",
                  icon: Icons.restaurant,
                ),
                const SizedBox(height: 20),
                // Calories Input
                _buildTextField(
                  controller: _caloriesController,
                  label: "Calories (kcal)",
                  icon: Icons.local_fire_department,
                ),
                const SizedBox(height: 20),
                // Protein Input
                _buildTextField(
                  controller: _proteinController,
                  label: "Protéines (g)",
                  icon: Icons.fitness_center,
                ),
                const SizedBox(height: 20),
                // Carbs Input
                _buildTextField(
                  controller: _carbsController,
                  label: "Glucides (g)",
                  icon: Icons.rice_bowl,
                ),
                const SizedBox(height: 20),
                // Fat Input
                _buildTextField(
                  controller: _fatController,
                  label: "Lipides (g)",
                  icon: Icons.opacity,
                ),
                const SizedBox(height: 20),
                // Meal Time Input
                _buildTextField(
                  controller: _mealTimeController,
                  label: "Heure du repas (ex: Petit-déjeuner)",
                  icon: Icons.access_time,
                ),
                const SizedBox(height: 20),
                // Notes Input
                _buildTextField(
                  controller: _notesController,
                  label: "Notes sur le repas",
                  icon: Icons.notes,
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
                            AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveMeal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pinkAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: const Text(
                                "Enregistrer",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // View All Meals Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _viewAllMeals,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pinkAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: const Text(
                                "Voir tous les repas",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
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
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.pinkAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.pinkAccent, width: 2),
        ),
      ),
    );
  }

  Future<void> _saveMeal() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Valider les champs
      if (_mealController.text.isEmpty || _caloriesController.text.isEmpty) {
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

      // Structure des données du repas
      final mealData = {
        'meal_name': _mealController.text,
        'calories': int.tryParse(_caloriesController.text) ?? 0,
        'proteins': double.tryParse(_proteinController.text) ?? 0,
        'carbs': double.tryParse(_carbsController.text) ?? 0,
        'fat': double.tryParse(_fatController.text) ?? 0,
        'meal_time': _mealTimeController.text,
        'notes': _notesController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Sauvegarder les données dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('nutrition_data')
          .add(mealData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Repas enregistré avec succès!")),
      );

      // Vider les champs après l'enregistrement
      _mealController.clear();
      _caloriesController.clear();
      _proteinController.clear();
      _carbsController.clear();
      _fatController.clear();
      _mealTimeController.clear();
      _notesController.clear();
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

  Future<void> _viewAllMeals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final mealsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('nutrition_data')
        .orderBy('timestamp', descending: true)
        .get();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            "Tous les repas",
            style: TextStyle(
              color: Colors.pinkAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              children: mealsSnapshot.docs.map((doc) {
                final data = doc.data();
                return ListTile(
                  title: Text(
                    data['meal_name'] ?? "Repas inconnu",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _viewMealDetails(doc.id);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Fermer",
                style: TextStyle(
                  color: Colors.pinkAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _viewMealDetails(String mealId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final mealSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('nutrition_data')
        .doc(mealId)
        .get();

    if (!mealSnapshot.exists) {
      return;
    }

    final mealData = mealSnapshot.data();

    if (mealData == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          title: Text(
            mealData['meal_name'] ?? "Détails du repas",
            style: const TextStyle(
              color: Colors.pinkAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Calories: ${mealData['calories']} kcal",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Protéines: ${mealData['proteins']} g",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Glucides: ${mealData['carbs']} g",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Lipides: ${mealData['fat']} g",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Heure du repas: ${mealData['meal_time']}",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Notes: ${mealData['notes'] ?? 'Aucune'}",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Fermer",
                style: TextStyle(
                  color: Colors.pinkAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
