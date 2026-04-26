import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../providers/buku_provider.dart';
import '../providers/data_providers.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class PeminjamanScreen extends StatefulWidget {
  const PeminjamanScreen({super.key});

  @override
  State<PeminjamanScreen> createState() => _PeminjamanScreenState();
}

class _PeminjamanScreenState extends State<PeminjamanScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PeminjamanProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔖 Peminjaman'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<PeminjamanProvider>().fetchPeminjamans(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context),
        backgroundColor: AppTheme.warning,
        icon: const Icon(Icons.bookmark_add_rounded, color: Colors.white),
        label: const Text('Pinjam Buku',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Search & Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                AppSearchBar(
                  hint: 'Cari buku atau anggota...',
                  controller: _searchCtrl,
                  onChanged: (v) => context.read<PeminjamanProvider>().setSearch(v),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      AppFilterChip(
                        label: 'Semua',
                        selected: provider.filterStatus.isEmpty,
                        onTap: () => context.read<PeminjamanProvider>().setFilterStatus(''),
                      ),
                      AppFilterChip(
                        label: 'Dipinjam',
                        selected: provider.filterStatus == 'dipinjam',
                        onTap: () => context.read<PeminjamanProvider>().setFilterStatus('dipinjam'),
                      ),
                      AppFilterChip(
                        label: 'Dikembalikan',
                        selected: provider.filterStatus == 'dikembalikan',
                        onTap: () => context.read<PeminjamanProvider>().setFilterStatus('dikembalikan'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (provider.status == DataStatus.loaded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFFEF3C7),
              child: Row(
                children: [
                  Text('${provider.peminjamans.length} data ditemukan',
                      style: const TextStyle(
                          color: AppTheme.warning, fontSize: 12, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _searchCtrl.clear();
                      context.read<PeminjamanProvider>().resetFilter();
                    },
                    child: const Text('Reset', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

          Expanded(
            child: switch (provider.status) {
              DataStatus.loading => const LoadingList(),
              DataStatus.error => ErrorState(
                  message: provider.error ?? 'Terjadi kesalahan',
                  onRetry: () => context.read<PeminjamanProvider>().fetchPeminjamans(),
                ),
              DataStatus.loaded when provider.peminjamans.isEmpty => const EmptyState(
                  message: 'Tidak ada data peminjaman',
                  icon: Icons.bookmark_outline_rounded,
                ),
              _ => AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: provider.peminjamans.length,
                    itemBuilder: (ctx, i) => AnimationConfiguration.staggeredList(
                      position: i,
                      duration: const Duration(milliseconds: 400),
                      child: SlideAnimation(
                        verticalOffset: 30,
                        child: FadeInAnimation(
                          child: _PeminjamanCard(
                            peminjaman: provider.peminjamans[i],
                            onReturn: provider.peminjamans[i].status == 'dipinjam' 
                              ? () => _handleReturn(context, provider.peminjamans[i])
                              : null,
                            onDelete: () async {
                              final ok = await showDeleteConfirm(context, 'data peminjaman ini');
                              if (ok == true && context.mounted) {
                                await context.read<PeminjamanProvider>().deletePeminjaman(provider.peminjamans[i].id);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            },
          ),
        ],
      ),
    );
  }

  void _showForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PeminjamanFormSheet(),
    );
  }

  Future<void> _handleReturn(BuildContext context, Peminjaman p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kembalikan Buku'),
        content: Text('Konfirmasi pengembalian buku "${p.judulBuku}" oleh ${p.namaAnggota}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Kembalikan')),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final now = DateTime.now();
      final body = {
        'buku_id': p.bukuId,
        'anggota_id': p.anggotaId,
        'tgl_pinjam': p.tanggalPinjam,
        'tgl_kembali_rencana': p.tanggalKembaliRencana,
        'tgl_kembali_aktual': '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}',
        'status': 'dikembalikan',
      };
      final ok = await context.read<PeminjamanProvider>().updatePeminjaman(p.id, body);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Buku telah dikembalikan!' : 'Gagal memproses'),
          backgroundColor: ok ? AppTheme.success : AppTheme.danger,
        ));
      }
    }
  }
}

class _PeminjamanCard extends StatelessWidget {
  final Peminjaman peminjaman;
  final VoidCallback? onReturn;
  final VoidCallback onDelete;

  const _PeminjamanCard({required this.peminjaman, this.onReturn, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.bookmark_rounded, color: AppTheme.warning, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(peminjaman.judulBuku,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(peminjaman.namaAnggota,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    StatusBadge(status: peminjaman.status),
                  ],
                ),
              ),
              if (onReturn != null)
                IconButton(
                  onPressed: onReturn,
                  icon: const Icon(Icons.assignment_return_rounded, color: AppTheme.success),
                  tooltip: 'Kembalikan Buku',
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppTheme.border),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DateInfo('Pinjam', peminjaman.tanggalPinjam),
              _DateInfo('Rencana Kembali', peminjaman.tanggalKembaliRencana),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.danger, size: 20),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateInfo extends StatelessWidget {
  final String label;
  final String date;
  const _DateInfo(this.label, this.date);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
        Text(date, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
      ],
    );
  }
}

// ── Peminjaman Form Sheet ─────────────────────────────────────────────────────
class PeminjamanFormSheet extends StatefulWidget {
  const PeminjamanFormSheet({super.key});

  @override
  State<PeminjamanFormSheet> createState() => _PeminjamanFormSheetState();
}

class _PeminjamanFormSheetState extends State<PeminjamanFormSheet> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedBuku;
  int? _selectedAnggota;
  DateTime _returnDate = DateTime.now().add(const Duration(days: 7));
  bool _loading = false;

  Future<void> _submit() async {
    if (_selectedBuku == null || _selectedAnggota == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih buku dan anggota!')));
      return;
    }
    setState(() => _loading = true);
    final now = DateTime.now();
    final body = {
      'buku_id': _selectedBuku,
      'anggota_id': _selectedAnggota,
      'tgl_pinjam': '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}',
      'tgl_kembali_rencana': '${_returnDate.year}-${_returnDate.month.toString().padLeft(2,'0')}-${_returnDate.day.toString().padLeft(2,'0')}',
      'status': 'dipinjam',
    };
    final ok = await context.read<PeminjamanProvider>().createPeminjaman(body);
    setState(() => _loading = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Peminjaman berhasil dicatat!' : 'Gagal menyimpan'),
        backgroundColor: ok ? AppTheme.success : AppTheme.danger,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bukuList = context.watch<BukuProvider>().bukus;
    final anggotaList = context.watch<AnggotaProvider>().anggotas;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Pinjam Buku Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Pilih Buku'),
            items: bukuList.where((b) => b.stok > 0).map((b) => DropdownMenuItem(
              value: b.id, child: Text(b.judul, overflow: TextOverflow.ellipsis)
            )).toList(),
            onChanged: (v) => setState(() => _selectedBuku = v),
          ),
          const SizedBox(height: 14),
          
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Pilih Anggota'),
            items: anggotaList.where((a) => a.status == 'aktif').map((a) => DropdownMenuItem(
              value: a.id, child: Text(a.nama)
            )).toList(),
            onChanged: (v) => setState(() => _selectedAnggota = v),
          ),
          const SizedBox(height: 14),

          ListTile(
            title: const Text('Rencana Kembali', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text(DateFormat('EEEE, d MMM yyyy').format(_returnDate)),
            trailing: const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryLight),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _returnDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) setState(() => _returnDate = picked);
            },
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning),
            child: _loading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Proses Peminjaman'),
          ),
        ],
      ),
    );
  }
}
