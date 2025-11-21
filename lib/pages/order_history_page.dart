import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/order_history.dart';
import '../services/order_service.dart';
import '../services/local_order_storage.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final OrderService _orderService = OrderService();
  List<OrderHistoryEntry> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final orders = await _orderService.fetchOrderHistory();
      setState(() {
        _orders = orders;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      String errorMessage = 'Erreur de chargement';
      if (e is Exception) {
        final msg = e.toString();
        if (msg.contains('Exception: ')) {
          errorMessage = msg.replaceFirst('Exception: ', '');
        } else {
          errorMessage = msg;
        }
      } else {
        errorMessage = e.toString();
      }
      
      print('❌ Erreur chargement historique: $errorMessage');
      
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
      
      Fluttertoast.showToast(
        msg: errorMessage.length > 50 ? errorMessage.substring(0, 50) + '...' : errorMessage,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
      );
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF20C997);
      case 'confirmed':
      case 'processing':
      case 'shipped':
        return const Color(0xFF98C379);
      case 'cancelled':
        return const Color(0xFFE06C75);
      default:
        return const Color(0xFFD4A855);
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'processing':
        return 'En préparation';
      case 'shipped':
        return 'Expédiée';
      case 'delivered':
        return 'Livrée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date inconnue';
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _clearHistory() async {
    // Afficher une boîte de dialogue de confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0C4B2E),
        title: const Text(
          'Vider l\'historique',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vider tout l\'historique des commandes ? Cette action est irréversible.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE06C75),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Vider'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      print('🗑️ Début vidage historique - confirmation reçue');
      try {
        // Vider le cache local
        print('🗑️ Appel clearCache()...');
        await LocalOrderStorage.clearCache();
        print('🗑️ clearCache() terminé');
        
        // Vérifier que le flag est bien sauvegardé
        final isCleared = await LocalOrderStorage.isHistoryCleared();
        print('🗑️ Vérification flag après clearCache: $isCleared');
        
        // Vider la liste affichée
        setState(() {
          _orders = [];
        });

        // Afficher un message de confirmation
        Fluttertoast.showToast(
          msg: 'Historique vidé avec succès',
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: const Color(0xFF0C4B2E),
          textColor: Colors.white,
        );
      } catch (e) {
        print('❌ Erreur lors du vidage: $e');
        Fluttertoast.showToast(
          msg: 'Erreur lors du vidage de l\'historique: ${e.toString()}',
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: const Color(0xFFE06C75),
          textColor: Colors.white,
        );
      }
    } else {
      print('🗑️ Vidage historique annulé par l\'utilisateur');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A6456),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4B2E),
        title: const Text(
          'Historique des commandes',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_orders.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: 'Vider l\'historique',
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4C896)),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_orders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: const Color(0xFF0C4B2E),
      onRefresh: () => _loadOrders(showLoader: false),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.white.withOpacity(0.8), size: 48),
            const SizedBox(height: 16),
            Text(
              _error ?? "Erreur inconnue",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A855),
                foregroundColor: Colors.black87,
              ),
              onPressed: () => _loadOrders(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 56, color: Colors.white.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text(
              'Vous n’avez pas encore de commande.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
            ),
            const SizedBox(height: 8),
            Text(
              'Passez votre première commande pour la retrouver ici.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderHistoryEntry order) {
    final statusColor = _statusColor(order.status);
    final productsPreview = order.products.take(3).toList();
    final remaining = order.products.length - productsPreview.length;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C4B2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4C896), width: 2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Ma commande',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  _statusLabel(order.status),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(order.createdAt ?? order.updatedAt),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.shopping_bag_outlined, color: Colors.white.withOpacity(0.8)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${order.totalItems} article${order.totalItems > 1 ? "s" : ""} • ${order.totalPrice.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...productsPreview.map(
                (product) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${product.quantity} × ${product.name} (${product.totalPrice.toStringAsFixed(0)} FCFA)',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              if (remaining > 0)
                Text(
                  '+ $remaining autre${remaining > 1 ? "s" : ""} article${remaining > 1 ? "s" : ""}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.pin_drop_outlined, color: Colors.white.withOpacity(0.8), size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.address.isNotEmpty ? order.address : 'Adresse non renseignée',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.local_shipping_outlined, color: Colors.white.withOpacity(0.8), size: 20),
              const SizedBox(width: 6),
              Text(
                '${order.zone.isNotEmpty ? order.zone : 'Zone inconnue'} • Livraison',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

