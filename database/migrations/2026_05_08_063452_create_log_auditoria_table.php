<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Implementación de trazabilidad completa según requerimientos de auditoría.
     */
    public function up(): void
    {
        Schema::create('log_auditoria', function (Blueprint $table) {
            // ID único del log (usamos UUID para mayor seguridad)
            $table->uuid('id_log')->primary();
            
            // ¿Quién? - Relación con el usuario y su rol
            $table->uuid('id_usuario')->nullable(); 
            $table->string('rol')->nullable();
            
            // ¿Cuándo? - Marca de tiempo exacta
            $table->timestamp('fecha_hora')->useCurrent();
            
            // ¿Desde dónde? - Datos de red y dispositivo
            $table->ipAddress('ip');
            $table->text('navegador');
            
            // ¿Qué hizo? - Descripción de la acción realizada
            $table->string('accion');

            // Índices para mejorar la velocidad de las auditorías
            $table->index(['id_usuario', 'fecha_hora']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('log_auditoria');
    }
};