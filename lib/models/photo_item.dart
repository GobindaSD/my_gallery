import 'package:flutter/material.dart';
import '../services/api_config.dart';

class PhotoItem {
  final String? id;
  final String? imageUrl;
  final String size; // দেখানোর জন্য, যেমন "3.87 MB"
  final double sizeBytes; // মোট storage হিসাবের জন্য
  final String date;
  final List<Color> colors; // ছবি না থাকলে placeholder
  final bool isAi;
  bool isFav;

  PhotoItem({
    this.id,
    this.imageUrl,
    required this.size,
    this.sizeBytes = 0,
    required this.date,
    this.colors = const [Color(0xFFD1C4FF), Color(0xFF9B8CF5)],
    this.isAi = false,
    this.isFav = false,
  });

  factory PhotoItem.fromJson(Map<String, dynamic> json) {
    // ছবির লিংক: সম্ভাব্য key গুলো চেক করা হচ্ছে
    String? img;
    for (final k in ['image', 'imageUrl', 'url', 'photo', 'path']) {
      final v = json[k];
      if (v is String && v.isNotEmpty) {
        img = v;
        break;
      }
    }
    if (img != null && !img.startsWith('http')) {
      img = '${ApiConfig.origin}${img.startsWith('/') ? '' : '/'}$img';
    }

    // সাইজ (bytes ধরা হয়েছে)
    double bytes = 0;
    String sizeText = '';
    final s = json['size'];
    if (s is num) {
      bytes = s.toDouble();
      sizeText = '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else if (s is String) {
      sizeText = s;
      bytes = (double.tryParse(s) ?? 0);
      if (bytes > 0) sizeText = '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }

    return PhotoItem(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      imageUrl: img,
      size: sizeText.isEmpty ? '—' : sizeText,
      sizeBytes: bytes,
      date: _formatDate(json['createdAt']?.toString()),
      isAi: json['isAI'] == true || json['isAi'] == true,
      isFav: json['isFavorite'] == true,
    );
  }

  static String _formatDate(String? iso) {
    final d = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
    if (d == null) return '';
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}
