<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Si existe 'users' pero no 'usuario', la renombramos
        if (Schema::hasTable('users') && !Schema::hasTable('usuario')) {
            Schema::rename('users', 'usuario');
        }

        // 2. Ahora sí alteramos la tabla 'usuario'
        Schema::table('usuario', function (Blueprint $table) {
            if (!Schema::hasColumn('usuario', '2fa_secreto')) {
                $table->text('2fa_secreto')->nullable();
            }
            
            if (!Schema::hasColumn('usuario', 'activo')) {
                $table->boolean('activo')->default(true);
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('usuario', function (Blueprint $table) {
            //
        });
    }
};
