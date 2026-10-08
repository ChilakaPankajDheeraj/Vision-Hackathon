import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isVerifying = false;
  String _verificationStatus = '';

  Future<void> _checkoutAndVerify() async {
    // 1. Show Fake Payment UI
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(color: Colors.greenAccent),
              SizedBox(height: 24),
              Text('Processing Payment...', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );

    // Simulate 2 seconds of payment processing
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context); // Close the payment dialog

    // 2. Just approve it directly (Removed AI Camera for MVP)
    _showExitDialog();
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'PAYMENT SUCCESSFUL',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your payment has been processed successfully.\nThank you for shopping at Nexera!',
              style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              CartState().cartItems.clear();
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
            child: const Text(
              'Finish',
              style: TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = CartState().cartItems;
    final total = CartState().getTotal();

    return Scaffold(
      backgroundColor: const Color(0xFF12121D), // Deep dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.white24),
                        SizedBox(height: 16),
                        Text('Your cart is empty', style: TextStyle(color: Colors.white54, fontSize: 18, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2C),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.fastfood_rounded, color: Colors.deepPurpleAccent, size: 28),
                          ),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text('₹${item.price} × ${item.quantity}', style: const TextStyle(color: Colors.white54, fontSize: 14)),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₹${item.price * item.quantity}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 20),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () {
                                  setState(() {
                                    CartState().removeProduct(item.id);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Bottom Checkout Section
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E2C),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              boxShadow: [
                BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, -5)),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white54)),
                      Text('₹$total', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_verificationStatus.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isVerifying) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.orangeAccent)),
                          if (_isVerifying) const SizedBox(width: 12),
                          Text(_verificationStatus, style: const TextStyle(color: Colors.orangeAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ElevatedButton(
                    onPressed: cartItems.isEmpty || _isVerifying ? null : _checkoutAndVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      disabledBackgroundColor: Colors.deepPurple.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 10,
                      shadowColor: Colors.deepPurpleAccent.withOpacity(0.5),
                    ),
                    child: _isVerifying
                        ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.security_rounded, color: Colors.white, size: 26),
                              SizedBox(width: 12),
                              Text('PAY & VERIFY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.2)),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
