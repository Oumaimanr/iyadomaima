/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  _RecommendationsScreenState createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  bool _isLoading = true;
  List<Map<String, String>> recommendations = [];

  @override
  void initState() {
    super.initState();
    _generateRecommendations();
  }

  Future<void> _generateRecommendations() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Charger les données de l'utilisateur
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final healthData = userDoc.data()?['health_data'];

          if (healthData != null) {
            final currentWeight = healthData['weight'] ?? 0;
            final goalWeight = healthData['goal_weight'] ?? 0;

            // Simplifier les critères pour toujours générer des recommandations à titre de test
            if (true) {
              // Remplacer par une condition toujours vraie pour tester
              recommendations.add({
                'title': 'Faire une marche quotidienne',
                'description':
                    'Marchez pendant au moins 30 minutes chaque jour pour rester actif.',
              });
              recommendations.add({
                'title': 'Augmenter l\'apport en légumes',
                'description':
                    'Consommez davantage de légumes verts et de fibres pour une meilleure alimentation.',
              });
            }
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la génération des recommandations: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text(
          'Recommandations Personnalisées',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                ),
              )
            : recommendations.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune recommandation disponible pour le moment.',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) {
                      final recommendation = recommendations[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recommendation['title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pinkAccent,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                recommendation['description'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
*/