import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ComplaintPhotoViewer extends StatelessWidget {
  final String? imagePath;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  const ComplaintPhotoViewer({
    super.key,
    required this.imagePath,
    this.height = 140,
    this.borderRadius = 16,
    this.fit = BoxFit.cover,
  });

  static bool hasValidImage(String? path) {
    return path != null && path.trim().isNotEmpty && path != 'none';
  }

  @override
  Widget build(BuildContext context) {
    if (!hasValidImage(imagePath)) {
      return const SizedBox.shrink();
    }

    final rawPath = imagePath!.trim();

    return GestureDetector(
      onTap: () => _showFullScreenPreview(context, rawPath),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.darkNavy,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImageContent(rawPath),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'View Photo',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent(String path) {
    try {
      // 1. Base64 Image
      if (path.startsWith('data:image') || path.length > 200) {
        final base64String = path.contains(',') ? path.split(',').last : path;
        final bytes = base64Decode(base64String.trim());
        return Image.memory(
          bytes,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      }

      // 2. HTTP/HTTPS Network URL
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return Image.network(
          path,
          fit: fit,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brightCyan),
              ),
            );
          },
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      }

      // 3. Local File System
      if (!kIsWeb && File(path).existsSync()) {
        return Image.file(
          File(path),
          fit: fit,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      }
    } catch (_) {}

    return _buildFallback();
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.deepNavy,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_not_supported_rounded, color: AppColors.textGrey, size: 28),
            const SizedBox(height: 4),
            Text(
              'Evidence Attached',
              style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenPreview(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.92),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Attached Photo Evidence',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white70),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(ctx).size.height * 0.65,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: InteractiveViewer(
                          child: _buildImageContent(path),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
