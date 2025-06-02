// lib/presentation/screens/scanner/scanner_screen.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/repositories/visit_repository.dart';
import '../../../domain/repositories/tag_repository.dart';
import '../../../injection_container.dart';
import '../places/place_detail_screen.dart';
import '../explore/detail/person_detail_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final ImagePicker _picker = ImagePicker();
  final supabase = Supabase.instance.client;

  bool _isProcessing = false;
  String? _lastBarcode;

  final VisitRepository _visitRepo = sl<VisitRepository>();
  final TagRepository _tagRepo = sl<TagRepository>();

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handlePlaceScan(int placeId) async {
    setState(() => _isProcessing = true);
    _scannerController.stop();

    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) {
      setState(() => _isProcessing = false);
      _scannerController.start();
      return;
    }

    try {
      final Uint8List bytes = await photo.readAsBytes();
      final String filePath =
          'visit-photos/place_${placeId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage.from('visit-photos').uploadBinary(filePath, bytes);
      final String publicUrl =
      supabase.storage.from('visit-photos').getPublicUrl(filePath);

      final result = await _visitRepo.createVisit(
        placeId: placeId,
        photoUrl: publicUrl,
      );

      result.fold(
            (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not create visit: ${failure.message}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        },
            (visit) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Visit recorded successfully!',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlaceDetailScreen(placeId: placeId),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to upload photo: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }

    setState(() => _isProcessing = false);
    _scannerController.start();
  }

  Future<void> _handlePersonScan(int personId) async {
    setState(() => _isProcessing = true);
    _scannerController.stop();

    final String? comment = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String temp = '';
        return AlertDialog(
          title: const Text('Add a comment'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter your comment…'),
            onChanged: (val) => temp = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(temp.trim()),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (comment == null || comment.isEmpty) {
      setState(() => _isProcessing = false);
      _scannerController.start();
      return;
    }

    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) {
      setState(() => _isProcessing = false);
      _scannerController.start();
      return;
    }

    try {
      final Uint8List bytes = await photo.readAsBytes();
      final String filePath =
          'visit-photos/person_${personId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage.from('visit-photos').uploadBinary(filePath, bytes);
      final String publicUrl =
      supabase.storage.from('visit-photos').getPublicUrl(filePath);

      final result = await _tagRepo.createTag(
        personId: personId,
        comment: comment,
        photoUrl: publicUrl,
        latitude: null,
        longitude: null,
      );

      result.fold(
            (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not create tag: ${failure.message}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        },
            (newTag) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Tag created successfully!',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PersonDetailScreen(person: newTag.person!),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to upload photo: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }

    setState(() => _isProcessing = false);
    _scannerController.start();
  }

  void _onBarcodeDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final raw = barcodes.first.rawValue;
    if (raw == null || raw == _lastBarcode) return;
    _lastBarcode = raw.trim();

    if (_lastBarcode!.startsWith('place:')) {
      final idPart = _lastBarcode!.substring(6);
      final placeId = int.tryParse(idPart);
      if (placeId != null) {
        _handlePlaceScan(placeId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Malformed place QR code'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else if (_lastBarcode!.startsWith('person:')) {
      final idPart = _lastBarcode!.substring(7);
      final personId = int.tryParse(idPart);
      if (personId != null) {
        _handlePersonScan(personId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Malformed person QR code'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unknown QR code format'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine size of the “scanning window” (square) based on screen width:
    final double scanWindowSize = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1) Live camera view for QR scanning:
          MobileScanner(
            controller: _scannerController,
            onDetect: _onBarcodeDetect,
          ),

          // 2) Semi‐transparent overlay, leaving a central square “window”:
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                // This creates a big rectangle and “cuts out” the center square
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: scanWindowSize,
                    height: scanWindowSize,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: scanWindowSize,
                      height: scanWindowSize,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.center_focus_strong,
                          size: 48,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3) Instructions at bottom in a safe area
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Place the QR code inside the box\n'
                    '• “place:<ID>” → create a Visit\n'
                    '• “person:<ID>” → create a Tag',
                style: AppTextStyles.bodyMedium?.copyWith(
                  color: Colors.white,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // 4) Busy indicator overlay when processing
          if (_isProcessing)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
