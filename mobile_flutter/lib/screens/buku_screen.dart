import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/buku_provider.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class BukuScreen extends StatefulWidget {
  const BukuScreen({super.key});

  @override
  State<BukuScreen> createState() => _BukuScreenState();
}

class _BukuScreenState extends State<BukuScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BukuProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Koleksi Buku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<BukuProvider>().fetchBukus(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context),
        backgroundColor: AppTheme.primaryLight,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Buku', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
                  hint: 'Cari judul, pengarang, ISBN...',
                  controller: _searchCtrl,
                  onChanged: (v) => context.read<BukuProvider>().setSearch(v),
                ),
                if (provider.kategoriList.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        AppFilterChip(
                          label: 'Semua',
                          selected: provider.filterKategori.isEmpty,
                          onTap: () {
                            context.read<BukuProvider>().setKategori('');
                          },
                        ),
                        ...provider.kategoriList.map((k) => AppFilterChip(
                              label: k,
                              selected: provider.filterKategori == k,
                              onTap: () => context.read<BukuProvider>().setKategori(k),
                            )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Info bar
          if (provider.status == DataStatus.loaded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.accentLight,
              child: Row(
                children: [
                  Text(
                    '${provider.bukus.length} buku ditemukan',
                    style: const TextStyle(
                        color: AppTheme.primaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (provider.search.isNotEmpty || provider.filterKategori.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        _searchCtrl.clear();
                        context.read<BukuProvider>().resetFilter();
                      },
                      child: const Text('Reset', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: switch (provider.status) {
              DataStatus.loading => const LoadingList(),
              DataStatus.error => ErrorState(
                  message: provider.error ?? 'Terjadi kesalahan',
                  onRetry: () => context.read<BukuProvider>().fetchBukus(),
                ),
              DataStatus.loaded when provider.bukus.isEmpty => const EmptyState(
                  message: 'Tidak ada buku ditemukan',
                  icon: Icons.menu_book_outlined,
                ),
              _ => AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: provider.bukus.length,
                    itemBuilder: (ctx, i) => AnimationConfiguration.staggeredList(
                      position: i,
                      duration: const Duration(milliseconds: 400),
                      child: SlideAnimation(
                        verticalOffset: 30,
                        child: FadeInAnimation(
                          child: _BukuCard(
                            buku: provider.bukus[i],
                            onEdit: () => _showForm(context, buku: provider.bukus[i]),
                            onDelete: () async {
                              final ok = await showDeleteConfirm(
                                  context, '"${provider.bukus[i].judul}"');
                              if (ok == true && context.mounted) {
                                await context.read<BukuProvider>().deleteBuku(provider.bukus[i].id);
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

  void _showForm(BuildContext context, {Buku? buku}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BukuFormSheet(buku: buku),
    );
  }
}

class _BukuCard extends StatelessWidget {
  final Buku buku;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BukuCard({required this.buku, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.accentLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: AppTheme.primaryLight, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(buku.judul,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(buku.pengarang,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (buku.kategori.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accentLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(buku.kategori,
                            style: const TextStyle(
                                color: AppTheme.primaryLight,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    const SizedBox(width: 8),
                    Text('Stok: ${buku.stok}',
                        style: TextStyle(
                            color: buku.stok > 0 ? AppTheme.success : AppTheme.danger,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, color: AppTheme.primaryLight, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.accentLight,
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(height: 6),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_rounded, color: AppTheme.danger, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.danger.withOpacity(0.1),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Buku Form Sheet ───────────────────────────────────────────────────────────
class BukuFormSheet extends StatefulWidget {
  final Buku? buku;

  const BukuFormSheet({super.key, this.buku});

  @override
  State<BukuFormSheet> createState() => _BukuFormSheetState();
}

class _BukuFormSheetState extends State<BukuFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulCtrl;
  late final TextEditingController _pengarangCtrl;
  late final TextEditingController _penerbitCtrl;
  late final TextEditingController _tahunCtrl;
  late final TextEditingController _isbnCtrl;
  late final TextEditingController _stokCtrl;
  late final TextEditingController _kategoriCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _judulCtrl = TextEditingController(text: widget.buku?.judul);
    _pengarangCtrl = TextEditingController(text: widget.buku?.pengarang);
    _penerbitCtrl = TextEditingController(text: widget.buku?.penerbit);
    _tahunCtrl = TextEditingController(text: widget.buku?.tahunTerbit);
    _isbnCtrl = TextEditingController(text: widget.buku?.isbn);
    _stokCtrl = TextEditingController(text: widget.buku?.stok.toString() ?? '1');
    _kategoriCtrl = TextEditingController(text: widget.buku?.kategori);
  }

  @override
  void dispose() {
    _judulCtrl.dispose(); _pengarangCtrl.dispose(); _penerbitCtrl.dispose();
    _tahunCtrl.dispose(); _isbnCtrl.dispose(); _stokCtrl.dispose(); _kategoriCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final body = {
      'judul': _judulCtrl.text,
      'pengarang': _pengarangCtrl.text,
      'penerbit': _penerbitCtrl.text,
      'tahun_terbit': _tahunCtrl.text,
      'isbn': _isbnCtrl.text,
      'stok': int.tryParse(_stokCtrl.text) ?? 1,
      'kategori': _kategoriCtrl.text,
    };
    bool ok;
    if (widget.buku != null) {
      ok = await context.read<BukuProvider>().updateBuku(widget.buku!.id, body);
    } else {
      ok = await context.read<BukuProvider>().createBuku(body);
    }
    setState(() => _loading = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Buku berhasil ${widget.buku != null ? 'diupdate' : 'ditambahkan'}!' : 'Gagal menyimpan buku'),
        backgroundColor: ok ? AppTheme.success : AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(widget.buku != null ? 'Edit Buku' : 'Tambah Buku',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              _field('Judul Buku *', _judulCtrl, required: true),
              _field('Pengarang *', _pengarangCtrl, required: true),
              _field('Penerbit', _penerbitCtrl),
              _field('Tahun Terbit', _tahunCtrl, type: TextInputType.number),
              _field('ISBN', _isbnCtrl),
              _field('Stok *', _stokCtrl, type: TextInputType.number, required: true),
              _field('Kategori', _kategoriCtrl),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(widget.buku != null ? 'Update Buku' : 'Tambah Buku'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType type = TextInputType.text, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(labelText: label),
        validator: required ? (v) => v?.isEmpty == true ? '$label wajib diisi' : null : null,
      ),
    );
  }
}
