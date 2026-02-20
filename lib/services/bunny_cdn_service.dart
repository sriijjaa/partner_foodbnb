import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BunnyCdnService {
  // ─── BunnyCDN Configuration ────────────────────────────────────────────────
  static const String storageZone = 'foodbnb-images';

  // Access key: BunnyCDN → foodbnb-storage → FTP & API Access → Password
  static const String accessKey = 'fe822c35-37e6-4260-84326ab95ac8-fc27-45de';

  // ─── All BunnyCDN regional storage endpoints ───────────────────────────────
  // The service will auto-try each until one returns HTTP 201.
  static const List<String> _regionalEndpoints = [
    'https://sg.storage.bunnycdn.com', // Singapore  ← most likely for India
    'https://storage.bunnycdn.com', // Germany (DE) — default
    'https://ny.storage.bunnycdn.com', // New York
    'https://la.storage.bunnycdn.com', // Los Angeles
    'https://uk.storage.bunnycdn.com', // London
    'https://syd.storage.bunnycdn.com', // Sydney
    'https://jh.storage.bunnycdn.com', // Johannesburg
    'https://se.storage.bunnycdn.com', // Stockholm
  ];

  // ─── Folder paths inside the storage zone ──────────────────────────────────
  static const String _dishImagePath = 'images/dish_image/';
  static const String _profilesPath = 'images/profiles/';

  // ─── Singleton setup ───────────────────────────────────────────────────────
  BunnyCdnService._();
  static final BunnyCdnService instance = BunnyCdnService._();

  // ─── Upload helpers ────────────────────────────────────────────────────────

  /// Uploads a dish image and returns its direct storage URL.
  Future<String> uploadDishImage(File file) async {
    final fileName = _uniqueFileName(file);
    final bytes = await file.readAsBytes();
    final endpoint = await _uploadWithRegionDetect(
      fileName,
      bytes,
      _dishImagePath,
    );
    return '$endpoint/$storageZone/$_dishImagePath$fileName';
  }

  /// Uploads a profile image and returns its direct storage URL.
  Future<String> uploadProfileImage(File file) async {
    final fileName = _uniqueFileName(file);
    final bytes = await file.readAsBytes();
    final endpoint = await _uploadWithRegionDetect(
      fileName,
      bytes,
      _profilesPath,
    );
    return '$endpoint/$storageZone/$_profilesPath$fileName';
  }

  // ─── Core upload — tries every regional endpoint until one succeeds ────────
  Future<String> _uploadWithRegionDetect(
    String fileName,
    List<int> bytes,
    String path,
  ) async {
    for (final endpoint in _regionalEndpoints) {
      final url = Uri.parse('$endpoint/$storageZone/$path$fileName');
      debugPrint('[BunnyCDN] Trying $url');

      final response = await http.put(
        url,
        headers: {
          'AccessKey': accessKey,
          'Content-Type': 'application/octet-stream',
          'Accept': 'application/json',
        },
        body: bytes,
      );

      debugPrint('[BunnyCDN] ${response.statusCode} ← $endpoint');

      if (response.statusCode == 201) {
        debugPrint('[BunnyCDN] ✅ Success with region: $endpoint');
        return endpoint; // Return the working endpoint
      }

      // 401 = wrong region (key is valid but zone is elsewhere), try next
      // any other 4xx/5xx is a real error — stop immediately
      if (response.statusCode != 401) {
        throw Exception(
          'BunnyCDN upload failed — HTTP ${response.statusCode}: ${response.body}',
        );
      }
    }

    throw Exception(
      'BunnyCDN upload failed — could not find the correct storage region. '
      'Please check your storage zone region on panel.bunny.net/storage.',
    );
  }

  // ─── Private util ──────────────────────────────────────────────────────────
  String _uniqueFileName(File file) {
    final ext = file.path.split('.').last;
    final ts = DateTime.now().millisecondsSinceEpoch;
    return '$ts.$ext';
  }
}
