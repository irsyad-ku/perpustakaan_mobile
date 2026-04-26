import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/buku_provider.dart';
import '../providers/data_providers.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';
import 'buku_screen.dart';
import 'anggota_screen.dart';
import 'peminjaman_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _DashboardTab(),
    BukuScreen(),
    AnggotaScreen(),
    PeminjamanScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BukuProvider>().fetchBukus();
      context.read<AnggotaProvider>().fetchAnggotas();
      context.read<PeminjamanProvider>().fetchPeminjamans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.accentLight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primaryLight),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded, color: AppTheme.primaryLight),
            label: 'Buku',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded, color: AppTheme.primaryLight),
            label: 'Anggota',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded, color: AppTheme.primaryLight),
            label: 'Peminjaman',
          ),
        ],
      ),
    );
  }
}

// ── Dashboard Tab ─────────────────────────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final buku = context.watch<BukuProvider>();
    final anggota = context.watch<AnggotaProvider>();
    final peminjaman = context.watch<PeminjamanProvider>();

    final totalBuku = buku.status == DataStatus.loaded ? buku.bukus.length : 0;
    final totalAnggota = anggota.status == DataStatus.loaded ? anggota.anggotas.length : 0;
    final totalAktif = peminjaman.status == DataStatus.loaded
        ? peminjaman.allPeminjamans.where((p) => p.status == 'dipinjam').length
        : 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primary, Color(0xFF1D4ED8)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'assets/logo.png',
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Perpustakaan Digital',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800)),
                                  Text(
                                    'Halo, ${auth.userName ?? 'Pengguna'}! 👋',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)),
                                    title: const Text('Logout'),
                                    content: const Text('Yakin ingin keluar?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('Batal')),
                                      ElevatedButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Logout')),
                                    ],
                                  ),
                                );
                                if (confirm == true && context.mounted) {
                                  context.read<AuthProvider>().logout();
                                }
                              },
                              icon: const Icon(Icons.logout_rounded, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Statistik',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),

                  // Stats Grid
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                    children: [
                      StatCard(
                        label: 'Total Buku',
                        value: '$totalBuku',
                        icon: Icons.menu_book_rounded,
                        color: AppTheme.primaryLight,
                      ),
                      StatCard(
                        label: 'Anggota',
                        value: '$totalAnggota',
                        icon: Icons.people_rounded,
                        color: AppTheme.success,
                      ),
                      StatCard(
                        label: 'Aktif',
                        value: '$totalAktif',
                        icon: Icons.bookmark_rounded,
                        color: AppTheme.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Menu Grid
                  const Text('Menu',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _MenuCard(
                        label: 'Kelola Buku',
                        subtitle: '$totalBuku buku tersedia',
                        icon: Icons.menu_book_rounded,
                        color: AppTheme.primaryLight,
                        onTap: () {},
                      ),
                      _MenuCard(
                        label: 'Kelola Anggota',
                        subtitle: '$totalAnggota anggota',
                        icon: Icons.people_rounded,
                        color: AppTheme.success,
                        onTap: () {},
                      ),
                      _MenuCard(
                        label: 'Peminjaman',
                        subtitle: '$totalAktif sedang dipinjam',
                        icon: Icons.bookmark_rounded,
                        color: AppTheme.warning,
                        onTap: () {},
                      ),
                      _MenuCard(
                        label: 'Laporan',
                        subtitle: 'Ringkasan data',
                        icon: Icons.bar_chart_rounded,
                        color: const Color(0xFF8B5CF6),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Peminjaman
                  const Text('Peminjaman Terbaru',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),

                  if (peminjaman.status == DataStatus.loading)
                    const ShimmerCard()
                  else if (peminjaman.allPeminjamans.isEmpty)
                    const EmptyState(
                        message: 'Belum ada data peminjaman',
                        icon: Icons.bookmark_outline_rounded)
                  else
                    ...peminjaman.allPeminjamans.take(3).map((p) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.bookmark_rounded,
                                    color: AppTheme.primaryLight, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.judulBuku,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    Text(p.namaAnggota,
                                        style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                              StatusBadge(status: p.status),
                            ],
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.textPrimary)),
            Text(subtitle,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
