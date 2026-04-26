import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/data_providers.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class AnggotaScreen extends StatefulWidget {
  const AnggotaScreen({super.key});

  @override
  State<AnggotaScreen> createState() => _AnggotaScreenState();
}

class _AnggotaScreenState extends State<AnggotaScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnggotaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 Kelola Anggota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<AnggotaProvider>().fetchAnggotas(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context),
        backgroundColor: AppTheme.success,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Tambah Anggota',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                AppSearchBar(
                  hint: 'Cari nama, email, nomor HP...',
                  controller: _searchCtrl,
                  onChanged: (v) => context.read<AnggotaProvider>().setSearch(v),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      AppFilterChip(
                        label: 'Semua',
                        selected: provider._filterStatus.isEmpty,
                        onTap: () => context.read<AnggotaProvider>().setFilterStatus(''),
                      ),
                      AppFilterChip(
                        label: 'Aktif',
                        selected: provider._filterStatus == 'aktif',
                        onTap: () => context.read<AnggotaProvider>().setFilterStatus('aktif'),
                      ),
                      AppFilterChip(
                        label: 'Nonaktif',
                        selected: provider._filterStatus == 'nonaktif',
                        onTap: () => context.read<AnggotaProvider>().setFilterStatus('nonaktif'),
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
              color: const Color(0xFFDCFCE7),
              child: Row(
                children: [
                  Text('${provider.anggotas.length} anggota ditemukan',
                      style: const TextStyle(
                          color: AppTheme.success, fontSize: 12, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _searchCtrl.clear();
                      context.read<AnggotaProvider>().resetFilter();
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
                  onRetry: () => context.read<AnggotaProvider>().fetchAnggotas(),
                ),
              DataStatus.loaded when provider.anggotas.isEmpty => const EmptyState(
                  message: 'Tidak ada anggota ditemukan',
                  icon: Icons.people_outline_rounded,
                ),
              _ => AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: provider.anggotas.length,
                    itemBuilder: (ctx, i) => AnimationConfiguration.staggeredList(
                      position: i,
                      duration: const Duration(milliseconds: 400),
                      child: SlideAnimation(
                        verticalOffset: 30,
                        child: FadeInAnimation(
                          child: _AnggotaCard(
                            anggota: provider.anggotas[i],
                            onEdit: () => _showForm(context, anggota: provider.anggotas[i]),
                            onDelete: () async {
                              final ok = await showDeleteConfirm(
                                  context, '"${provider.anggotas[i].nama}"');
                              if (ok == true && context.mounted) {
                                await context.read<AnggotaProvider>().deleteAnggota(provider.anggotas[i].id);
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

  void _showForm(BuildContext context, {Anggota? anggota}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AnggotaFormSheet(anggota: anggota),
    );
  }
}

class _AnggotaCard extends StatelessWidget {
  final Anggota anggota;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AnggotaCard({required this.anggota, required this.onEdit, required this.onDelete});

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
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppTheme.success.withOpacity(0.12),
            child: Text(
              anggota.nama.isNotEmpty ? anggota.nama[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: AppTheme.success, fontWeight: FontWeight.w800, fontSize: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(anggota.nama,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(anggota.email,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    StatusBadge(status: anggota.status),
                    const SizedBox(width: 8),
                    if (anggota.noHp.isNotEmpty)
                      Text(anggota.noHp,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
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
                    backgroundColor: AppTheme.accentLight, padding: const EdgeInsets.all(8)),
              ),
              const SizedBox(height: 6),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_rounded, color: AppTheme.danger, size: 20),
                style: IconButton.styleFrom(
                    backgroundColor: AppTheme.danger.withOpacity(0.1),
                    padding: const EdgeInsets.all(8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Anggota Form Sheet ────────────────────────────────────────────────────────
class AnggotaFormSheet extends StatefulWidget {
  final Anggota? anggota;
  const AnggotaFormSheet({super.key, this.anggota});

  @override
  State<AnggotaFormSheet> createState() => _AnggotaFormSheetState();
}

class _AnggotaFormSheetState extends State<AnggotaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _noHpCtrl;
  late final TextEditingController _alamatCtrl;
  String _status = 'aktif';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.anggota?.nama);
    _emailCtrl = TextEditingController(text: widget.anggota?.email);
    _noHpCtrl = TextEditingController(text: widget.anggota?.noHp);
    _alamatCtrl = TextEditingController(text: widget.anggota?.alamat);
    _status = widget.anggota?.status ?? 'aktif';
  }

  @override
  void dispose() {
    _namaCtrl.dispose(); _emailCtrl.dispose(); _noHpCtrl.dispose(); _alamatCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final now = DateTime.now();
    final body = {
      'nama': _namaCtrl.text,
      'email': _emailCtrl.text,
      'no_hp': _noHpCtrl.text,
      'alamat': _alamatCtrl.text,
      'tgl_daftar': '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}',
      'status': _status,
    };
    bool ok;
    if (widget.anggota != null) {
      ok = await context.read<AnggotaProvider>().updateAnggota(widget.anggota!.id, body);
    } else {
      ok = await context.read<AnggotaProvider>().createAnggota(body);
    }
    setState(() => _loading = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Anggota berhasil ${widget.anggota != null ? 'diupdate' : 'ditambahkan'}!' : 'Gagal menyimpan'),
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
          color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              Text(widget.anggota != null ? 'Edit Anggota' : 'Tambah Anggota',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              _field('Nama Lengkap *', _namaCtrl, required: true),
              _field('Email *', _emailCtrl, type: TextInputType.emailAddress, required: true),
              _field('Nomor HP *', _noHpCtrl, type: TextInputType.phone, required: true),
              _field('Alamat *', _alamatCtrl, required: true),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['aktif', 'nonaktif']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                child: _loading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(widget.anggota != null ? 'Update Anggota' : 'Tambah Anggota'),
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

// expose _filterStatus for filter chips
extension on AnggotaProvider {
  String get _filterStatus => filterStatus;
}
