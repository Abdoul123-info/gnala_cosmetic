import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/users_service.dart';

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  final UsersService _usersService = UsersService();
  List<UserStats> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final users = await _usersService.fetchUsers();
      setState(() {
        _users = users;
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

      print('❌ Erreur chargement utilisateurs: $errorMessage');

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

  Future<void> _toggleBlockUser(UserStats user) async {
    final action = user.blocked ? 'débloquer' : 'bloquer';
    final confirmMessage = user.blocked
        ? 'Voulez-vous vraiment débloquer cet utilisateur ?'
        : 'Voulez-vous vraiment bloquer cet utilisateur ?\n\nL\'utilisateur ne pourra plus passer de commandes.';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer le $action'),
          content: Text(confirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: user.blocked ? Colors.green : Colors.red,
              ),
              child: Text(action.toUpperCase()),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      if (user.blocked) {
        await _usersService.unblockUser(user.uid);
        Fluttertoast.showToast(
          msg: 'Utilisateur débloqué avec succès',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        await _usersService.blockUser(user.uid);
        Fluttertoast.showToast(
          msg: 'Utilisateur bloqué avec succès',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
      }
      await _loadUsers(showLoader: false);
    } catch (e) {
      String errorMessage = 'Erreur lors du ${action}';
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

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _deleteUser(UserStats user) async {
    final confirmMessage1 = '⚠️ ATTENTION : Voulez-vous vraiment SUPPRIMER DÉFINITIVEMENT cet utilisateur ?\n\nCette action est IRRÉVERSIBLE et supprimera :\n• Le compte Firebase Auth\n• Les données Firestore\n• Les favoris\n• Le numéro de téléphone';

    final confirmed1 = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⚠️ Suppression définitive'),
          content: Text(confirmMessage1),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Continuer'),
            ),
          ],
        );
      },
    );

    if (confirmed1 != true) return;

    final confirmMessage2 = '⚠️ DERNIÈRE CONFIRMATION :\n\nL\'utilisateur "${user.name.isNotEmpty ? user.name : user.email}" sera supprimé définitivement.\n\nCette action ne peut pas être annulée.';

    final confirmed2 = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⚠️ Confirmation finale'),
          content: Text(confirmMessage2),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('SUPPRIMER'),
            ),
          ],
        );
      },
    );

    if (confirmed2 != true) return;

    try {
      await _usersService.deleteUser(user.uid);
      Fluttertoast.showToast(
        msg: 'Utilisateur supprimé avec succès',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      await _loadUsers(showLoader: false);
    } catch (e) {
      String errorMessage = 'Erreur lors de la suppression';
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

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A6456),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A6456),
        foregroundColor: const Color(0xFFD4C896),
        title: const Text(
          'Gestion des Utilisateurs',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFD4C896)),
            onPressed: () => _loadUsers(),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4C896)),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _loadUsers(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4C896),
                          foregroundColor: const Color(0xFF4A6456),
                        ),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Color(0xFFD4C896),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucun utilisateur trouvé',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _loadUsers(showLoader: false),
                      color: const Color(0xFFD4C896),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return _buildUserCard(user);
                        },
                      ),
                    ),
    );
  }

  Widget _buildUserCard(UserStats user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8DDB5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: user.blocked ? Colors.red : const Color(0xFFD4C896),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec nom et statut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.isNotEmpty ? user.name : 'Sans nom',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A6456),
                      ),
                    ),
                    if (user.email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A6456),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: user.blocked ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.blocked ? 'BLOQUÉ' : 'ACTIF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Informations de contact
          if (user.phone.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Color(0xFF4A6456)),
                const SizedBox(width: 8),
                Text(
                  user.phone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A6456),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          // Statistiques des commandes
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem('Commandes', user.ordersCount.toString()),
                    _buildStatItem('Livrées', user.deliveredOrdersCount.toString()),
                    _buildStatItem('En cours', (user.pendingOrdersCount + user.processingOrdersCount + user.confirmedOrdersCount + user.shippedOrdersCount).toString()),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Prix total:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A6456),
                      ),
                    ),
                    Text(
                      '${_formatPrice(user.totalRevenue)} FCFA',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4A855),
                      ),
                    ),
                  ],
                ),
                if (user.status.isNotEmpty && user.status != 'Aucune commande') ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Color(0xFF4A6456)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Statut: ${user.status}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4A6456),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _toggleBlockUser(user),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: user.blocked ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(user.blocked ? Icons.lock_open : Icons.block, size: 18),
                      const SizedBox(width: 8),
                      Text(user.blocked ? 'Débloquer' : 'Bloquer'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _deleteUser(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_forever, size: 18),
                    SizedBox(width: 4),
                    Text('Supprimer'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A6456),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF4A6456),
          ),
        ),
      ],
    );
  }
}

