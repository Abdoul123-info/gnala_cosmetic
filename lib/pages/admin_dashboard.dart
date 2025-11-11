import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../routes.dart';
import 'add_product_page.dart';
import 'edit_product_page.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../utils/responsive.dart';
import '../utils/image_url.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductService _productService = ProductService();
  String? _adminName;
  int _totalUsers = 0;
  int _totalProducts = 0;
  bool _isLoading = true;
  String _selectedCategory = 'Tous'; // Filtre par catégorie
  
  final List<String> _categories = [
    'Tous',
    'Recommandés',
    'Nouveautés',
    'Visage',
    'Corps',
    'Cheveux',
    'Homme',
    'Maquillage',
    'Parfum',
    'Promotions / Meilleures ventes',
  ];

  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _loadUsersCount();
    _loadProductsCount();
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

  Future<void> _deleteProduct(Product product) async {
    // Afficher une boîte de dialogue de confirmation
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer le produit "${product.name}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _productService.deleteProduct(product.id);
        Fluttertoast.showToast(
          msg: "Produit supprimé avec succès",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        // Rafraîchir le compteur
        _loadProductsCount();
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Erreur lors de la suppression: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  void _navigateToAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductPage()),
    ).then((_) {
      // Rafraîchir le compteur après retour
      _loadProductsCount();
    });
  }

  void _navigateToEditProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProductPage(product: product)),
    ).then((_) {
      // Rafraîchir le compteur après retour
      _loadProductsCount();
    });
  }

  Future<void> _toggleRecommended(Product product) async {
    try {
      Product updatedProduct = product.copyWith(
        isRecommended: !product.isRecommended,
        updatedAt: DateTime.now(),
      );
      await _productService.updateProduct(updatedProduct);
      Fluttertoast.showToast(
        msg: product.isRecommended 
            ? "Produit retiré des recommandés" 
            : "Produit ajouté aux recommandés",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur lors de la modification: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _toggleAvailable(Product product) async {
    try {
      Product updatedProduct = product.copyWith(
        isAvailable: !product.isAvailable,
        updatedAt: DateTime.now(),
      );
      await _productService.updateProduct(updatedProduct);
      Fluttertoast.showToast(
        msg: product.isAvailable 
            ? "Produit marqué comme non disponible" 
            : "Produit marqué comme disponible",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur lors de la modification: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
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
                    value: '0',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.attach_money,
                    title: 'Revenus',
                    value: '0 FCFA',
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
              height: 376, // 2 lignes * ~180px + espacement
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
                    Fluttertoast.showToast(
                      msg: "Fonctionnalité à venir",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  },
                ),
                _buildManagementCard(
                  icon: Icons.shopping_bag,
                  title: 'Produits',
                  subtitle: 'Gérer les produits',
                  color: Colors.green,
                  onTap: () {
                    Fluttertoast.showToast(
                      msg: "Fonctionnalité à venir",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  },
                ),
                _buildManagementCard(
                  icon: Icons.shopping_cart,
                  title: 'Commandes',
                  subtitle: 'Gérer les commandes',
                  color: Colors.orange,
                  onTap: () {
                    Fluttertoast.showToast(
                      msg: "Fonctionnalité à venir",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  },
                ),
                _buildManagementCard(
                  icon: Icons.analytics,
                  title: 'Analytics',
                  subtitle: 'Voir les statistiques',
                  color: Colors.purple,
                  onTap: () {
                    Fluttertoast.showToast(
                      msg: "Fonctionnalité à venir",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  },
                ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section gestion des produits
            Container(
              width: double.infinity,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gestion des produits',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ElevatedButton.icon(
                onPressed: _navigateToAddProduct,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A855),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/test');
                },
                icon: const Icon(Icons.bug_report, size: 18),
                label: const Text('Test Firebase'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4C896),
                  foregroundColor: const Color(0xFF4A6456),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Filtre par catégorie
                  const Text(
                    'Filtrer par catégorie:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFD4A855) : const Color(0xFFE8DDB5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFD4C896),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.black : const Color(0xFF4A6456),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<Product>>(
                    stream: _productService.getProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4C896)),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Text(
                          'Erreur lors du chargement des produits',
                          style: TextStyle(color: Color(0xFF4A6456)),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 48,
                                  color: Color(0xFF4A6456).withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Aucun produit trouvé',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF4A6456),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Commencez par ajouter votre premier produit',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF4A6456),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                      }

                      // Filtrer les produits par catégorie
                      List<Product> filteredProducts = snapshot.data!;
                      if (_selectedCategory != 'Tous') {
                        if (_selectedCategory == 'Recommandés') {
                          filteredProducts = filteredProducts.where((p) => p.isRecommended).toList();
                        } else if (_selectedCategory == 'Nouveautés') {
                          filteredProducts = filteredProducts.where((p) => p.isNew).toList();
                        } else if (_selectedCategory == 'Promotions / Meilleures ventes') {
                          filteredProducts = filteredProducts.where((p) => p.isPromotion).toList();
                        } else {
                          filteredProducts = filteredProducts.where((product) {
                            return product.category == _selectedCategory;
                          }).toList();
                        }
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          Product product = filteredProducts[index];
                          return _buildProductCard(product);
                        },
                      );
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

  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4C896), width: 2),
      ),
      child: Row(
        children: [
          // Image du produit
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: product.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      optimizeCloudinaryUrl(product.imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.shopping_bag,
                    color: Colors.grey,
                  ),
          ),
          const SizedBox(width: 12),
          
          // Informations du produit
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A6456),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A6456),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.price.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4A855),
                  ),
                ),
              ],
            ),
          ),
          
          // Boutons d'action
          Column(
            children: [
              // Toggle Promotion / Meilleures ventes
              IconButton(
                onPressed: () async {
                  try {
                    final updated = product.copyWith(isPromotion: !product.isPromotion, updatedAt: DateTime.now());
                    await _productService.updateProduct(updated);
                    Fluttertoast.showToast(
                      msg: updated.isPromotion ? "Produit ajouté aux promotions" : "Produit retiré des promotions",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    );
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: "Erreur lors de la modification: $e",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
                },
                icon: Icon(
                  product.isPromotion ? Icons.local_fire_department : Icons.local_fire_department_outlined,
                  color: product.isPromotion ? Colors.redAccent : const Color(0xFF4A6456),
                ),
                tooltip: product.isPromotion ? 'Retirer des promotions' : 'Ajouter aux promotions',
              ),
              // Toggle nouveauté
              IconButton(
                onPressed: () async {
                  try {
                    final updated = product.copyWith(isNew: !product.isNew, updatedAt: DateTime.now());
                    await _productService.updateProduct(updated);
                    Fluttertoast.showToast(
                      msg: updated.isNew ? "Produit marqué comme nouveauté" : "Produit retiré des nouveautés",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    );
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: "Erreur lors de la modification: $e",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
                },
                icon: Icon(
                  product.isNew ? Icons.fiber_new : Icons.new_releases_outlined,
                  color: product.isNew ? Colors.blue : const Color(0xFF4A6456),
                ),
                tooltip: product.isNew ? 'Retirer des nouveautés' : 'Marquer comme nouveauté',
              ),
              IconButton(
                onPressed: () => _toggleAvailable(product),
                icon: Icon(
                  product.isAvailable ? Icons.check_circle : Icons.cancel,
                  color: product.isAvailable ? Colors.green : Colors.red,
                ),
                tooltip: product.isAvailable ? 'Marquer comme non disponible' : 'Marquer comme disponible',
              ),
              IconButton(
                onPressed: () => _toggleRecommended(product),
                icon: Icon(
                  product.isRecommended ? Icons.star : Icons.star_border,
                  color: product.isRecommended ? Colors.amber : const Color(0xFF4A6456),
                ),
                tooltip: product.isRecommended ? 'Retirer des recommandés' : 'Ajouter aux recommandés',
              ),
              IconButton(
                onPressed: () => _navigateToEditProduct(product),
                icon: const Icon(Icons.edit, color: Color(0xFF4A6456)),
                tooltip: 'Modifier',
              ),
              IconButton(
                onPressed: () => _deleteProduct(product),
                icon: const Icon(Icons.delete, color: Color(0xFF4A6456)),
                tooltip: 'Supprimer',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
