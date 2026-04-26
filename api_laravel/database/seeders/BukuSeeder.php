<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Buku;

class BukuSeeder extends Seeder
{
    public function run(): void
    {
        $bukus = [
            [
                'judul' => 'Pemrograman Web dengan Laravel',
                'pengarang' => 'Ahmad Rizki',
                'penerbit' => 'Penerbit IT',
                'tahun_terbit' => 2022,
                'isbn' => '978-123-001',
                'stok' => 5,
                'kategori' => 'Teknologi'
            ],

            [
                'judul' => 'Belajar React.js Modern',
                'pengarang' => 'Siti Rahma',
                'penerbit' => 'CodeBook',
                'tahun_terbit' => 2023,
                'isbn' => '978-123-002',
                'stok' => 3,
                'kategori' => 'Teknologi'
            ],

            [
                'judul' => 'Database MySQL untuk Pemula',
                'pengarang' => 'Budi Santoso',
                'penerbit' => 'TechPress',
                'tahun_terbit' => 2021,
                'isbn' => '978-123-003',
                'stok' => 7,
                'kategori' => 'Database'
            ],
        ];

        foreach ($bukus as $buku) {
            Buku::create($buku);
        }
    }
}
