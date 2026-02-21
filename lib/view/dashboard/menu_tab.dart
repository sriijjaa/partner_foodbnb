import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partner_foodbnb/controller/dish_controller.dart';
import 'package:partner_foodbnb/view/screens/add_dish.dart';
import 'package:partner_foodbnb/widgets/bunny_cdn_image.dart';

class MenuScreen extends StatelessWidget {
  MenuScreen({super.key});

  final List<String> categories = [
    'All',
    'Active',
    'Sold Out',
    'Starters',
    'Mains',
    'Desserts',
  ];

  final RxInt selectedCategoryIndex = 0.obs;
  final DishMenuController dmc = Get.put(DishMenuController());

  // Reactive search state
  final RxString searchQuery = ''.obs;
  final RxInt _matchCount = 0.obs;

  // ── Design tokens ─────────────────────────────────────────────────────────
  static const _kPrimary = Color(0xFFEF5350);
  static const _kCrimson = Color(0xFFC62828); // deep red gradient end
  static const _kRadius = 16.0;
  static const _kCardShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];
  // Faint rose-white background
  static const _kBg = Color(0xFFFFF5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: _buildSearchBar(),
            ),
            _buildCategoryFilters(),
            Expanded(
              child: Obx(() {
                final selectedCategory =
                    categories[selectedCategoryIndex.value];
                final query = searchQuery.value.toLowerCase().trim();

                return Stack(
                  children: [
                    FirestoreListView<Map<String, dynamic>>(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      query: FirebaseFirestore.instance
                          .collection('dish')
                          .where(
                            'kitchen_id',
                            isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                          ),
                      loadingBuilder: (_) => _buildLoadingState(),
                      emptyBuilder: (_) => _buildEmptyState(),
                      itemBuilder: (context, doc) {
                        final dish = doc.data();
                        final bool matchesCategory = _matchesCategory(
                          dish,
                          selectedCategory,
                        );
                        final bool matchesSearch =
                            query.isEmpty ||
                            (dish['dish_name'] ?? '')
                                .toString()
                                .toLowerCase()
                                .contains(query);

                        if (!matchesCategory || !matchesSearch) {
                          return const SizedBox.shrink();
                        }

                        // Increment match counter after the frame
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _matchCount.value++;
                        });

                        return _buildDishCard(dish);
                      },
                    ),

                    // ── No-search-results overlay ──
                    Obx(() {
                      if (searchQuery.value.trim().isEmpty) {
                        return const SizedBox.shrink();
                      }
                      if (_matchCount.value > 0) {
                        return const SizedBox.shrink();
                      }
                      return _buildNoSearchResult(searchQuery.value.trim());
                    }),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_kPrimary, _kCrimson],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Menu Management',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: 0.2,
            ),
          ),
          Text(
            'Manage your dishes & availability',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: GestureDetector(
            onTap: () => Get.to(() => AddDishScreen(), arguments: [true, '']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add_rounded, color: _kPrimary, size: 18),
                  SizedBox(width: 5),
                  Text(
                    'ADD',
                    style: TextStyle(
                      color: _kPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Search Bar ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_kRadius),
          boxShadow: _kCardShadow,
        ),
        child: TextField(
          controller: dmc.searchbar,
          style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A2E)),
          onChanged: (val) {
            searchQuery.value = val;
            _matchCount.value = 0; // reset count on every keystroke
          },
          decoration: InputDecoration(
            hintText: 'Search dishes…',
            hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: searchQuery.value.isNotEmpty
                  ? _kPrimary
                  : const Color(0xFFBDBDBD),
            ),
            suffixIcon: searchQuery.value.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      dmc.searchbar.clear();
                      searchQuery.value = '';
                      _matchCount.value = 0;
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF9E9E9E),
                      size: 20,
                    ),
                  )
                : const Icon(
                    Icons.tune_rounded,
                    color: Color(0xFFBDBDBD),
                    size: 20,
                  ),
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_kRadius),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  // ── Category Chips ─────────────────────────────────────────────────────────

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 62,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Obx(() {
            final isSelected = selectedCategoryIndex.value == index;
            return GestureDetector(
              onTap: () => selectedCategoryIndex.value = index,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? _kPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? _kPrimary
                        : const Color(0xFFFFCDD2), // light rose border
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _kPrimary.withOpacity(0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF616161),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  // ── Empty & Loading ────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _kPrimary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                size: 48,
                color: _kPrimary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Dishes Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap ADD to start building\nyour menu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9E9E9E),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResult(String query) {
    return Container(
      color: const Color(0xFFF7F8FA),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF9E9E9E).withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Similar Item Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No dish matches "$query".\nTry a different keyword.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9E9E9E),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(child: CircularProgressIndicator(color: _kPrimary)),
    );
  }

  // ── Category filter logic (unchanged) ─────────────────────────────────────

  bool _matchesCategory(Map<String, dynamic> dish, String category) {
    if (category == 'All') return true;
    if (category == 'Active') return (dish['qnt_available'] ?? 0) > 0;
    if (category == 'Sold Out') return (dish['qnt_available'] ?? 0) == 0;
    return dish['category'] == category;
  }

  // ── Dish Card ──────────────────────────────────────────────────────────────

  Widget _buildDishCard(Map<String, dynamic> dish) {
    final bool isAvailable = (dish['qnt_available'] ?? 0) > 0;
    final bool isVeg = dish['preference'] != 'Non-Veg';
    final List images = dish['images'] ?? [];
    // Raw URL from Firebase — BunnyCdnImage handles auth & format internally
    final String? imageUrl = images.isNotEmpty ? images[0] as String : null;

    return Opacity(
      opacity: isAvailable ? 1.0 : 0.55,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_kRadius),
          boxShadow: _kCardShadow,
          // Subtle warm left-border accent
          border: Border(
            left: BorderSide(
              color: isAvailable ? _kPrimary : const Color(0xFFBDBDBD),
              width: 3.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Dish image ──
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(_kRadius),
                bottomLeft: Radius.circular(_kRadius),
              ),
              child: Stack(
                children: [
                  // ── Dish image (fetched with BunnyCDN API key) ──
                  BunnyCdnImage(
                    storageUrl: imageUrl,
                    width: 100,
                    height: 110,
                    placeholder: _imagePlaceholder,
                  ),

                  // Sold out overlay
                  if (!isAvailable)
                    Container(
                      width: 100,
                      height: 110,
                      color: Colors.black.withOpacity(0.35),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'SOLD OUT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Dish info ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + veg/non-veg indicator
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            dish['dish_name'] ?? 'N/A',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Color(0xFF1A1A2E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Veg / Non-veg dot badge
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isVeg
                                  ? const Color(0xFF43A047)
                                  : const Color(0xFFE53935),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: isVeg
                                  ? const Color(0xFF43A047)
                                  : const Color(0xFFE53935),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Text(
                      dish['description'] ?? '',
                      style: const TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Price + Qty row
                    Row(
                      children: [
                        // Price
                        Text(
                          '₹${dish['price'] ?? 0}',
                          style: const TextStyle(
                            color: _kPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        // Qty badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFCE4EC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 12,
                                color: isAvailable
                                    ? const Color(0xFF2E7D32)
                                    : _kPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${dish['qnt_available'] ?? 0}',
                                style: TextStyle(
                                  color: isAvailable
                                      ? const Color(0xFF2E7D32)
                                      : _kPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Edit button
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            dmc.dishnameController.text =
                                dish['dish_name'] ?? '';
                            dmc.dishDescription.text =
                                dish['description'] ?? '';
                            dmc.dishPrice.text =
                                dish['price']?.toString() ?? '';
                            dmc.selectedCategory.value = dish['category'] ?? '';
                            dmc.currentQuantity.value =
                                dish['qnt_available'] ?? 0;
                            dmc.selectedPreference.value =
                                dish['preference'] ?? '';
                            dmc.ingredientsList.value = List<String>.from(
                              dish['ingredients'] ?? [],
                            );
                            // Pass existing image URL so edit screen can show it
                            final List imgs = dish['images'] ?? [];
                            dmc.existingImageUrl.value = imgs.isNotEmpty
                                ? imgs[0] as String
                                : '';
                            Get.to(
                              () => AddDishScreen(),
                              arguments: [false, dish['dish_id']],
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF5F5), // soft rose tint
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFFCDD2), // rose border
                              ),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 16,
                              color: _kPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 100,
      height: 110,
      color: const Color(0xFFFFF5F5), // soft rose placeholder
      alignment: Alignment.center,
      child: const Icon(
        Icons.fastfood_rounded,
        color: Color(0xFFEF9A9A), // muted rose-red icon
        size: 34,
      ),
    );
  }
}
