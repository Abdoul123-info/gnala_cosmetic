import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../routes.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/favorites_service.dart';
import '../providers/cart_provider.dart';
import '../utils/responsive.dart';
import '../utils/image_url.dart';

import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductService _productService = ProductService();
  final FavoritesService _favoritesService = FavoritesService();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _productsKey = GlobalKey();
  String? _userName;
  bool _isLoading = true;
  String _selectedCategory = 'Recommandés';

  static const String _facebookUrl = 'https://www.facebook.com/profile.php?id=61582554140219';
  static const String _whatsappUrl = 'https://wa.me/22789831840';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          setState(() {
            _userName = userDoc.get('name') ?? 'Utilisateur';
            _isLoading = false;
          });
        } else {
          setState(() {
            _userName = 'Utilisateur';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Erreur lors du chargement des données utilisateur",
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
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF4A6456),
      drawer: _buildNavigationDrawer(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: ResponsiveUtils.getPadding(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: const Color(0xFFD4C896),
                      size: ResponsiveUtils.getIconSize(context),
                    ),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  Flexible(
                    child: Text(
                      'Salut, $_userName',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveUtils.getBodyFontSize(context),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Panier avec badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.shopping_cart_outlined,
                              color: const Color(0xFFD4C896),
                              size: ResponsiveUtils.getIconSize(context),
                            ),
                            onPressed: () {
                              AppRoutes.navigateToCart(context);
                            },
                          ),
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Consumer<CartProvider>(
                              builder: (context, cart, child) {
                                if (cart.totalItems > 0) {
                                  return Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '${cart.totalItems}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                    child: Padding(
                  padding: ResponsiveUtils.getPadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar (fond vert, texte blanc)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C4B2E),
                          border: Border.all(color: const Color(0xFFD4C896), width: 2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Recherche',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: ResponsiveUtils.getBodyFontSize(context),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white,
                              size: ResponsiveUtils.getIconSize(context),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Categories Section
                      Row(
                        key: _productsKey,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Catégories',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveUtils.getTitleFontSize(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = 'Tous';
                              });
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final ctx = _productsKey.currentContext;
                                if (ctx != null) {
                                  Scrollable.ensureVisible(
                                    ctx,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              });
                            },
                            child: Text(
                              'Voir plus',
                              style: TextStyle(
                                color: const Color(0xFFD4C896),
                                fontSize: ResponsiveUtils.getSmallFontSize(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Category Buttons (wrap pour s'adapter)
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          'Recommandés',
                          'Nouveautés',
                          'Visage',
                          'Corps',
                          'Cheveux',
                          'Homme',
                          'Maquillage',
                          'Parfum',
                          'Promotions / Meilleures ventes',
                        ].map((cat) => _buildCategoryChip(cat, _selectedCategory == cat)).toList(),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Titre de la section active
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedCategory == 'Recommandés'
                                ? 'Recommandé pour vous'
                                : _selectedCategory == 'Tous'
                                    ? 'Tous les produits'
                                    : _selectedCategory,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveUtils.getTitleFontSize(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveUtils.getSpacing(context) * 2.0),
                      
                      // Product Grid
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
                            return Container(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Erreur lors du chargement des produits',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
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
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucun produit disponible',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Filtrer les produits - Afficher TOUS les produits (disponibles ou non)
                          // Si catégorie "Nouveautés" sélectionnée, afficher uniquement les recommandés
                          // Sinon, afficher tous les produits de la catégorie sélectionnée
                          List<Product> filteredProducts = snapshot.data!; // Afficher tous les produits
                          
                          // Filtrer selon le filtre actif (un seul filtre actif pour éviter les doublons)
                          if (_selectedCategory == 'Tous') {
                            // pas de filtre
                          } else if (_selectedCategory == 'Recommandés') {
                            filteredProducts = filteredProducts.where((product) => product.isRecommended).toList();
                          } else if (_selectedCategory == 'Nouveautés') {
                            filteredProducts = filteredProducts.where((product) => product.isNew).toList();
                          } else if (_selectedCategory == 'Promotions / Meilleures ventes') {
                            filteredProducts = filteredProducts.where((product) => product.isPromotion).toList();
                          } else {
                            filteredProducts = filteredProducts.where((product) => product.category == _selectedCategory).toList();
                          }
                          
                          // Filtrer par recherche si applicable
                          if (_searchController.text.isNotEmpty) {
                            final q = _searchController.text.trim().toLowerCase();
                            filteredProducts = filteredProducts.where((product) {
                              return product.name.toLowerCase().startsWith(q);
                            }).toList();
                          }

                          if (filteredProducts.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 48,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                  (_selectedCategory == 'Recommandés'
                                      ? 'Aucun produit recommandé'
                                      : _selectedCategory == 'Nouveautés'
                                          ? 'Aucun produit en nouveauté'
                                          : _selectedCategory == 'Promotions / Meilleures ventes'
                                              ? 'Aucun produit en promotion'
                                              : 'Aucun produit dans cette catégorie'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Grid like the provided screenshot (no + button)
                          final crossAxisCount = ResponsiveUtils.isMobile(context) ? 2 : 4;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 18,
                              childAspectRatio: 0.70,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              return _buildProductTile(filteredProducts[index]);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildNavigationDrawer(BuildContext context) {
    final textStyle = TextStyle(
      color: const Color(0xFF0C4B2E),
      fontWeight: FontWeight.w600,
      fontSize: ResponsiveUtils.getBodyFontSize(context),
    );

    return Drawer(
      backgroundColor: const Color(0xFFE8DDB5),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: _buildDrawerLogo(),
              ),
            ),
            const Divider(thickness: 1, height: 1, color: Color(0xFFD4C896)),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF0C4B2E)),
              title: Text('Mon profil', style: textStyle),
              onTap: () {
                Navigator.of(context).pop();
                AppRoutes.navigateToProfile(context);
              },
            ),
            const Divider(thickness: 1, height: 1, color: Color(0xFFD4C896)),
            ListTile(
              leading: const Icon(Icons.favorite, color: Color(0xFF0C4B2E)),
              title: Text('Mes favoris', style: textStyle),
              onTap: () {
                Navigator.of(context).pop();
                AppRoutes.navigateToFavorites(context);
              },
            ),
            const Divider(thickness: 1, height: 1, color: Color(0xFFD4C896)),
            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFF0C4B2E)),
              title: Text('Historique des commandes', style: textStyle),
              onTap: () {
                Navigator.of(context).pop();
                AppRoutes.navigateToOrderHistory(context);
              },
            ),
            const Divider(thickness: 1, height: 1, color: Color(0xFFD4C896)),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF0C4B2E)),
              title: Text('Déconnexion', style: textStyle),
              onTap: () {
                Navigator.of(context).pop(); // Fermer le drawer
                _signOut();
              },
            ),
            const Spacer(),
            const Divider(thickness: 1, height: 1, color: Color(0xFFD4C896)),
            _buildSocialListTile(
              context,
              label: 'WhatsApp',
              imagePath: 'IM/WhatsApp-icone.png',
              url: _whatsappUrl,
              textStyle: textStyle,
            ),
            _buildSocialListTile(
              context,
              label: 'Facebook',
              imagePath: 'IM/facebook-icon-ios-facebook-social-media-logo-on-white-background-free-free-vector.jpg',
              url: _facebookUrl,
              textStyle: textStyle,
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Besoin d\'aide ?',
                    style: textStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Service client: +227 89 83 18 40',
                    style: TextStyle(
                      color: const Color(0xFF4A6456),
                      fontSize: ResponsiveUtils.getSmallFontSize(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialListTile(
    BuildContext context, {
    required String label,
    required String imagePath,
    required String url,
    required TextStyle textStyle,
  }) {
    return ListTile(
      leading: ClipOval(
        child: Image.asset(
          imagePath,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF4A6456),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.share, color: Colors.white),
            );
          },
        ),
      ),
      title: Text(label, style: textStyle),
      onTap: () async {
        Navigator.of(context).pop();
        await _launchUrl(url);
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = kIsWeb
          ? await launchUrl(
              uri,
              webOnlyWindowName: '_blank',
            )
          : await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
      if (!launched) {
        throw Exception('launch failed');
      }
    } catch (_) {
      Fluttertoast.showToast(
        msg: "Impossible d'ouvrir le lien",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
  
  // (ancien bouton non utilisé supprimé)
  
  Widget _buildCategoryChip(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4A855) : const Color(0xFFE8DDB5),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFD4C896), width: 2),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : const Color(0xFF4A6456),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
 

  // Logo avec cercle pour le drawer
  Widget _buildDrawerLogo() {
    const double logoSize = 80.0;
    const double circleSize = logoSize * 1.2;
    
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF26D366),
            Color(0xFF1FB952),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          'IM/cercle.png',
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Text(
              'g',
              style: TextStyle(
                color: Colors.white,
                fontSize: logoSize * 0.6,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
              ),
            );
          },
        ),
      ),
    );
  }

  // Grid tile without cart controls; tap navigates to detail page
  Widget _buildProductTile(Product product) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppRoutes.navigateToProductDetail(context, product);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD4C896), width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image (top), keeping aspect similar to screenshot
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                      child: Container(
                        width: double.infinity,
                        color: Colors.white,
                        child: product.imageUrl.isNotEmpty
                            ? Image.network(
                                optimizeCloudinaryUrl(product.imageUrl),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.grey[400],
                                      size: 40,
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Icon(
                                  Icons.image,
                                  color: Colors.grey[400],
                                  size: 40,
                                ),
                              ),
                      ),
                    ),
                    // Bouton favori
                    Positioned(
                      top: 8,
                      right: 8,
                      child: FutureBuilder<bool>(
                        future: _favoritesService.isFavorite(product.id),
                        builder: (context, snapshot) {
                          final isFav = snapshot.data ?? false;
                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.white,
                              size: 20,
                            ),
                            onPressed: () async {
                              try {
                                await _favoritesService.toggleFavorite(product.id);
                                setState(() {}); // Rafraîchir pour mettre à jour l'icône
                              } catch (e) {
                                Fluttertoast.showToast(
                                  msg: 'Erreur lors de la modification',
                                  gravity: ToastGravity.BOTTOM,
                                );
                              }
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.5),
                              padding: const EdgeInsets.all(6),
                              minimumSize: const Size(32, 32),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: ResponsiveUtils.getSmallFontSize(context) + 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${product.price.toStringAsFixed(0)} FCFA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: ResponsiveUtils.getBodyFontSize(context) - 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
