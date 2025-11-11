import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../config/cloudinary_config.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Récupérer tous les produits en temps réel
  Stream<List<Product>> getProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Récupérer le nombre de produits
  Future<int> getProductsCount() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.docs.length;
  }

  // Ajouter un produit
  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toFirestore());
  }

  // Mettre à jour un produit
  Future<void> updateProduct(Product product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toFirestore());
  }

  // Supprimer un produit
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  // Upload d'image vers Cloudinary (pour File - mobile)
  Future<String> uploadProductImage(File imageFile) async {
    try {
      // Lire les bytes du fichier
      Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Générer un nom de fichier unique
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_product.jpg';
      
      // Upload vers Cloudinary
      return await _uploadToCloudinary(imageBytes, fileName);
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  // Upload d'image vers Cloudinary (pour Uint8List - web)
  Future<String> uploadProductImageBytes(Uint8List imageBytes) async {
    try {
      // Générer un nom de fichier unique
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_product.jpg';
      
      // Upload vers Cloudinary
      return await _uploadToCloudinary(imageBytes, fileName);
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  // Méthode privée pour uploader vers Cloudinary
  Future<String> _uploadToCloudinary(Uint8List imageBytes, String fileName) async {
    try {
      // Convertir l'image en base64
      String base64Image = base64Encode(imageBytes);
      
      // Construire l'URL d'upload Cloudinary
      String uploadUrl = 'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload';
      
      // Construire les paramètres pour un preset unsigned
      Map<String, String> fields = {
        'file': 'data:image/jpeg;base64,$base64Image',
        'upload_preset': CloudinaryConfig.uploadPreset, // Utiliser le preset ml_default
        'folder': CloudinaryConfig.productsFolder, // gnala_cosmetic/products
      };
      
      // Créer la requête multipart
      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      
      // Ajouter les champs
      fields.forEach((key, value) {
        request.fields[key] = value;
      });
      
      // Envoyer la requête
      http.StreamedResponse response = await request.send();
      
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        String imageUrl = jsonResponse['secure_url'] ?? jsonResponse['url'];
        
        if (imageUrl.isEmpty) {
          throw Exception('URL d\'image vide reçue de Cloudinary');
        }
        
        return imageUrl;
      } else {
        String errorBody = await response.stream.bytesToString();
        throw Exception('Erreur Cloudinary (${response.statusCode}): $errorBody');
      }
    } catch (e) {
      print('Erreur upload Cloudinary: $e');
      throw Exception('Échec de l\'upload vers Cloudinary: $e');
    }
  }

  // Sélectionner une image depuis la galerie
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la sélection de l\'image: $e');
    }
  }

  // Prendre une photo avec la caméra
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la prise de photo: $e');
    }
  }
}

