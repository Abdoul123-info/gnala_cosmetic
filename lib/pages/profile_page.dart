import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/order_service.dart';
import '../utils/responsive.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OrderService _orderService = OrderService();
  
  String? _userEmail;
  int _totalOrders = 0;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadOrderStats();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      setState(() {
        _userEmail = user.email;
      });

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc.get('name') ?? '';
          _phoneController.text = userDoc.get('phone') ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _nameController.text = '';
          _phoneController.text = '';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Erreur lors du chargement des données",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }

  Future<void> _loadOrderStats() async {
    try {
      final orders = await _orderService.fetchOrderHistory();
      setState(() {
        _totalOrders = orders.length;
      });
    } catch (e) {
      // Ignorer les erreurs pour les stats
      print('Erreur chargement stats: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      if (mounted) {
        Fluttertoast.showToast(
          msg: "Profil mis à jour avec succès",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFF0C4B2E),
          textColor: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Erreur lors de la sauvegarde",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  void _cancelEdit() {
    _loadUserData(); // Recharger les données originales
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFF4A6456),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4B2E),
        title: const Text(
          'Mon profil',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              tooltip: 'Modifier',
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4C896)),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carte de profil
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C4B2E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFD4C896),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Avatar
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFD4C896),
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF0C4B2E),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Nom
                          if (_isEditing)
                            TextFormField(
                              controller: _nameController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Votre nom',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD4C896),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD4C896),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD4C896),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Veuillez entrer votre nom';
                                }
                                return null;
                              },
                            )
                          else
                            Text(
                              _nameController.text.isEmpty
                                  ? 'Utilisateur'
                                  : _nameController.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(height: 8),
                          // Email (non éditable)
                          Text(
                            _userEmail ?? 'Email non disponible',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Informations personnelles
                    Text(
                      'Informations personnelles',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Téléphone
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C4B2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFD4C896),
                          width: 1,
                        ),
                      ),
                      child: _isEditing
                          ? TextFormField(
                              controller: _phoneController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Téléphone',
                                labelStyle: const TextStyle(
                                  color: Color(0xFFD4C896),
                                ),
                                hintText: 'Entrez votre numéro',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: Color(0xFFD4C896),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Veuillez entrer votre téléphone';
                                }
                                return null;
                              },
                            )
                          : ListTile(
                              leading: const Icon(
                                Icons.phone,
                                color: Color(0xFFD4C896),
                              ),
                              title: const Text(
                                'Téléphone',
                                style: TextStyle(
                                  color: Color(0xFFD4C896),
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                _phoneController.text.isEmpty
                                    ? 'Non renseigné'
                                    : _phoneController.text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 24),

                    // Statistiques
                    Text(
                      'Statistiques',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C4B2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFD4C896),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.shopping_bag,
                          color: Color(0xFFD4C896),
                        ),
                        title: const Text(
                          'Commandes totales',
                          style: TextStyle(
                            color: Color(0xFFD4C896),
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '$_totalOrders commande${_totalOrders > 1 ? "s" : ""}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Boutons d'action
                    if (_isEditing) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(27),
                            ),
                            elevation: 8,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Enregistrer',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: _cancelEdit,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Color(0xFFD4C896),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(27),
                            ),
                          ),
                          child: const Text(
                            'Annuler',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}







