<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Anggota;
use Illuminate\Http\Request;

class AnggotaController extends Controller
{
    /**
     * Menampilkan daftar semua anggota yang terdaftar dalam sistem.
     * 
     * @return \Illuminate\Http\JsonResponse Koleksi data anggota dalam format JSON.
     */
    public function index()
    {
        $anggotas = Anggota::all();
        return response()->json([
            'status' => 'success',
            'data'   => $anggotas
        ], 200);
    }

    /**
     * Mendaftarkan anggota baru ke dalam database.
     * 
     * @param Request $request Data input anggota (nama, email, no_hp, alamat, tgl_daftar, status).
     * @return \Illuminate\Http\JsonResponse Data anggota yang berhasil dibuat atau error validasi.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama'       => 'required|string|max:255',
            'email'      => 'required|email|unique:anggotas',
            'no_hp'      => 'required|string|max:15',
            'alamat'     => 'required|string',
            'tgl_daftar' => 'required|date',
            'status'     => 'in:aktif,nonaktif',
        ]);

        $anggota = Anggota::create($validated);

        return response()->json([
            'status' => 'success', 
            'data'   => $anggota
        ], 201);
    }

    /**
     * Menampilkan informasi detail dari satu anggota tertentu.
     * 
     * @param Anggota $anggota Model instance anggota.
     * @return \Illuminate\Http\JsonResponse Objek data anggota.
     */
    public function show(Anggota $anggota)
    {
        return response()->json([
            'status' => 'success', 
            'data'   => $anggota
        ], 200);
    }

    /**
     * Memperbarui informasi data anggota yang sudah terdaftar.
     * 
     * @param Request $request Data pembaruan anggota.
     * @param Anggota $anggota Model instance anggota yang akan diubah.
     * @return \Illuminate\Http\JsonResponse Objek data anggota setelah diperbarui.
     */
    public function update(Request $request, Anggota $anggota)
    {
        $anggota->update($request->all());

        return response()->json([
            'status' => 'success', 
            'data'   => $anggota
        ], 200);
    }

    /**
     * Menghapus data anggota dari sistem secara permanen.
     * 
     * @param Anggota $anggota Model instance anggota yang akan dihapus.
     * @return \Illuminate\Http\JsonResponse Pesan konfirmasi penghapusan.
     */
    public function destroy(Anggota $anggota)
    {
        $anggota->delete();

        return response()->json([
            'status'  => 'success', 
            'message' => 'Data anggota berhasil dihapus dari sistem'
        ], 200);
    }
}
