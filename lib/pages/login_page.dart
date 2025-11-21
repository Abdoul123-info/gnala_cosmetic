import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../routes.dart';
import '../utils/responsive.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Convertir le numéro de téléphone en format email interne
      // ou utiliser directement si c'est déjà un email (pour admin)
      String phoneInput = _phoneController.text.trim();
      String email;
      
      // Si c'est déjà un email (contient @), l'utiliser tel quel
      if (phoneInput.contains('@')) {
        email = phoneInput.trim().toLowerCase();
      } else {
        // Extraire uniquement les chiffres du numéro
        final digits = phoneInput.replaceAll(RegExp(r'[^\d]'), '');
        if (digits.isEmpty) {
          throw FirebaseAuthException(
            code: 'invalid-email',
            message: 'Numéro de téléphone invalide',
          );
        }

        // Récupérer l'UID associé à ce numéro via la collection dédiée
        final phoneDoc = await FirebaseFirestore.instance
            .collection('phone_numbers')
            .doc(digits)
            .get();

        if (!phoneDoc.exists) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'Aucun utilisateur trouvé avec ce numéro',
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
              message: 'Utilisateur introuvable pour ce numéro',
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

      // Essayer de se connecter avec email et mot de passe
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );

      // Récupérer le document utilisateur dans Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        String role = userDoc.get('role') ?? 'user';
        
        if (mounted) {
          AppRoutes.navigateBasedOnRole(context, role);
        }
      } else {
        // Si l'utilisateur n'existe pas dans Firestore, le créer avec role "user"
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'phone': phoneInput.contains('@') ? '' : phoneInput,
          'email': email,
          'role': email == 'admin@gnala.com' ? 'admin' : 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          AppRoutes.navigateToHome(context);
        }
      }

      Fluttertoast.showToast(
        msg: "Connexion réussie !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      await _syncPhoneNumberIndex(userCredential.user!.uid, email);
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Erreur de connexion";
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "Aucun utilisateur trouvé avec ce numéro";
          break;
        case 'wrong-password':
          errorMessage = "Mot de passe incorrect";
          break;
        case 'invalid-email':
          errorMessage = "Format de numéro invalide";
          break;
        case 'user-disabled':
          errorMessage = "Ce compte a été désactivé";
          break;
        case 'too-many-requests':
          errorMessage = "Trop de tentatives. Réessayez plus tard";
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
    final isMobile = ResponsiveUtils.isMobile(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    final screenWidth = ResponsiveUtils.screenWidth(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final availableHeight = screenHeight - safeAreaTop - safeAreaBottom;
    
    // Calculer les espacements dynamiques selon la hauteur disponible
    final double headerSpacing = availableHeight < 700 ? 8 : (availableHeight < 800 ? 12 : 15);
    final double logoSpacing = availableHeight < 700 ? 12 : (availableHeight < 800 ? 20 : 25);
    final double formSpacing = availableHeight < 700 ? 8 : (availableHeight < 800 ? 12 : 15);
    final double buttonSpacing = availableHeight < 700 ? 8 : (availableHeight < 800 ? 10 : 14);
    final double bottomSpacing = availableHeight < 700 ? 8 : (availableHeight < 800 ? 12 : 16);
    
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
            
            // Contenu principal - sans SingleChildScrollView pour éviter le défilement
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: ResponsiveUtils.getHorizontalPadding(context),
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          SizedBox(height: headerSpacing),
                          
                          // Header avec Aide et Service client
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 12 : 16,
                                  vertical: isMobile ? 6 : 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Aide ?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 11 : 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 12 : 14,
                                  vertical: isMobile ? 6 : 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF22C55E).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      color: Colors.white,
                                      size: isMobile ? 12 : 14,
                                    ),
                                    SizedBox(width: isMobile ? 4 : 6),
                                    Text(
                                      'Service client',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isMobile ? 10 : 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: logoSpacing),
                          
                          // Logo concentrique avec points décoratifs + texte collé
                          Flexible(
                            flex: availableHeight < 700 ? 2 : 3,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: _buildConcentricLogo(availableHeight),
                                ),
                                // Nom de la marque avec image ecriture.png (collé au cercle, pas d'espace)
                                Flexible(
                                  child: Image.asset(
                                    'IM/ecriture.png',
                                    width: availableHeight < 700 
                                        ? (isMobile ? screenWidth * 0.4 : isTablet ? 180 : 200)
                                        : (isMobile ? screenWidth * 0.45 : isTablet ? 200 : 220),
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'gnala',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: availableHeight < 700
                                                  ? (isMobile ? 28 : isTablet ? 36 : 40)
                                                  : (isMobile ? 32 : isTablet ? 40 : 44),
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.w300,
                                              height: 1.0,
                                            ),
                                          ),
                                          Text(
                                            'cosmetic',
                                            style: TextStyle(
                                              color: const Color(0xFF22C55E),
                                              fontSize: availableHeight < 700
                                                  ? (isMobile ? 14 : isTablet ? 18 : 20)
                                                  : (isMobile ? 16 : isTablet ? 20 : 22),
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: formSpacing),
                          
                          // Formulaire de connexion (collé au texte, pas d'espace)
                          Flexible(
                            flex: availableHeight < 700 ? 3 : 4,
                            child: Transform.translate(
                              offset: const Offset(0, -5),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 16 : 20,
                                  vertical: isMobile ? 16 : 20,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD8E8DF),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Champ téléphone (fond vert brillant complet comme dans l'image)
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
                                              keyboardType: TextInputType.text,
                                              textInputAction: TextInputAction.next,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                              decoration: InputDecoration(
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
                                                if (value.length < 8 && !value.contains('@')) {
                                                  return 'Le numéro doit contenir au moins 8 caractères';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    SizedBox(height: availableHeight < 700 ? 10 : 14),
                                    
                                    // Champ mot de passe (fond vert brillant complet comme dans l'image)
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
                                          const Padding(
                                            padding: EdgeInsets.only(left: 18),
                                            child: Icon(Icons.lock_rounded, color: Colors.white, size: 18),
                                          ),
                                          Expanded(
                                            child: TextFormField(
                                              controller: _passwordController,
                                              obscureText: _obscurePassword,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              decoration: InputDecoration(
                                                hintText: 'Mot de passe',
                                                hintStyle: TextStyle(
                                                  color: Colors.white.withOpacity(0.7),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                filled: true,
                                                fillColor: Colors.transparent,
                                                border: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Veuillez entrer votre mot de passe';
                                                }
                                                if (value.length < 6) {
                                                  return 'Le mot de passe doit contenir au moins 6 caractères';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword = !_obscurePassword;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    SizedBox(height: availableHeight < 700 ? 6 : 10),
                                    
                                    // Mot de passe oublié
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          AppRoutes.navigateToForgotPassword(context);
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        ),
                                        child: const Text(
                                          'Mot de passe oublié ?',
                                          style: TextStyle(
                                            color: Color(0xFF0C4B2E),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: buttonSpacing),
                          
                          // Bouton Se connecter
                          Container(
                            width: double.infinity,
                            height: availableHeight < 700 ? 48 : 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signIn,
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
                                      'Se connecter',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: availableHeight < 700 ? 16 : 18,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                          
                          SizedBox(height: buttonSpacing),
                          
                          // Bouton S'inscrire
                          SizedBox(
                            width: double.infinity,
                            height: availableHeight < 700 ? 48 : 54,
                            child: OutlinedButton(
                              onPressed: () {
                                AppRoutes.navigateToSignup(context);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(27),
                                ),
                              ),
                              child: Text(
                                "S'inscrire",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: availableHeight < 700 ? 16 : 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: bottomSpacing),
                        ],
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

  Widget _buildConcentricLogo(double availableHeight) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    final screenWidth = ResponsiveUtils.screenWidth(context);
    
    // Taille de base responsive, bornée pour petits écrans
    // Réduire encore plus sur les petits écrans
    double baseSize = availableHeight < 700
        ? (isMobile ? screenWidth * 0.2 : isTablet ? 90 : 110)
        : (isMobile ? screenWidth * 0.25 : isTablet ? 120 : 142);
    // Evite des tailles trop grandes ou trop petites
    final double maxBaseCandidate = screenWidth * 0.3;
    final double maxBase = maxBaseCandidate < 90.0
        ? 90.0
        : (maxBaseCandidate > 180.0 ? 180.0 : maxBaseCandidate);
    // Ajuster selon la hauteur disponible
    final double minBase = availableHeight < 700 ? 60.0 : 72.0;
    baseSize = baseSize.clamp(minBase, maxBase).toDouble();
    // Taille totale maximale des cercles (le plus grand = baseSize * 3.0)
    final double outerSize = baseSize * 3.0;
    
    // Prépare les couches: anneaux + cercle central avec logo
    final List<Widget> layers = [];
    // Cercles concentriques (responsive)
    for (int i = 5; i >= 1; i--) {
      layers.add(
        Container(
          width: baseSize * (1 + (i * 0.4)),
          height: baseSize * (1 + (i * 0.4)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == 5
                ? const Color(0xFF2C4A3E).withOpacity(0.3)
                : Colors.white.withOpacity(0.04 + (i * 0.04)),
            border: Border.all(
              color: Colors.white.withOpacity(0.12 + (i * 0.02)),
              width: 1.5,
            ),
          ),
        ),
      );
    }
    // Cercle central avec logo (responsive)
    layers.add(
      Container(
          width: baseSize * 1.7,
          height: baseSize * 1.7,
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
                color: const Color(0xFF22C55E).withOpacity(0.5),
                blurRadius: 25,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Point décoratif en haut (proportionnellement ajusté)
              Positioned(
                top: baseSize * 0.15,
                left: baseSize * 0.35,
                child: Container(
                  width: baseSize * 0.08,
                  height: baseSize * 0.08,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white54,
                        blurRadius: baseSize * 0.035,
                        spreadRadius: baseSize * 0.01,
                      ),
                    ],
                  ),
                ),
              ),
              // Grille de points en haut à droite (proportionnellement ajustée)
              Positioned(
                top: baseSize * 0.12,
                right: baseSize * 0.1,
                child: Transform.scale(
                  scale: (baseSize / 120).clamp(0.7, 1.4),
                  child: const _DotGrid(),
                ),
              ),
              // Logo cercle.png au centre (agrandi puis réduit de 3 fois)
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    // Le logo reste bien à l'intérieur du cercle central
                    maxWidth: baseSize * 1.2,
                    maxHeight: baseSize * 1.2,
                  ),
                  child: Image.asset(
                    'IM/cercle.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        'g',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: baseSize * 0.6,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                          height: 1.0,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
      ),
    );

    return SizedBox(
      width: outerSize,
      height: outerSize,
      child: Stack(
        alignment: Alignment.center,
        children: layers,
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

  Future<void> _syncPhoneNumberIndex(String uid, String email) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userSnapshot.exists) return;

      final data = userSnapshot.data();
      final phoneDigits = (data?['phoneDigits'] ?? '').toString().trim();
      if (phoneDigits.isEmpty) return;

      final phoneRef = FirebaseFirestore.instance
          .collection('phone_numbers')
          .doc(phoneDigits);

      await phoneRef.set({
        'uid': uid,
        'phoneDigits': phoneDigits,
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Ne pas bloquer la connexion en cas d'erreur de synchronisation
      print('Erreur sync phone_numbers: $e');
    }
  }
}

// Widget séparé pour la grille de points
class _DotGrid extends StatelessWidget {
  const _DotGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              children: [
                for (int j = 0; j < 5; j++)
                  Container(
                    width: 2.5,
                    height: 2.5,
                    margin: EdgeInsets.only(right: j < 4 ? 3 : 0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
