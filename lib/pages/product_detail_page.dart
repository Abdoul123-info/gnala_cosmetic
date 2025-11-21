import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/product.dart';
import '../utils/image_url.dart';
import '../providers/cart_provider.dart';
import '../services/favorites_service.dart';
import '../routes.dart';
import '../utils/responsive.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final FavoritesService _favoritesService = FavoritesService();

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isMobile = ResponsiveUtils.isMobile(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    // Choisir une largeur max adaptée à l'écran (sans upscaling grâce à c_limit)
    final int targetWidth = isMobile ? 600 : (isTablet ? 900 : 1200);

    return Scaffold(
      backgroundColor: const Color(0xFF4A6456),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A6456),
        foregroundColor: const Color(0xFFD4C896),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4C896)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Bouton favori
          FutureBuilder<bool>(
            future: _favoritesService.isFavorite(product.id),
            builder: (context, snapshot) {
              final isFav = snapshot.data ?? false;
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : const Color(0xFFD4C896),
                ),
                onPressed: () async {
                  try {
                    await _favoritesService.toggleFavorite(product.id);
                    setState(() {}); // Rafraîchir pour mettre à jour l'icône
                    Fluttertoast.showToast(
                      msg: isFav
                          ? 'Retiré des favoris'
                          : 'Ajouté aux favoris',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: const Color(0xFF22C55E),
                      textColor: Colors.white,
                    );
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: 'Erreur lors de la modification',
                      gravity: ToastGravity.BOTTOM,
                    );
                  }
                },
              );
            },
          ),
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Color(0xFFD4C896)),
                    onPressed: () {
                      AppRoutes.navigateToCart(context);
                    },
                  ),
                  if (cart.totalItems > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
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
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
              padding: ResponsiveUtils.getPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image du produit
              Center(
                child: Container(
                  width: double.infinity,
                  height: isMobile ? 250 : isTablet ? 350 : 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD4C896), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(
                            optimizeCloudinaryUrlWithWidth(product.imageUrl, width: targetWidth),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Nom et catégorie
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveUtils.getTitleFontSize(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4A855),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            product.category,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Statut de disponibilité
              Row(
                children: [
                  Icon(
                    product.isAvailable ? Icons.check_circle : Icons.cancel,
                    color: product.isAvailable ? const Color(0xFFD4C896) : Colors.red[300],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    product.isAvailable ? 'Disponible' : 'Non disponible',
                    style: TextStyle(
                      color: product.isAvailable ? const Color(0xFFD4C896) : Colors.red[300],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Prix
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8DDB5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4C896), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Prix:',
                      style: TextStyle(
                        color: Color(0xFF4A6456),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${product.price.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        color: Color(0xFF4A6456),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8DDB5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4C896), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        color: Color(0xFF4A6456),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.description,
                      style: const TextStyle(
                        color: Color(0xFF4A6456),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Bouton d'ajout au panier / Contrôles de quantité
              Consumer<CartProvider>(
                builder: (context, cart, child) {
                  final isInCart = cart.isProductInCart(product.id);
                  final quantity = cart.getProductQuantity(product.id);

                  if (!product.isAvailable) {
                    // Produit non disponible
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Center(
                        child: Text(
                          'Produit non disponible',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }

                  if (isInCart) {
                    // Contrôles de quantité
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8DDB5),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: const Color(0xFFD4C896), width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => cart.decrementQuantity(product),
                            icon: Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD4A855),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.remove, color: Colors.black),
                            ),
                          ),
                          Text(
                            '$quantity',
                            style: const TextStyle(
                              color: Color(0xFF4A6456),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => cart.incrementQuantity(product),
                            icon: Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD4A855),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Bouton d'ajout au panier
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: ElevatedButton(
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
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Ajouter au panier',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

