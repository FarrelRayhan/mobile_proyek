// home_screen.dart - FIXED OVERFLOW VERSION
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../app_state.dart';
import '../models.dart';
import '../widgets.dart';
import 'product_detail_screen.dart';
import 'other_screens.dart';
import 'rental_screen.dart';
import 'buy_only_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 900) {
      return 4;
    } else if (width > 600) {
      return 3;
    } else {
      return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final products = state.filteredProducts;
    final user = state.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          // HEADER
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.bgGradientStart, AppTheme.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, ${user?.name.split(' ').first ?? 'Pengguna'} 👋',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Mau belanja apa hari ini?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          )
                        ],
                      ),
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(user?.avatarUrl ?? ''),
                        backgroundColor: Colors.white24,
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppSearchBar(
                    controller: _searchCtrl,
                    onChanged: (q) => state.setSearchQuery(q),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.inventory_2_outlined,
                        label: '${state.products.length}+ Produk',
                      ),
                      const SizedBox(width: 10),
                      _StatChip(
                        icon: Icons.article_outlined,
                        label: 'Artikel',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ArticleScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _StatChip(
                        icon: Icons.cabin_outlined,
                        label: 'Sewa',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RentalScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _StatChip(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Beli',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BuyOnlyScreen(),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // BANNER FIX: height 160
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF44A39E)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white10,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Petualangan Menantimu 🏕️',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Siap untuk petualangan outdoor? Temukan peralatan camping & hiking terbaik!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            state.setSearchQuery('');
                            state.setCategory('Semua');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Mulai Belanja →',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          // KATEGORI
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: SectionHeader(title: 'Kategori'),
                ),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => CategoryChip(
                      label: state.categories[i],
                      isSelected: state.selectedCategory == state.categories[i],
                      onTap: () => state.setCategory(state.categories[i]),
                    ),
                  ),
                )
              ],
            ),
          ),

          // REKOMENDASI
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: SectionHeader(title: 'Rekomendasi Untukmu'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final product = products[i];
                  return ProductCard(
                    product: product,
                    isFavorite: state.isFavorite(product.id),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    ),
                    onFavorite: () => state.toggleFavorite(product),
                    onAddToCart: () => state.addToCart(product),
                    productMode: '',
                  );
                },
                childCount: products.length > 4 ? 4 : products.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.68,
              ),
            ),
          ),

          // POPULER
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: SectionHeader(title: 'Produk Populer'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final product = products[products.length - 1 - i];
                  return ProductCard(
                    product: product,
                    isFavorite: state.isFavorite(product.id),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    ),
                    onFavorite: () => state.toggleFavorite(product),
                    onAddToCart: () => state.addToCart(product),
                    productMode: '',
                  );
                },
                childCount: products.length > 4 ? 4 : products.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.68,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: SectionHeader(
                title: products.isEmpty
                    ? 'Produk'
                    : '${products.length} Produk Campuran',
              ),
            ),
          ),

          products.isEmpty
              ? SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Produk Tidak Ditemukan',
                    subtitle: 'Coba kata kunci lain',
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final product = products[i];
                        return ProductCard(
                          product: product,
                          isFavorite: state.isFavorite(product.id),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(product: product),
                            ),
                          ),
                          onFavorite: () => state.toggleFavorite(product),
                          onAddToCart: () => state.addToCart(product),
                          productMode: '',
                        );
                      },
                      childCount: products.length,
                    ),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(context),
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.68,
                    ),
                  ),
                )
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _StatChip({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
