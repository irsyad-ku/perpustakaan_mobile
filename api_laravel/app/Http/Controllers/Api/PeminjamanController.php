<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Peminjaman;
use Illuminate\Http\Request;

class PeminjamanController extends Controller
{
    /**
     * Menampilkan daftar semua transaksi peminjaman beserta relasi buku dan anggota.
     * 
     * @return \Illuminate\Http\JsonResponse Koleksi data peminjaman dalam format JSON.
     */
    public function index()
    {
        // Menggunakan Eager Loading untuk memuat data buku dan anggota guna menghindari N+1 query problem
        $peminjamans = Peminjaman::with(['buku', 'anggota'])->get();

        return response()->json([
            'status' => 'success',
            'data'   => $peminjamans
        ], 200);
    }

    /**
     * Mencatat transaksi peminjaman buku baru.
     * 
     * @param Request $request Data input transaksi (buku_id, anggota_id, tgl_pinjam, tgl_kembali_rencana, status).
     * @return \Illuminate\Http\JsonResponse Data peminjaman yang berhasil dibuat atau error validasi.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'buku_id'              => 'required|exists:bukus,id',
            'anggota_id'           => 'required|exists:anggotas,id',
            'tgl_pinjam'           => 'required|date',
            'tgl_kembali_rencana'  => 'required|date',
            'status'               => 'in:dipinjam,dikembalikan',
        ]);

        $peminjaman = Peminjaman::create($validated);

        return response()->json([
            'status' => 'success', 
            'data'   => $peminjaman
        ], 201);
    }

    /**
     * Menampilkan detail informasi dari satu transaksi peminjaman.
     * 
     * @param Peminjaman $peminjaman Model instance peminjaman.
     * @return \Illuminate\Http\JsonResponse Objek data peminjaman beserta detail buku dan anggota.
     */
    public function show(Peminjaman $peminjaman)
    {
        return response()->json([
            'status' => 'success', 
            'data'   => $peminjaman->load(['buku', 'anggota'])
        ], 200);
    }

    /**
     * Memperbarui status atau data transaksi peminjaman.
     * 
     * @param Request $request Data pembaruan transaksi (misal: tgl_kembali_aktual atau status).
     * @param Peminjaman $peminjaman Model instance peminjaman yang akan diubah.
     * @return \Illuminate\Http\JsonResponse Objek data peminjaman setelah diperbarui.
     */
    public function update(Request $request, Peminjaman $peminjaman)
    {
        $peminjaman->update($request->all());

        return response()->json([
            'status' => 'success', 
            'data'   => $peminjaman
        ], 200);
    }

    /**
     * Menghapus catatan transaksi peminjaman dari sistem.
     * 
     * @param Peminjaman $peminjaman Model instance peminjaman yang akan dihapus.
     * @return \Illuminate\Http\JsonResponse Pesan konfirmasi penghapusan.
     */
    public function destroy(Peminjaman $peminjaman)
    {
        $peminjaman->delete();

        return response()->json([
            'status'  => 'success', 
            'message' => 'Catatan peminjaman berhasil dihapus'
        ], 200);
    }
}
