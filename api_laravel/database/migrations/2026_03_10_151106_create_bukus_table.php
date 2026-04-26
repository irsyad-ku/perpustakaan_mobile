<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('bukus', function (Blueprint $table) {
            $table->id();
            $table->string('judul');
            $table->string('pengarang');
            $table->string('penerbit');
            $table->year('tahun_terbit');
            $table->string('isbn', 20)->unique();
            $table->integer('stok')->default(1);
            $table->string('kategori');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bukus');
    }
};
