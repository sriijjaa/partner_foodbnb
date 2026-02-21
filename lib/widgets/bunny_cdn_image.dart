import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// ─── Controller ──────────────────────────────────────────────────────────────

class BunnyCdnImageController extends GetxController {
  static const String _accessKey = 'fe822c35-37e6-4260-84326ab95ac8-fc27-45de';
  static const String _storageZone = 'foodbnb-images';

  // Shared cache across all instances
  static final Map<String, Uint8List> _cache = {};

  String _toStorageApiUrl(String url) {
    if (url.contains('storage.bunnycdn.com')) return url;
    final path = Uri.parse(url).path;
    return 'https://storage.bunnycdn.com/$_storageZone$path';
  }

  Future<Uint8List> fetchImage(String url) async {
    if (_cache.containsKey(url)) return _cache[url]!;

    final response = await http.get(
      Uri.parse(_toStorageApiUrl(url)),
      headers: {'AccessKey': _accessKey, 'Accept': '*/*'},
    );

    if (response.statusCode == 200) {
      _cache[url] = response.bodyBytes;
      return response.bodyBytes;
    }
    throw Exception('Image fetch failed (${response.statusCode})');
  }
}

// ─── Widget ───────────────────────────────────────────────────────────────────

class BunnyCdnImage extends StatelessWidget {
  final String? storageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget Function()? placeholder;

  const BunnyCdnImage({
    super.key,
    required this.storageUrl,
    this.width = 100,
    this.height = 110,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BunnyCdnImageController());
    final url = storageUrl;

    if (url == null || url.isEmpty) {
      return _placeholder();
    }

    return FutureBuilder<Uint8List>(
      future: controller.fetchImage(url),
      builder: (context, snapshot) {
        // ── Loading ──
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFEF5350),
              ),
            ),
          );
        }

        // ── Error ──
        if (snapshot.hasError || !snapshot.hasData) {
          return _placeholder();
        }

        // ── Success ──
        return SizedBox(
          width: width,
          height: height,
          child: Image.memory(
            snapshot.data!,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (_, __, ___) => _placeholder(),
          ),
        );
      },
    );
  }

  Widget _placeholder() {
    return placeholder?.call() ??
        Container(
          width: width,
          height: height,
          color: const Color(0xFFFFF5F5),
          alignment: Alignment.center,
          child: const Icon(
            Icons.fastfood_rounded,
            color: Color(0xFFEF9A9A),
            size: 34,
          ),
        );
  }
}
