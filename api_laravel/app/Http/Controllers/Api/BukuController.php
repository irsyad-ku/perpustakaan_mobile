<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Buku;
use Illuminate\Http\Request;

class BukuController extends Controller
{

    /**
     * Menampilkan daftar semua buku yang tersedia di perpustakaan.
     * 
     * @return \Illuminate\Http\JsonResponse Koleksi data buku dalam format JSON.
     */
    public function index()
    {
        $bukus = Buku::all();
        return response()->json([
            'status' => 'success',
            'data'   => $bukus
        ], 200);
    }

    /**
     * Menyimpan data buku baru ke dalam database.
     * 
     * @param Request $request Data input buku (judul, pengarang, penerbit, tahun_terbit, isbn, stok, kategori).
     * @return \Illuminate\Http\JsonResponse Data buku yang berhasil dibuat atau error validasi.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'judul'        => 'required|string|max:255',
            'pengarang'    => 'required|string|max:255',
            'penerbit'     => 'required|string|max:255',
            'tahun_terbit' => 'required|integer',
            'isbn'         => 'required|unique:bukus|max:20',
            'stok'         => 'required|integer|min:0',
            'kategori'     => 'required|string',
        ]);

        $buku = Buku::create($validated);
        
        return response()->json([
            'status' => 'success', 
            'data'   => $buku
        ], 201);
    }

    /**
     * Menampilkan detail informasi dari satu buku tertentu.
     * 
     * @param Buku $buku Model instance buku (menggunakan Route Model Binding).
     * @return \Illuminate\Http\JsonResponse Objek data buku tunggal.
     */
    public function show(Buku $buku)
    {
        return response()->json([
            'status' => 'success', 
            'data'   => $buku
        ], 200);
    }

    /**
     * Memperbarui informasi data buku yang sudah ada.
     * 
     * @param Request $request Data pembaruan buku.
     * @param Buku $buku Model instance buku yang akan diubah.
     * @return \Illuminate\Http\JsonResponse Objek data buku setelah diperbarui.
     */
    public function update(Request $request, Buku $buku)
    {
        // Melakukan update secara massal berdasarkan payload request yang diterima
        $buku->update($request->all());

        return response()->json([
            'status' => 'success', 
            'data'   => $buku
        ], 200);
    }

    /**
     * Menghapus data buku dari sistem secara permanen.
     * 
     * @param Buku $buku Model instance buku yang akan dihapus.
     * @return \Illuminate\Http\JsonResponse Pesan konfirmasi penghapusan.
     */
    public function destroy(Buku $buku)
    {
        $buku->delete();

        return response()->json([
            'status'  => 'success', 
            'message' => 'Buku berhasil dihapus dari sistem'
        ], 200);
    }
}
