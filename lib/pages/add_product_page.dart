import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  final ProductService _productService = ProductService();
  File? _selectedImage;
  Uint8List? _imageBytes; // Pour Flutter Web
  bool _isLoading = false;
  String _selectedCategory = 'Nouveautés';
  bool _isAvailable = true;
  bool _isNew = false;
  bool _isRecommended = false;
  bool _isPromotion = false;
  
  final List<String> _categories = [
    'Nouveautés',
    'Visage',
    'Corps',
    'Cheveux',
    'Homme',
    'Maquillage',
    'Parfum',
    'Promotions / Meilleures ventes',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Pour le web, utiliser image_picker avec XFile
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        
        if (image != null) {
          final Uint8List bytes = await image.readAsBytes();
          setState(() {
            _imageBytes = bytes;
          });
          
          Fluttertoast.showToast(
            msg: "Image sélectionnée avec succès !",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Erreur lors de la sélection de l'image: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      return;
    }
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    File? image = await _productService.pickImageFromGallery();
                    if (image != null) {
                      setState(() {
                        _selectedImage = image;
                      });
                    }
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: "Erreur lors de la sélection de l'image: $e",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Caméra'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    File? image = await _productService.pickImageFromCamera();
                    if (image != null) {
                      setState(() {
                        _selectedImage = image;
                      });
                    }
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: "Erreur lors de la prise de photo: $e",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // Vérifier qu'une image a été sélectionnée
    if (!kIsWeb && _selectedImage == null) {
      Fluttertoast.showToast(
        msg: "Veuillez sélectionner une image",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (kIsWeb && _imageBytes == null) {
      Fluttertoast.showToast(
        msg: "Veuillez sélectionner une image",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = '';
      
      // Uploader l'image
      if (kIsWeb && _imageBytes != null) {
        imageUrl = await _productService.uploadProductImageBytes(_imageBytes!);
      } else if (!kIsWeb && _selectedImage != null) {
        imageUrl = await _productService.uploadProductImage(_selectedImage!);
      }

      if (imageUrl.isEmpty) {
        throw Exception('Échec de l\'upload de l\'image');
      }

      // Créer le produit
      final now = DateTime.now();
      Product newProduct = Product(
        id: '', // Sera généré par Firestore
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        imageUrl: imageUrl,
        category: _selectedCategory,
        isRecommended: _isRecommended,
        isNew: _isNew,
        isPromotion: _isPromotion,
        isAvailable: _isAvailable,
        createdAt: now,
        updatedAt: now,
      );

      // Ajouter le produit dans Firestore
      await _productService.addProduct(newProduct);

      Fluttertoast.showToast(
        msg: "Produit ajouté avec succès !",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      // Retourner à la page précédente
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur lors de l'ajout du produit: $e",
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        title: const Text('Ajouter un produit'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section image
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Image du produit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: _selectedImage != null || _imageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: kIsWeb && _imageBytes != null
                                    ? Image.memory(
                                        _imageBytes!,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Appuyez pour sélectionner une image',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section informations
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations du produit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nom du produit
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du produit',
                        hintText: 'Entrez le nom du produit',
                        prefixIcon: Icon(Icons.shopping_bag),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer le nom du produit';
                        }
                        if (value.trim().length < 2) {
                          return 'Le nom doit contenir au moins 2 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Entrez la description du produit',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer la description';
                        }
                        if (value.trim().length < 10) {
                          return 'La description doit contenir au moins 10 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Prix
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prix (FCFA)',
                        hintText: 'Entrez le prix du produit',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer le prix';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Veuillez entrer un prix valide';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Le prix doit être supérieur à 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Catégorie
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner une catégorie';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Disponibilité
                    SwitchListTile(
                      title: const Text('Produit disponible'),
                      subtitle: const Text('Le produit est disponible à la vente'),
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      },
                      secondary: Icon(
                        _isAvailable ? Icons.check_circle : Icons.cancel,
                        color: _isAvailable ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Nouveauté
                    SwitchListTile(
                      title: const Text('Produit nouveauté'),
                      subtitle: const Text('Marquer ce produit comme une nouveauté'),
                      value: _isNew,
                      onChanged: (value) {
                        setState(() {
                          _isNew = value;
                        });
                      },
                      secondary: Icon(
                        _isNew ? Icons.fiber_new : Icons.new_releases_outlined,
                        color: _isNew ? Colors.blue : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Recommandé
                    SwitchListTile(
                      title: const Text('Produit recommandé'),
                      subtitle: const Text('Afficher dans "Recommandé pour vous"'),
                      value: _isRecommended,
                      onChanged: (value) {
                        setState(() {
                          _isRecommended = value;
                        });
                      },
                      secondary: Icon(
                        _isRecommended ? Icons.star : Icons.star_border,
                        color: _isRecommended ? Colors.amber : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Promotion / Meilleures ventes
                    SwitchListTile(
                      title: const Text('Promotion / Meilleures ventes'),
                      subtitle: const Text('Mettre en avant dans Promotions / Meilleures ventes'),
                      value: _isPromotion,
                      onChanged: (value) {
                        setState(() {
                          _isPromotion = value;
                        });
                      },
                      secondary: Icon(
                        _isPromotion ? Icons.local_fire_department : Icons.local_fire_department_outlined,
                        color: _isPromotion ? Colors.redAccent : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bouton d'ajout
              ElevatedButton(
                onPressed: _isLoading ? null : _addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                        'Ajouter le produit',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


