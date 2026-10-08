import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/product.dart';
import 'cart_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  String? _lastScannedCode;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String code = barcodes.first.rawValue ?? "";
      if (code.isNotEmpty) {
        // If it's the exact same item they just scanned, ignore it to prevent spamming
        if (code == _lastScannedCode) return;

        setState(() { 
          _isProcessing = true; 
          _lastScannedCode = code;
        });
        
        bool success = await CartState().addProductByBarcode(code);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(success ? Icons.check_circle : Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(success ? 'Added to Cart: $code' : 'Not found on internet: $code', style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            backgroundColor: success ? Colors.green.shade600 : Colors.redAccent.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 2),
          ),
        );

        // Allow scanning a DIFFERENT item immediately after 1 second
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() { _isProcessing = false; });
          }
        });

        // Allow scanning the SAME item again only after 5 seconds
        // (If they actually have two bottles of the same item)
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            _lastScannedCode = null;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CartScreen()));
              },
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          
          // Custom beautiful scanner overlay
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: Colors.deepPurpleAccent,
                borderRadius: 20,
                borderLength: 40,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
          ),
          
          // Animated Scanning Line inside the box (Optional visual flair)
          
          // Instructions text at bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white24)
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Point camera at barcode',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
              ),
            )
        ],
      ),
    );
  }
}

// Helper class for the scanner cutout overlay
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }
    return _getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _cutOutSize = cutOutSize < width ? cutOutSize : width - borderOffset;

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.65)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: _cutOutSize,
      height: _cutOutSize,
    );

    canvas
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)), boxPaint)
      ..restore();

    canvas.drawRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)), borderPaint);
    
    // Draw corners
    final strokePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    // Top left
    canvas.drawLine(Offset(cutOutRect.left, cutOutRect.top + borderRadius), Offset(cutOutRect.left, cutOutRect.top + borderLength), strokePaint);
    canvas.drawLine(Offset(cutOutRect.left + borderRadius, cutOutRect.top), Offset(cutOutRect.left + borderLength, cutOutRect.top), strokePaint);
    // Top right
    canvas.drawLine(Offset(cutOutRect.right, cutOutRect.top + borderRadius), Offset(cutOutRect.right, cutOutRect.top + borderLength), strokePaint);
    canvas.drawLine(Offset(cutOutRect.right - borderRadius, cutOutRect.top), Offset(cutOutRect.right - borderLength, cutOutRect.top), strokePaint);
    // Bottom left
    canvas.drawLine(Offset(cutOutRect.left, cutOutRect.bottom - borderRadius), Offset(cutOutRect.left, cutOutRect.bottom - borderLength), strokePaint);
    canvas.drawLine(Offset(cutOutRect.left + borderRadius, cutOutRect.bottom), Offset(cutOutRect.left + borderLength, cutOutRect.bottom), strokePaint);
    // Bottom right
    canvas.drawLine(Offset(cutOutRect.right, cutOutRect.bottom - borderRadius), Offset(cutOutRect.right, cutOutRect.bottom - borderLength), strokePaint);
    canvas.drawLine(Offset(cutOutRect.right - borderRadius, cutOutRect.bottom), Offset(cutOutRect.right - borderLength, cutOutRect.bottom), strokePaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      borderRadius: borderRadius * t,
      borderLength: borderLength * t,
      cutOutSize: cutOutSize * t,
    );
  }
}
