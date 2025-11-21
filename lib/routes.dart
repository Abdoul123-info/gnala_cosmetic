import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/home_page.dart';
import 'pages/admin_dashboard.dart';
import 'pages/cart_page.dart';
import 'pages/checkout_page.dart';
import 'pages/product_detail_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/order_history_page.dart';
import 'pages/favorites_page.dart';
import 'pages/profile_page.dart';
import 'models/product.dart';

class AppRoutes {
  // Noms des routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String admin = '/admin';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String productDetail = '/product-detail';
  static const String forgotPassword = '/forgot-password';
  static const String orderHistory = '/order-history';
  static const String favorites = '/favorites';
  static const String profile = '/profile';

  // Configuration des routes
  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginPage(),
      signup: (context) => const SignupPage(),
      home: (context) => const HomePage(),
      admin: (context) => const AdminDashboard(),
      cart: (context) => const CartPage(),
      checkout: (context) => const CheckoutPage(),
      forgotPassword: (context) => const ForgotPasswordPage(),
      orderHistory: (context) => const OrderHistoryPage(),
      favorites: (context) => const FavoritesPage(),
      profile: (context) => const ProfilePage(),
    };
  }

  // Navigation avec remplacement de pile
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, login, (route) => false);
  }

  static void navigateToSignup(BuildContext context) {
    Navigator.pushNamed(context, signup);
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, home, (route) => false);
  }

  static void navigateToAdmin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, admin, (route) => false);
  }

  static void navigateToCart(BuildContext context) {
    Navigator.pushNamed(context, cart);
  }

  // Navigation basée sur le rôle
  static void navigateBasedOnRole(BuildContext context, String role) {
    if (role.toLowerCase() == 'admin') {
      navigateToAdmin(context);
    } else {
      navigateToHome(context);
    }
  }

  // Navigation simple (ajout à la pile)
  static void goToLogin(BuildContext context) {
    Navigator.pushNamed(context, login);
  }

  static void goToSignup(BuildContext context) {
    Navigator.pushNamed(context, signup);
  }

  static void goToCart(BuildContext context) {
    Navigator.pushNamed(context, cart);
  }

  static void navigateToForgotPassword(BuildContext context) {
    Navigator.pushNamed(context, forgotPassword);
  }

  static void navigateToOrderHistory(BuildContext context) {
    Navigator.pushNamed(context, orderHistory);
  }

  static void navigateToFavorites(BuildContext context) {
    Navigator.pushNamed(context, favorites);
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, profile);
  }

  static void navigateToCheckout(BuildContext context) {
    Navigator.pushNamed(context, checkout);
  }

  static void goToCheckout(BuildContext context) {
    Navigator.pushNamed(context, checkout);
  }

  // Navigation avec remplacement simple
  static void replaceWithLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, login);
  }

  static void replaceWithSignup(BuildContext context) {
    Navigator.pushReplacementNamed(context, signup);
  }

  // Retour en arrière
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  // Navigation vers la page de détails produit
  static void navigateToProductDetail(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
  }
}

