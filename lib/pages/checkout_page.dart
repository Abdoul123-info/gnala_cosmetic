import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../routes.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import '../utils/responsive.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _zoneController = TextEditingController();
  final _orderService = OrderService();
  
  String? _userName;
  String? _userPhone;
  String _deliveryType = 'simple'; // 'simple' ou 'express'
  bool _isLoading = false;
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _zoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userName = userDoc.get('name') ?? 'Utilisateur';
            _userPhone = userDoc.get('phone') ?? userDoc.get('email') ?? '';
            _isLoadingUserData = false;
          });
        } else {
          setState(() {
            _userName = 'Utilisateur';
            _userPhone = user.email ?? '';
            _isLoadingUserData = false;
          });
        }
      } else {
        setState(() {
          _isLoadingUserData = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingUserData = false;
      });
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Erreur lors du chargement des données utilisateur",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }

  Future<void> _submitOrder(BuildContext context, CartProvider cart) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _orderService.submitOrder(
        cart: cart,
        address: _addressController.text.trim(),
        zone: _zoneController.text.trim(),
        deliveryType: _deliveryType,
      );

      if (success && mounted) {
        Fluttertoast.showToast(
          msg: "Commande envoyée avec succès ! Vous serez contacté pour la livraison.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFF22C55E),
          textColor: Colors.white,
        );

        // Vider le panier après confirmation
        cart.clearCart();

        // Retourner à la page d'accueil
        AppRoutes.navigateToHome(context);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Erreur lors de l'envoi de la commande: ${e.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    if (_isLoadingUserData) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: const Color(0xFF0C4B2E),
          foregroundColor: Colors.white,
          title: const Text('Confirmer la commande'),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0C4B2E)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4B2E),
        foregroundColor: Colors.white,
        title: const Text('Confirmer la commande'),
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Résumé de la commande
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8E8DF),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Résumé de la commande',
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0C4B2E),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Informations utilisateur (en lecture seule)
                        if (_userName != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nom:',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                _userName!,
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0C4B2E),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (_userPhone != null && _userPhone!.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Téléphone:',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                _userPhone!,
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0C4B2E),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Articles:',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '${cart.totalItems}',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0C4B2E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '${cart.totalPrice.toStringAsFixed(0)} FCFA',
                              style: TextStyle(
                                fontSize: isMobile ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF22C55E),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Informations de livraison
                  Text(
                    'Informations de livraison',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Champ Adresse / Quartier
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8E8DF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _addressController,
                      style: const TextStyle(
                        color: Color(0xFF0C4B2E),
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Adresse / Quartier',
                        labelStyle: const TextStyle(
                          color: Color(0xFF0C4B2E),
                        ),
                        hintText: 'Entrez votre adresse ou quartier',
                        hintStyle: TextStyle(
                          color: const Color(0xFF0C4B2E).withOpacity(0.6),
                        ),
                        prefixIcon: const Icon(Icons.location_on, color: Color(0xFF0C4B2E)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre adresse ou quartier';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Champ Zone / Secteur
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8E8DF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _zoneController,
                      style: const TextStyle(
                        color: Color(0xFF0C4B2E),
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Zone / Secteur',
                        labelStyle: const TextStyle(
                          color: Color(0xFF0C4B2E),
                        ),
                        hintText: 'Entrez votre zone ou secteur',
                        hintStyle: TextStyle(
                          color: const Color(0xFF0C4B2E).withOpacity(0.6),
                        ),
                        prefixIcon: const Icon(Icons.map, color: Color(0xFF0C4B2E)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre zone ou secteur';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Bouton de confirmation
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _submitOrder(context, cart),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C4B2E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Confirmer la commande',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
