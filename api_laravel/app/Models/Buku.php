<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Buku extends Model
{
    use HasFactory;

    protected $fillable = [
        'judul',
        'pengarang',
        'penerbit',
        'tahun_terbit',
        'isbn',
        'stok',
        'kategori'
    ];

    // Relasi: satu buku bisa memiliki banyak peminjaman
    public function peminjamans()
    {
        return $this->hasMany(Peminjaman::class);
    }
}
