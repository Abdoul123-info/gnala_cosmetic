import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'guards/auth_guard.dart';
import 'providers/cart_provider.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        title: 'Gnala Cosmetic',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: const ColorScheme(
            primary: Color(0xFF0C4B2E), // Vert foncé (comme login_page)
            secondary: Color(0xFF22C55E), // Vert brillant (comme login_page)
            tertiary: Color(0xFF486A5A), // Vert moyen (pour gradients)
            surface: Color(0xFFD8E8DF), // Fond carte (comme login_page)
            background: Color(0xFF2C4A3E), // Fond principal (comme login_page)
            error: Colors.red,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onTertiary: Colors.white,
            onSurface: Color(0xFF0C4B2E),
            onBackground: Colors.white,
            onError: Colors.white,
            brightness: Brightness.light,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C4B2E),
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 48),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0C4B2E),
              side: const BorderSide(color: Color(0xFF0C4B2E)),
              minimumSize: const Size(120, 48),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0C4B2E),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            color: const Color(0xFFD8E8DF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        home: const AuthWrapper(),
        routes: AppRoutes.routes,
      ),
    );
  }
}
