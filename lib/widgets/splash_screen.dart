import 'package:flutter/material.dart';
import '../utils/responsive.dart';

/// Écran de chargement élégant avec le logo concentrique et le texte gnala cosmetic
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    final screenWidth = ResponsiveUtils.screenWidth(context);

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
            
            // Contenu principal centré
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight = constraints.maxHeight;
                  // Ajuster les espacements selon la hauteur disponible
                  final logoSpacing = availableHeight < 700 ? 12.0 : 20.0;
                  final textSpacing = availableHeight < 700 ? 24.0 : 40.0;
                  
                  return Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo concentrique (ajusté selon la hauteur disponible)
                            _buildConcentricLogo(availableHeight, isMobile, isTablet, screenWidth),
                            
                            SizedBox(height: logoSpacing),
                            
                            // Nom de la marque
                            Flexible(
                              child: Image.asset(
                                'IM/ecriture.png',
                                width: isMobile ? screenWidth * 0.5 : isTablet ? 220 : 240,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'gnala',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isMobile ? 36 : isTablet ? 44 : 48,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w300,
                                          height: 1.0,
                                        ),
                                      ),
                                      Text(
                                        'cosmetic',
                                        style: TextStyle(
                                          color: const Color(0xFF22C55E),
                                          fontSize: isMobile ? 18 : isTablet ? 22 : 24,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            
                            SizedBox(height: textSpacing),
                            
                            // Indicateur de chargement
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFF22C55E).withOpacity(0.8),
                                ),
                              ),
                            ),
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

  Widget _buildConcentricLogo(
    double screenHeight,
    bool isMobile,
    bool isTablet,
    double screenWidth,
  ) {
    // Taille de base responsive, adaptée pour le splash
    // Réduire encore plus pour les petits écrans
    double baseSize = screenHeight < 600
        ? (isMobile ? screenWidth * 0.18 : isTablet ? 85 : 100)
        : screenHeight < 700
            ? (isMobile ? screenWidth * 0.20 : isTablet ? 95 : 110)
            : (isMobile ? screenWidth * 0.25 : isTablet ? 120 : 140);
    
    // Limites pour éviter des tailles trop grandes ou trop petites
    final double maxBaseCandidate = screenWidth * 0.30;
    final double maxBase = maxBaseCandidate < 90.0
        ? 90.0
        : (maxBaseCandidate > 180.0 ? 180.0 : maxBaseCandidate);
    final double minBase = screenHeight < 600 ? 60.0 : screenHeight < 700 ? 65.0 : 75.0;
    baseSize = baseSize.clamp(minBase, maxBase).toDouble();
    
    // Taille totale maximale des cercles
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
            // Point décoratif en haut
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
            // Grille de points en haut à droite
            Positioned(
              top: baseSize * 0.12,
              right: baseSize * 0.1,
              child: Transform.scale(
                scale: (baseSize / 120).clamp(0.7, 1.4),
                child: const _DotGrid(),
              ),
            ),
            // Logo cercle.png au centre
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
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

