import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/theme.dart';

// ── Loading Shimmer ──────────────────────────────────────────────────────────
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class LoadingList extends StatelessWidget {
  const LoadingList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) => const ShimmerCard(),
    );
  }
}

// ── Error State ──────────────────────────────────────────────────────────────
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 48, color: AppTheme.danger),
            ),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({super.key, required this.message, this.icon = Icons.inbox_rounded});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.accentLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 52, color: AppTheme.primaryLight),
            ),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ── Search Bar ───────────────────────────────────────────────────────────────
class AppSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
        suffixIcon: controller?.text.isNotEmpty == true
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, color: AppTheme.textSecondary),
                onPressed: () {
                  controller?.clear();
                  onChanged('');
                },
              )
            : null,
      ),
    );
  }
}

// ── Status Badge ─────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case 'aktif':
        bg = AppTheme.success.withOpacity(0.12);
        fg = AppTheme.success;
        label = 'Aktif';
        break;
      case 'nonaktif':
        bg = AppTheme.danger.withOpacity(0.12);
        fg = AppTheme.danger;
        label = 'Nonaktif';
        break;
      case 'dipinjam':
        bg = AppTheme.warning.withOpacity(0.12);
        fg = AppTheme.warning;
        label = 'Dipinjam';
        break;
      case 'dikembalikan':
        bg = AppTheme.success.withOpacity(0.12);
        fg = AppTheme.success;
        label = 'Dikembalikan';
        break;
      default:
        bg = AppTheme.accentLight;
        fg = AppTheme.primaryLight;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

// ── Confirm Delete Dialog ────────────────────────────────────────────────────
Future<bool?> showDeleteConfirm(BuildContext context, String item) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Konfirmasi Hapus'),
      content: Text('Yakin ingin menghapus $item?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
}

// ── Stat Card ────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12), // Dikurangi dari 16
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // Tambahan agar ke tengah
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Dikurangi dari 10
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18), // Dikurangi dari 22
          ),
          const SizedBox(height: 8), // Dikurangi dari 12
          FittedBox( // Tambahan agar teks mengecil otomatis jika sempit
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          ),
          const SizedBox(height: 2),
          Text(label,
              maxLines: 1, // Tambahan
              overflow: TextOverflow.ellipsis, // Tambahan
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10, // Dikurangi dari 12
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Filter Chip ──────────────────────────────────────────────────────────────
class AppFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppTheme.primaryLight : AppTheme.border),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: selected ? Colors.white : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
