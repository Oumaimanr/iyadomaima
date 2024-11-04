import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityTrackingScreen extends StatefulWidget {
  const ActivityTrackingScreen({super.key});

  @override
  _ActivityTrackingScreenState createState() => _ActivityTrackingScreenState();
}

class _ActivityTrackingScreenState extends State<ActivityTrackingScreen> {
  final _activityTypeController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _distanceController = TextEditingController();
  final _notesController = TextEditingController();
  String _intensity = 'Modérée';
  DateTime? _activityDate;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLastActivity();
  }

  @override
  void dispose() {
    _activityTypeController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _distanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadLastActivity() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final lastActivity = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('activity_data')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (lastActivity.docs.isNotEmpty) {
          final data = lastActivity.docs.first.data();
          setState(() {
            _activityTypeController.text = data['activity_type'] ?? '';
            _durationController.text = (data['duration'] ?? '').toString();
            _caloriesController.text =
                (data['calories_burned'] ?? '').toString();
            _distanceController.text = (data['distance'] ?? '').toString();
            _intensity = data['intensity'] ?? 'Modérée';
            _activityDate = data['activity_date'] != null
                ? (data['activity_date'] as Timestamp).toDate()
                : null;
            _notesController.text = data['notes'] ?? '';
          });
        } else {
          setState(() {
            _errorMessage = "Aucune activité trouvée. Veuillez en ajouter une.";
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage =
              "Erreur lors du chargement de l'activité : \${e.toString()}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text(
          'Suivi des Activités',
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
                // Activity Type Input
                _buildTextField(
                  controller: _activityTypeController,
                  label: "Type d'activité (ex: marche, course)",
                  icon: Icons.directions_run,
                ),
                const SizedBox(height: 20),
                // Duration Input
                _buildTextField(
                  controller: _durationController,
                  label: "Durée (minutes)",
                  icon: Icons.timer,
                ),
                const SizedBox(height: 20),
                // Calories Burned Input
                _buildTextField(
                  controller: _caloriesController,
                  label: "Calories brûlées",
                  icon: Icons.local_fire_department,
                ),
                const SizedBox(height: 20),
                // Distance Input
                _buildTextField(
                  controller: _distanceController,
                  label: "Distance parcourue (km)",
                  icon: Icons.map,
                ),
                const SizedBox(height: 20),
                // Intensity Dropdown
                DropdownButtonFormField<String>(
                  value: _intensity,
                  decoration: InputDecoration(
                    labelText: "Intensité de l'activité",
                    prefixIcon: const Icon(Icons.speed),
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
                      borderSide:
                          const BorderSide(color: Colors.pinkAccent, width: 2),
                    ),
                  ),
                  items: ['Légère', 'Modérée', 'Élevée']
                      .map((label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _intensity = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // Activity Date Picker
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.pinkAccent),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _activityDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _activityDate = pickedDate;
                          });
                        }
                      },
                      child: Text(
                        "Date de l'activité: ${_activityDate?.toLocal().toString().split(' ')[0]}",
                        style: const TextStyle(
                          color: Colors.pinkAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Notes Input
                _buildTextField(
                  controller: _notesController,
                  label: "Notes sur l'activité",
                  icon: Icons.note,
                  isMultiline: true,
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
                              onPressed: _saveActivity,
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
                          // View All Activities Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _viewAllActivities,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pinkAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: const Text(
                                "Voir toutes les activités",
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
    bool isMultiline = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isMultiline ? TextInputType.multiline : TextInputType.text,
      maxLines: isMultiline ? 3 : 1,
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

  Future<void> _saveActivity() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Validate inputs
      if (_activityTypeController.text.isEmpty ||
          _durationController.text.isEmpty ||
          _caloriesController.text.isEmpty ||
          _distanceController.text.isEmpty) {
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

      final activityData = {
        'activity_type': _activityTypeController.text,
        'duration': int.tryParse(_durationController.text) ?? 0,
        'calories_burned': int.tryParse(_caloriesController.text) ?? 0,
        'distance': double.tryParse(_distanceController.text) ?? 0,
        'intensity': _intensity,
        'activity_date': _activityDate ?? FieldValue.serverTimestamp(),
        'notes': _notesController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('activity_data')
          .add(activityData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Activité enregistrée avec succès!")),
      );

      // Optionally clear fields after saving
      _activityTypeController.clear();
      _durationController.clear();
      _caloriesController.clear();
      _distanceController.clear();
      _notesController.clear();
      setState(() {
        _intensity = 'Modérée';
        _activityDate = null;
      });
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

  Future<void> _viewAllActivities() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final activitiesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('activity_data')
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
            "Toutes les activités",
            style: TextStyle(
              color: Colors.pinkAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              children: activitiesSnapshot.docs.map((doc) {
                final data = doc.data();
                return ListTile(
                  title: Text(
                    data['activity_type'] ?? "Activité inconnue",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _viewActivityDetails(data);
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

  void _viewActivityDetails(Map<String, dynamic> activityData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          title: Text(
            activityData['activity_type'] ?? "Détails de l'activité",
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
                "Durée: ${activityData['duration']} minutes",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Calories brûlées: ${activityData['calories_burned']}",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Distance: ${activityData['distance']} km",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Intensité: ${activityData['intensity']}",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Date: ${(activityData['activity_date'] as Timestamp).toDate().toLocal().toString().split(' ')[0]}",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Notes: ${activityData['notes'] ?? 'Aucune'}",
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
