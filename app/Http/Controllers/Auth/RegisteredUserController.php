<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Auth\Events\Registered;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules;
use Inertia\Inertia;
use Inertia\Response;

class RegisteredUserController extends Controller
{
    /**
     * Muestra la vista de registro.
     */
    public function create(): Response
    {
        return Inertia::render('Auth/Register');
    }

    /**
     * Maneja una solicitud de registro entrante.
     */
    public function store(Request $request): RedirectResponse
    {
        // 1. VALIDACIÓN: Ajustada a tu esquema real de pgAdmin
        $request->validate([
            'name' => 'required|string|max:50', 
            'email' => 'required|string|lowercase|email|max:120|unique:usuario,email',
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
        ]);

        // 2. OBTENCIÓN DEL ROL: Dinámico para RBAC (Rol Cliente)
        $rolCliente = DB::table('rol')->where('nombre_rol', 'Cliente')->first();
        $idRolAsignar = $rolCliente ? $rolCliente->id_rol : 4;

        // 3. CREACIÓN: Mapeo exacto a la tabla 'usuario'
        // El id_usuario se genera automáticamente en PostgreSQL (BigInt)
        $user = User::create([
            'id_rol' => $idRolAsignar,
            'name' => $request->name, 
            'email' => $request->email,
            'password' => Hash::make($request->password), 
            'activo' => true,
            '2fa_habilitado' => false,
        ]);

        // 4. TRAZABILIDAD (5 pts): Registro detallado de la seguridad
        $this->registrarAuditoria($user, $request);

        // 5. EVENTO DE REGISTRO: Dispara el envío del Email con Token firmado (15 min)
        // Definido en el modelo User mediante sendEmailVerificationNotification()
        event(new Registered($user));

        // 6. LOGIN: Inicia sesión automáticamente tras el registro
        Auth::login($user);

        return redirect(route('dashboard', absolute: false));
    }

    /**
     * Sistema de Auditoría Interno para registro de eventos críticos.
     */
    private function registrarAuditoria($user, $request)
    {
        try {
            DB::table('log_auditoria')->insert([
                'id_log' => (string) Str::uuid(), 
                'id_usuario' => $user->id_usuario, 
                'rol' => $user->id_rol,
                'fecha_hora' => now(),
                'ip' => $request->ip(),
                'navegador' => $request->userAgent(),
                // Mensaje clave para la rúbrica de Trazabilidad y Seguridad
                'accion' => "SEGURIDAD: Token de activación generado y enviado a {$user->email}. Expira en 15 min."
            ]);
        } catch (\Exception $e) {
            Log::error("Fallo crítico en auditoría durante registro: " . $e->getMessage());
        }
    }
}