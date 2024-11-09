import 'package:flutter/material.dart';
import 'package:flutter_app/health_info.dart';
import 'package:flutter_app/activity_tracking.dart';
import 'package:flutter_app/nutrition_tracking.dart';
import 'package:flutter_app/dashboard.dart';
//import 'package:flutter_app/recommendations.dart'; // Importer la nouvelle page de recommandations

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HealthInfoScreen(),
    const ActivityTrackingScreen(),
    const NutritionTrackingScreen(),
    const DashboardScreen(),
    //const RecommendationsScreen(), // Nouvelle page de recommandations
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Santé',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run),
            label: 'Activité',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                          child: Image.asset(
                            'assets/images/homeimage.webp', // Update this with your image path
                            height: 100,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Avis de non-responsabilité concernant la santé",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Information Cards
                  Expanded(
                    child: ListView(
                      children: [
                        _buildInfoCard(
                          title: "Pas un dispositif médical",
                          description:
                              "Cette application propose des informations générales sur la condition physique et la santé et ne remplace pas un avis médical professionnel.",
                        ),
                        const SizedBox(height: 20),
                        _buildInfoCard(
                          title: "À titre informatif",
                          description:
                              "Consultez votre médecin ou professionnel de la santé avant de commencer tout nouveau programme d'exercice ou de modifier votre régime alimentaire.",
                        ),
                        const SizedBox(height: 20),
                        _buildInfoCard(
                          title: "Limite des fonctionnalités",
                          description:
                              "Veuillez noter que cette application ne mesure pas la tension artérielle, la glycémie, mais peut vous aider à créer un journal de données.",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.teal),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
