<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Anggota extends Model
{
    use HasFactory;

    protected $fillable = [
        'nama',
        'email',
        'no_hp',
        'alamat',
        'tgl_daftar',
        'status'
    ];

    // Relasi: satu anggota bisa memiliki banyak peminjaman
    public function peminjamans()
    {
        return $this->hasMany(Peminjaman::class);
    }
}
