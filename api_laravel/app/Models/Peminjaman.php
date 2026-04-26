<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Peminjaman extends Model
{
    use HasFactory;

    protected $table = 'peminjamans'; // ← tambahkan baris ini

    protected $fillable = [
        'buku_id',
        'anggota_id',
        'tgl_pinjam',
        'tgl_kembali_rencana',
        'tgl_kembali_aktual',
        'status'
    ];

    public function buku()
    {
        return $this->belongsTo(Buku::class);
    }

    public function anggota()
    {
        return $this->belongsTo(Anggota::class);
    }
}
