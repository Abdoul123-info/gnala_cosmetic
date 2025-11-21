import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../routes.dart';
import '../utils/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Convertir le numéro de téléphone ou utiliser directement l'email
      String input = _phoneController.text.trim();
      String email;

      if (input.contains('@')) {
        email = input.toLowerCase();
      } else {
        final digits = input.replaceAll(RegExp(r'[^\d]'), '');
        if (digits.isEmpty) {
          throw FirebaseAuthException(
            code: 'invalid-email',
            message: 'Numéro de téléphone invalide',
          );
        }

        // Rechercher l'UID associé à ce numéro dans la collection phone_numbers
        final phoneDoc = await FirebaseFirestore.instance
            .collection('phone_numbers')
            .doc(digits)
            .get();

        if (!phoneDoc.exists) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'Aucun compte trouvé avec ce numéro',
          );
        }

        final phoneData = phoneDoc.data();
        String storedEmail = (phoneData?['email'] ?? '').toString().trim();
        if (storedEmail.isEmpty) {
          final uid = (phoneData?['uid'] ?? '').toString().trim();
          if (uid.isEmpty) {
            throw FirebaseAuthException(
              code: 'invalid-email',
              message:
                  'Adresse email introuvable pour ce numéro. Veuillez utiliser votre email.',
            );
          }

          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();

          if (!userDoc.exists) {
            throw FirebaseAuthException(
              code: 'user-not-found',
              message: 'Utilisateur introuvable',
            );
          }

          final userData = userDoc.data();
          storedEmail = (userData?['email'] ?? '').toString().trim();
          if (storedEmail.isEmpty) {
            storedEmail = (userData?['createdEmail'] ?? '').toString().trim();
          }

          if (storedEmail.isNotEmpty) {
            await FirebaseFirestore.instance
                .collection('phone_numbers')
                .doc(digits)
                .set({
              'uid': uid,
              'phoneDigits': digits,
              'email': storedEmail,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        }

        if (storedEmail.isEmpty) {
          throw FirebaseAuthException(
            code: 'invalid-email',
            message:
                'Adresse email introuvable pour ce numéro. Veuillez utiliser votre email.',
          );
        }

        email = storedEmail.toLowerCase();
      }

      // Envoyer l'email de réinitialisation
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (mounted) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });

        Fluttertoast.showToast(
          msg: "Email de réinitialisation envoyé !",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFF22C55E),
          textColor: Colors.white,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Erreur lors de l'envoi de l'email";
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "Aucun compte trouvé avec ce numéro/email";
          break;
        case 'invalid-email':
          errorMessage = e.message ?? "Format de numéro/email invalide";
          break;
        case 'too-many-requests':
          errorMessage = "Trop de tentatives. Réessayez plus tard";
          break;
        default:
          errorMessage = "Erreur: ${e.message}";
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Fluttertoast.showToast(
          msg: "Erreur inattendue: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

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
        child: Stack(
          children: [
            // Points décoratifs en arrière-plan
            ..._buildBackgroundDots(),
            
            // Contenu principal
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: ResponsiveUtils.getHorizontalPadding(context),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Bouton retour
                              Align(
                                alignment: Alignment.topLeft,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => AppRoutes.goBack(context),
                                ),
                              ),

                              const Spacer(flex: 1),

                              // Icône de cadenas
                              Container(
                                width: isMobile ? 80 : 100,
                                height: isMobile ? 80 : 100,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lock_reset,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),

                              SizedBox(height: isMobile ? 24 : 32),

                              // Titre
                              Text(
                                'Mot de passe oublié ?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMobile ? 24 : 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: isMobile ? 12 : 16),

                              // Description
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 24 : 32,
                                ),
                                child: Text(
                                  _emailSent
                                      ? 'Un email de réinitialisation a été envoyé à votre adresse. Vérifiez votre boîte de réception et suivez les instructions.'
                                      : 'Entrez votre numéro de téléphone ou votre email pour recevoir un lien de réinitialisation de mot de passe.',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: isMobile ? 14 : 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              SizedBox(height: isMobile ? 32 : 40),

                              // Formulaire (seulement si l'email n'a pas été envoyé)
                              if (!_emailSent) ...[
                                // Champ téléphone/email
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E),
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF22C55E).withOpacity(0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                          left: isMobile ? 12 : 16,
                                          right: isMobile ? 6 : 8,
                                          top: isMobile ? 12 : 15,
                                          bottom: isMobile ? 12 : 15,
                                        ),
                                        child: Row(
                                          children: [
                                            ClipOval(
                                              child: Image.asset(
                                                'IM/Niger.jpg',
                                                width: isMobile ? 18 : 22,
                                                height: isMobile ? 18 : 22,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    width: isMobile ? 18 : 22,
                                                    height: isMobile ? 18 : 22,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.white54,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Text(
                                              '+227',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: '89831840 ou email@example.com',
                                            hintStyle: TextStyle(
                                              color: Colors.white.withOpacity(0.7),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            filled: true,
                                            fillColor: Colors.transparent,
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Veuillez entrer votre numéro ou email';
                                            }
                                            if (!value.contains('@') && value.length < 8) {
                                              return 'Le numéro doit contenir au moins 8 caractères';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: isMobile ? 24 : 32),

                                // Bouton Envoyer
                                SizedBox(
                                  width: double.infinity,
                                  height: isMobile ? 48 : 54,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _sendPasswordResetEmail,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0C4B2E),
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
                                        : Text(
                                            'Envoyer le lien',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isMobile ? 16 : 18,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),
                              ] else ...[
                                // Message de confirmation
                                Container(
                                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF22C55E),
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF22C55E),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Text(
                                          'Email envoyé avec succès !',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isMobile ? 14 : 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: isMobile ? 24 : 32),

                                // Bouton Retour à la connexion
                                SizedBox(
                                  width: double.infinity,
                                  height: isMobile ? 48 : 54,
                                  child: OutlinedButton(
                                    onPressed: () => AppRoutes.goBack(context),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(color: Colors.white, width: 2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(27),
                                      ),
                                    ),
                                    child: Text(
                                      'Retour à la connexion',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isMobile ? 16 : 18,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              const Spacer(flex: 2),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundDots() {
    List<Widget> dots = [];
    
    // Points sur le côté droit
    for (int i = 0; i < 12; i++) {
      dots.add(
        Positioned(
          right: 15 + (i % 3) * 25,
          top: 40 + (i * 35.0),
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    
    // Points sur le côté gauche
    for (int i = 0; i < 10; i++) {
      dots.add(
        Positioned(
          left: 10 + (i % 2) * 20,
          top: 100 + (i * 40.0),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    
    return dots;
  }
}

