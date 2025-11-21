import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/favorites_service.dart';
import '../providers/cart_provider.dart';
import '../routes.dart';
import '../utils/responsive.dart';
import '../utils/image_url.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesService _favoritesService = FavoritesService();

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFF4A6456),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4B2E),
        title: const Text(
          'Mes favoris',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Product>>(
          stream: _favoritesService.getFavoriteProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4C896)),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.white.withOpacity(0.8),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur lors du chargement des favoris',
                      style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              );
            }

            final favorites = snapshot.data ?? [];

            if (favorites.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun produit favori',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ajoutez des produits à vos favoris pour les retrouver facilement',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Padding(
              padding: ResponsiveUtils.getPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${favorites.length} produit${favorites.length > 1 ? "s" : ""} favori${favorites.length > 1 ? "s" : ""}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.getBodyFontSize(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 2 : (isTablet ? 3 : 4),
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final product = favorites[index];
                        return _buildProductCard(product);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final int targetWidth = isMobile ? 400 : 600;

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
              // Image du produit avec bouton favori
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
                                optimizeCloudinaryUrlWithWidth(
                                  product.imageUrl,
                                  width: targetWidth,
                                ),
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
                          final isFav = snapshot.data ?? true;
                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.white,
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
                              backgroundColor: Colors.white.withOpacity(0.9),
                              padding: const EdgeInsets.all(8),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Informations du produit
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.price.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        color: Color(0xFFD4C896),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Bouton ajouter au panier
                    Consumer<CartProvider>(
                      builder: (context, cart, child) {
                        final isInCart = cart.isProductInCart(product.id);
                        if (!product.isAvailable) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Indisponible',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }
                        if (isInCart) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4A855),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Dans le panier',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }
                        return ElevatedButton(
                          onPressed: () {
                            cart.addItem(product);
                            Fluttertoast.showToast(
                              msg: "${product.name} ajouté au panier",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: const Color(0xFF22C55E),
                              textColor: Colors.white,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4A855),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            minimumSize: const Size(double.infinity, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Ajouter',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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

