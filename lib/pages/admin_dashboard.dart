import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../routes.dart';
import 'users_management_page.dart';
import 'products_management_page.dart';
import '../services/product_service.dart';
import '../services/stats_service.dart';
import '../utils/responsive.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductService _productService = ProductService();
  final StatsService _statsService = StatsService();
  String? _adminName;
  int _totalUsers = 0;
  int _totalProducts = 0;
  int _totalOrders = 0;
  int _totalRevenue = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _loadUsersCount();
    _loadProductsCount();
    _loadStats();
  }

  Future<void> _loadAdminData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          setState(() {
            _adminName = userDoc.get('name') ?? 'Administrateur';
          });
        } else {
          setState(() {
            _adminName = 'Administrateur';
          });
        }
      }
    } catch (e) {
      setState(() {
        _adminName = 'Administrateur';
      });
    }
  }

  Future<void> _loadUsersCount() async {
    try {
      QuerySnapshot usersSnapshot = await _firestore
          .collection('users')
          .get();
      
      setState(() {
        _totalUsers = usersSnapshot.docs.length;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur lors du chargement des utilisateurs",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _loadProductsCount() async {
    try {
      int count = await _productService.getProductsCount();
      setState(() {
        _totalProducts = count;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Erreur lors du chargement des produits",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _statsService.fetchStats();
      setState(() {
        _totalOrders = stats.deliveredOrdersCount; // Afficher les commandes livrées
        _totalRevenue = stats.totalRevenue;
      });
    } catch (e) {
      print('Erreur chargement stats: $e');
      // Ne pas afficher d'erreur, juste garder les valeurs à 0
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      if (mounted) {
        AppRoutes.navigateToLogin(context);
        Fluttertoast.showToast(
          msg: "Déconnexion réussie",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur lors de la déconnexion",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF4A6456),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4C896)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF4A6456),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A6456),
        foregroundColor: const Color(0xFFD4C896),
        title: const Text(
          'Tableau de bord Admin',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFD4C896)),
            onPressed: _signOut,
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.getPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section de bienvenue admin
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A6456), Color(0xFF5A7566)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD4C896), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: Color(0xFFD4C896),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bienvenue, $_adminName !',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gérez votre application Gnala Cosmetic',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFD4C896),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Statistiques
            const Text(
              'Statistiques',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Cartes de statistiques
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.people,
                    title: 'Utilisateurs',
                    value: _totalUsers.toString(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.shopping_bag,
                    title: 'Produits',
                    value: _totalProducts.toString(),
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.shopping_cart,
                    title: 'Commandes',
                    value: _totalOrders.toString(),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.attach_money,
                    title: 'Revenus',
                    value: _formatPrice(_totalRevenue),
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Gestion
            const Text(
              'Gestion',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Grille de gestion (hauteur bornée pour éviter taille nulle/unbounded)
            SizedBox(
              height: 180, // 1 ligne * ~180px
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                _buildManagementCard(
                  icon: Icons.people,
                  title: 'Utilisateurs',
                  subtitle: 'Gérer les utilisateurs',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UsersManagementPage(),
                      ),
                    );
                  },
                ),
                _buildManagementCard(
                  icon: Icons.shopping_bag,
                  title: 'Produits',
                  subtitle: 'Gérer les produits',
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductsManagementPage(),
                      ),
                    ).then((_) {
                      // Rafraîchir le compteur après retour
                      _loadProductsCount();
                    });
                  },
                ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    if (price == 0) return '0 FCFA';
    return '${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )} FCFA';
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8DDB5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4C896), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF4A6456), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A6456),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4A6456),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final border = BorderRadius.circular(12);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 160, minWidth: 160),
      child: Material(
        color: const Color(0xFFE8DDB5),
        borderRadius: border,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        child: InkWell(
          onTap: onTap,
          borderRadius: border,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: const Color(0xFF4A6456),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A6456),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4A6456),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
