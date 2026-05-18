<?php

namespace App\Http\Requests\Auth;

use App\Models\User;
use Illuminate\Auth\Events\Lockout;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class LoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email' => ['required', 'string', 'email'],
            'password' => ['required', 'string'],
        ];
    }

    /**
     * Lógica de autenticación con bloqueo persistente, borrado lógico y auditoría.
     */
    public function authenticate(): void
    {
        $this->ensureIsNotRateLimited();

        // 1. Buscamos al usuario verificando que esté ACTIVO (Borrado Lógico) 
        /** @var User|null $user */
        $user = User::query()
            ->where('email', (string) $this->input('email'))
            ->where('activo', true) 
            ->first();

        // 2. Verificar si la cuenta está bloqueada temporalmente en PostgreSQL 
        if ($user && $user->bloqueado_hasta && now()->lessThan($user->bloqueado_hasta)) {
            $minutos = now()->diffInMinutes($user->bloqueado_hasta);
            throw ValidationException::withMessages([
                'email' => "Seguridad: Cuenta bloqueada. Intenta de nuevo en $minutos minutos.",
            ]);
        }

        // 3. Intentar el inicio de sesión
        if (! Auth::attempt($this->only('email', 'password'), $this->boolean('remember'))) {
            
            if ($user instanceof User) {
                // Incrementamos los intentos fallidos en la base de datos 
                $user->update([
                    'intentos_fallidos' => $user->intentos_fallidos + 1
                ]);

                // Bloqueo preventivo tras 5 intentos fallidos 
                if ($user->intentos_fallidos >= 5) {
                    $user->update([
                        'bloqueado_hasta' => now()->addMinutes(15),
                        'intentos_fallidos' => 0 
                    ]);

                    throw ValidationException::withMessages([
                        'email' => 'Demasiados intentos fallidos. Bloqueo de seguridad activado por 15 minutos.',
                    ]);
                }
            }

            RateLimiter::hit($this->throttleKey());

            // SUBSANADO: Mensaje explícito en español en lugar de trans('auth.failed')
            throw ValidationException::withMessages([
                'email' => 'El correo electrónico o la contraseña son incorrectos.',
            ]);
        }

        // 4. Éxito: Registro de Auditoría y limpieza de bloqueos
        if ($user instanceof User) {
            // Trazabilidad: Registrar quién, cuándo, IP/Navegador y acción
            DB::table('log_auditoria')->insert([
                'id_log' => (string) Str::uuid(),
                'id_usuario' => $user->id_usuario,
                'rol' => $user->id_rol,
                'fecha_hora' => now(), 
                'ip' => $this->ip(), 
                'navegador' => $this->header('User-Agent'), 
                'accion' => 'Inicio de sesión exitoso', 
            ]);

            $user->update([
                'intentos_fallidos' => 0,
                'bloqueado_hasta' => null
            ]);
        }

        RateLimiter::clear($this->throttleKey());
    }

    public function ensureIsNotRateLimited(): void
    {
        if (! RateLimiter::tooManyAttempts($this->throttleKey(), 5)) {
            return;
        }

        event(new Lockout($this));
        $seconds = RateLimiter::availableIn($this->throttleKey());

        // SUBSANADO: Traducido directamente aquí para evitar fallas del localizador
        throw ValidationException::withMessages([
            'email' => "Demasiados intentos de acceso. Por favor intente de nuevo en $seconds segundos.",
        ]);
    }

    public function throttleKey(): string
    {
        return Str::transliterate(Str::lower((string) $this->input('email')).'|'.$this->ip());
    }
}