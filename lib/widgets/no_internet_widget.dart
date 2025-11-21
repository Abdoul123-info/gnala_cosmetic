import 'package:flutter/material.dart';
import '../utils/responsive.dart';

/// Widget affiché quand il n'y a pas de connexion internet
class NoInternetWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetWidget({super.key, this.onRetry});

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
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: ResponsiveUtils.getHorizontalPadding(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icône WiFi barré
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.wifi_off_rounded,
                      size: isMobile ? 80 : 100,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Titre
                  Text(
                    'Pas de connexion internet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.getTitleFontSize(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Message d'excuse
                  Text(
                    'Nous sommes désolés, mais votre appareil n\'est pas connecté à internet.\n\n'
                    'Veuillez vous connecter à internet pour continuer.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: ResponsiveUtils.getBodyFontSize(context),
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Bouton Réessayer
                  if (onRetry != null)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Réessayer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ResponsiveUtils.getBodyFontSize(context) + 2,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
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

