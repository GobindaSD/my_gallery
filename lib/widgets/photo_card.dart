import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/photo_item.dart';

class PhotoCard extends StatelessWidget {
  final PhotoItem photo;
  final VoidCallback onFavTap;

  const PhotoCard({super.key, required this.photo, required this.onFavTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: photo.colors,
                ),
              ),
              child: Stack(
                children: [
                  if (photo.imageUrl != null)
                    Positioned.fill(
                      child: Image.network(
                        photo.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                                ? child
                                : const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                        errorBuilder: (context, error, stack) => Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white.withOpacity(0.9),
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  if (photo.imageUrl == null)
                    Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: Colors.white.withOpacity(0.9),
                        size: 36,
                      ),
                    ),
                  if (photo.isAi)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8A5B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavTap,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          photo.isFav ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: photo.isFav ? Colors.red : AppColors.dark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photo.size,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  photo.date,
                  style: const TextStyle(color: AppColors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
