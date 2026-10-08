import 'package:http/http.dart' as http;
import 'dart:convert';

class Product {
  final String id;
  final String barcode;
  final String name;
  final double price;
  int quantity;

  Product({
    required this.id,
    required this.barcode,
    required this.name,
    required this.price,
    this.quantity = 1,
  });
}

// Temporary Mock Database for Prototype
final List<Product> mockDatabase = [
  Product(id: '1', barcode: '890123', name: 'Coca Cola', price: 40.0),
  Product(id: '2', barcode: '890124', name: 'Lays', price: 20.0),
  Product(id: '3', barcode: '890125', name: 'Snickers', price: 50.0),
];

// Simple state management for virtual cart
class CartState {
  static final CartState _instance = CartState._internal();
  factory CartState() => _instance;
  CartState._internal();

  List<Product> cartItems = [];

  Future<bool> addProductByBarcode(String barcode) async {
    // 1. Check local mock database first
    var product = mockDatabase.where((p) => p.barcode == barcode).firstOrNull;
    
    if (product != null) {
      _addToCartList(product);
      return true;
    }

    // 2. If not found locally, search the real internet (OpenFoodFacts API)
    try {
      final response = await http.get(
        Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1) { // 1 means found
          final productName = data['product']['product_name'] ?? 'Unknown Item';
          
          // API doesn't give prices, so we assign a random dummy price for the MVP
          final newProduct = Product(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            barcode: barcode,
            name: productName,
            price: 50.0, // Mock price
          );
          
          _addToCartList(newProduct);
          return true;
        }
      }
    } catch (e) {
      print('API Error: $e');
    }
    
    return false; // Product not found on internet either
  }

  void _addToCartList(Product product) {
    var existing = cartItems.where((p) => p.barcode == product.barcode).firstOrNull;
    if (existing != null) {
      existing.quantity++;
    } else {
      cartItems.add(Product(
        id: product.id, 
        barcode: product.barcode, 
        name: product.name, 
        price: product.price
      ));
    }
  }

  void removeProduct(String id) {
    cartItems.removeWhere((item) => item.id == id);
  }

  double getTotal() {
    return cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }
}
