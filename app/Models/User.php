<?php

namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Auth\Notifications\VerifyEmail;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\URL;

class User extends Authenticatable implements MustVerifyEmail
{
    use HasFactory, Notifiable;

    /**
     * Tabla asociada en PostgreSQL.
     */
    protected $table = 'usuario'; 

    /**
     * Llave primaria personalizada.
     */
    protected $primaryKey = 'id_usuario'; 

    /**
     * CONFIGURACIÓN CRÍTICA: 
     * Como tu DB usa bigint con secuencia (nextval), habilitamos el incremento.
     */
    public $incrementing = true; 
    protected $keyType = 'int';

    /**
     * Campos habilitados para asignación masiva.
     */
    protected $fillable = [
        'id_rol',
        'name', 
        'email',
        'password',
        '2fa_habilitado',
        '2fa_secreto', 
        'intentos_fallidos',
        'bloqueado_hasta',
        'activo', 
    ];

    /**
     * Campos que deben ocultarse en serialización.
     */
    protected $hidden = [
        'password',
        'remember_token',
        '2fa_secreto',
    ];

    /**
     * Habilitamos timestamps para la trazabilidad de auditoría.
     */
    public $timestamps = true;

    protected static function boot()
    {
        parent::boot();
        
        static::creating(function ($model) {
            // Aseguramos que el estado activo sea true por defecto al crear
            if (!isset($model->activo)) {
                $model->activo = true;
            }
        });
    }

    /**
     * Sobrescribe el envío de notificación para aplicar la expiración de 15 min.
     * REQUERIMIENTO: Verificación y Tokens (Expiración real).
     */
    public function sendEmailVerificationNotification()
    {
        $verificationUrl = URL::temporarySignedRoute(
            'verification.verify',
            Carbon::now()->addMinutes(15), // Expiración de 15 minutos exactos
            [
                'id' => $this->getKey(),
                'hash' => sha1($this->getEmailForVerification()),
            ]
        );

        $this->notify(new VerifyEmail($verificationUrl));
    }

    /**
     * Borrado Lógico: El usuario se marca como inactivo (Requerimiento Persistencia).
     */
    public function eliminarLogico(): bool
    {
        return $this->update(['activo' => false]);
    }

    /**
     * Laravel busca por defecto la columna 'password'. 
     * Al llamarse así en tu DB, este método asegura la compatibilidad.
     */
    public function getAuthPassword()
    {
        return $this->password;
    }

    /**
     * Casts para asegurar que los tipos de datos sean manejados correctamente por Eloquent.
     */
    protected function casts(): array
    {
        return [
            'password' => 'hashed', 
            '2fa_habilitado' => 'boolean',
            'bloqueado_hasta' => 'datetime',
            'intentos_fallidos' => 'integer',
            'activo' => 'boolean',
            'email_verified_at' => 'datetime',
        ];
    }
}