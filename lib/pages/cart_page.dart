import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../routes.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../utils/responsive.dart';
import '../utils/image_url.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4B2E),
        foregroundColor: Colors.white,
        title: const Text('Mon Panier'),
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              // Liste des articles
              Expanded(
                child: ListView.builder(
                  padding: ResponsiveUtils.getPadding(context),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    CartItem item = cart.items[index];
                    return _buildCartItem(context, item);
                  },
                ),
              ),

              // Résumé et bouton de commande
              _buildCartSummary(context, cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Votre panier est vide',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez des produits pour commencer vos achats',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => AppRoutes.goBack(context),
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Voir les produits'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C4B2E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD8E8DF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
            child: item.product.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      optimizeCloudinaryUrl(item.product.imageUrl),
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
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.product.price.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF22C55E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: ${item.totalPrice.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0C4B2E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Contrôles de quantité
          Column(
            children: [
              // Boutons de quantité
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF0C4B2E).withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        context.read<CartProvider>().decrementQuantity(item.product);
                      },
                      icon: const Icon(Icons.remove, size: 18, color: Color(0xFF0C4B2E)),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0C4B2E),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.read<CartProvider>().incrementQuantity(item.product);
                      },
                      icon: const Icon(Icons.add, size: 18, color: Color(0xFF0C4B2E)),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Bouton supprimer
              IconButton(
                onPressed: () {
                  _showDeleteConfirmation(context, item);
                },
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                tooltip: 'Supprimer',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD8E8DF),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Résumé
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Articles (${cart.totalItems})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
                Text(
                  '${cart.totalPrice.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF22C55E),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<CartProvider>().clearCart();
                    Fluttertoast.showToast(
                      msg: "Panier vidé",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Vider le panier'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => AppRoutes.navigateToCheckout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C4B2E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Commander',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CartItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer du panier'),
          content: Text('Voulez-vous supprimer "${item.product.name}" du panier ?'),
          actions: [
            TextButton(
              onPressed: () => AppRoutes.goBack(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                context.read<CartProvider>().removeItem(item.product);
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                  msg: "${item.product.name} supprimé du panier",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.orange,
                  textColor: Colors.white,
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

}
