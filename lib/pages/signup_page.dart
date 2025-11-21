import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../routes.dart';
import '../utils/responsive.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Convertir le numéro de téléphone en format email interne
      String phoneInput = _phoneController.text.trim();
      final String emailInput = _emailController.text.trim().toLowerCase();
      String email;
      
      final digits = phoneInput.replaceAll(RegExp(r'[^\d]'), '');

      // Si l'utilisateur a saisi un email dans le champ téléphone (cas admin)
      if (phoneInput.contains('@')) {
        email = phoneInput;
      } else {
        // Extraire uniquement les chiffres du numéro
        if (digits.isEmpty) {
          throw Exception('Numéro de téléphone invalide');
        }
        // Utiliser l'email réel fourni pour l'inscription
        email = emailInput;

        // Vérifier que le numéro n'est pas déjà utilisé (collection séparée pour sécurité)
        final phoneDocRef = FirebaseFirestore.instance
            .collection('phone_numbers')
            .doc(digits);
        final phoneDoc = await phoneDocRef.get();
        if (phoneDoc.exists) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          Fluttertoast.showToast(
            msg: "Ce numéro est déjà utilisé",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          return;
        }
      }

      if (email.isEmpty) {
        Fluttertoast.showToast(
          msg: "Veuillez entrer une adresse email valide",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      // Créer le compte dans Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );

      // Enregistrer les informations utilisateur dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'name': _nameController.text.trim(),
        'phone': phoneInput.contains('@') ? '' : phoneInput,
        'phoneDigits': phoneInput.contains('@') ? '' : digits,
        'email': email,
        'createdEmail': email,
        'role': 'user', // Par défaut, tous les nouveaux utilisateurs sont "user"
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Enregistrer le numéro de téléphone dans la collection séparée (sécurité)
      // Seulement si ce n'est pas un email admin
      if (!phoneInput.contains('@') && digits.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('phone_numbers')
            .doc(digits)
            .set({
          'uid': userCredential.user!.uid,
          'phoneDigits': digits,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      Fluttertoast.showToast(
        msg: "Inscription réussie ! Vous êtes maintenant connecté.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      // Rediriger vers la page de connexion
      if (mounted) {
        AppRoutes.replaceWithLogin(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Erreur lors de l'inscription";
      
      switch (e.code) {
        case 'weak-password':
          errorMessage = "Le mot de passe est trop faible";
          break;
        case 'email-already-in-use':
          errorMessage = "Un compte existe déjà avec ce numéro";
          break;
        case 'invalid-email':
          errorMessage = "Format de numéro invalide";
          break;
        case 'operation-not-allowed':
          errorMessage = "L'inscription n'est pas autorisée";
          break;
        default:
          errorMessage = "Erreur: ${e.message}";
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur inattendue: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C4A3E),
              Color(0xFF486A5A),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getPadding(context),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  
                  // Logo cercle.png au lieu de l'icône +
                  Image.asset(
                    'IM/cercle.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.add,
                        size: 60,
                        color: Color(0xFF22C55E),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Créer un compte',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Remplissez les informations ci-dessous',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                // Champ nom
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8E8DF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    style: const TextStyle(
                      color: Color(0xFF0C4B2E),
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nom complet',
                      labelStyle: const TextStyle(
                        color: Color(0xFF0C4B2E),
                      ),
                      hintText: 'Entrez votre nom complet',
                      hintStyle: TextStyle(
                        color: const Color(0xFF0C4B2E).withOpacity(0.6),
                      ),
                      prefixIcon: const Icon(Icons.person, color: Color(0xFF0C4B2E)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre nom';
                      }
                      if (value.trim().length < 2) {
                        return 'Le nom doit contenir au moins 2 caractères';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Champ email réel
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8E8DF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      color: Color(0xFF0C4B2E),
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Adresse email',
                      labelStyle: const TextStyle(
                        color: Color(0xFF0C4B2E),
                      ),
                      hintText: 'email@example.com',
                      hintStyle: TextStyle(
                        color: const Color(0xFF0C4B2E).withOpacity(0.6),
                      ),
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF0C4B2E)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre adresse email';
                      }
                      final emailRegex =
                          RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Adresse email invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Champ numéro
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8E8DF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                      color: Color(0xFF0C4B2E),
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Numéro de téléphone',
                      labelStyle: const TextStyle(
                        color: Color(0xFF0C4B2E),
                      ),
                      hintText: 'Entrez votre numéro',
                      hintStyle: TextStyle(
                        color: const Color(0xFF0C4B2E).withOpacity(0.6),
                      ),
                      prefixIcon: const Icon(Icons.phone, color: Color(0xFF0C4B2E)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre numéro';
                      }
                      if (value.length < 8) {
                        return 'Le numéro doit contenir au moins 8 caractères';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Champ mot de passe
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8E8DF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(
                      color: Color(0xFF0C4B2E),
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      labelStyle: const TextStyle(
                        color: Color(0xFF0C4B2E),
                      ),
                      hintText: 'Entrez votre mot de passe',
                      hintStyle: TextStyle(
                        color: const Color(0xFF0C4B2E).withOpacity(0.6),
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF0C4B2E)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Champ confirmation mot de passe
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8E8DF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: const TextStyle(
                      color: Color(0xFF0C4B2E),
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      labelStyle: const TextStyle(
                        color: Color(0xFF0C4B2E),
                      ),
                      hintText: 'Confirmez votre mot de passe',
                      hintStyle: TextStyle(
                        color: const Color(0xFF0C4B2E).withOpacity(0.6),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF0C4B2E)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Bouton S'inscrire
                Container(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
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
                            'S\'inscrire',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Lien vers connexion
                TextButton(
                  onPressed: () {
                    AppRoutes.replaceWithLogin(context);
                  },
                  child: Text(
                    'Déjà un compte ? Se connecter',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
