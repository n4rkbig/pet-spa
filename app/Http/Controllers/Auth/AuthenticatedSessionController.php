<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;     // Facade para Auditoría
use Illuminate\Support\Facades\Log;    // Facade para Logs del Sistema
use Illuminate\Support\Str;            // Para generar UUIDs de logs
use Illuminate\Validation\ValidationException;
use Inertia\Inertia;
use Inertia\Response;

class AuthenticatedSessionController extends Controller
{
    /**
     * Muestra la vista de login.
     */
    public function create(): Response
    {
        return Inertia::render('Auth/Login', [
            'canResetPassword' => Route::has('password.request'),
            'status' => session('status'),
        ]);
    }

    /**
     * Procesa la solicitud de autenticación.
     */
    public function store(LoginRequest $request): RedirectResponse
    {
        try {
            // 1. Validar credenciales y procesar la autenticación básica
            $request->authenticate();

        } catch (ValidationException $e) {
            // SUBSANADO: Captura el intento fallido (Fuerza bruta / Password errónea)
            // Buscamos si el correo existe para asociar el id en la auditoría, si no, se guarda como anónimo
            $attemptedUser = DB::table('usuario')->where('email', $request->email)->first();
            
            $this->registrarAuditoriaAnonima(
                $attemptedUser ? $attemptedUser->id_usuario : null,
                $attemptedUser ? $attemptedUser->id_rol : null,
                $request,
                "ALERTA: Intento fallido de inicio de sesión para el correo: {$request->email}"
            );

            // Re-lanzamos la excepción para que Laravel maneje el flujo normal de errores visuales
            throw $e;
        }

        // 2. VERIFICACIÓN DE SEGURIDAD: ¿La cuenta está activa? (Borrado Lógico)
        if (!Auth::user()->activo) {
            // Registramos el intento de acceso de cuenta suspendida en la auditoría
            $this->registrarAuditoria(Auth::user(), $request, 'ALERTA: Intento de acceso con CUENTA SUSPENDIDA');

            // Cerramos la sesión inmediatamente
            Auth::guard('web')->logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();

            // Retornamos con el mensaje de error específico
            return redirect()->route('login')->withErrors([
                'email' => 'Esta cuenta ha sido suspendida por el administrador. Contacte a soporte.',
            ]);
        }

        // 3. Regenerar sesión (Seguridad contra fijación de sesión)
        $request->session()->regenerate();

        // 4. REGISTRO DE AUDITORÍA: Inicio de sesión exitoso
        $this->registrarAuditoria(Auth::user(), $request, 'INGRESO: Inicio de sesión exitoso');

        // 5. Redirección al Dashboard
        return redirect()->intended(route('dashboard', absolute: false));
    }

    /**
     * Cierra la sesión del usuario.
     */
    public function destroy(Request $request): RedirectResponse
    {
        if (Auth::check()) {
            $this->registrarAuditoria(Auth::user(), $request, 'EGRESO: Cierre de sesión');
        }

        Auth::guard('web')->logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect('/');
    }

    /**
     * Función privada para centralizar la lógica de Auditoría (Usuarios Autenticados).
     */
    private function registrarAuditoria($user, Request $request, $accion)
    {
        try {
            DB::table('log_auditoria')->insert([
                'id_log' => (string) Str::uuid(),
                'id_usuario' => $user->id_usuario,
                'rol' => $user->id_rol,
                'fecha_hora' => now(),
                'ip' => $request->ip(),
                'navegador' => $request->userAgent(),
                'accion' => $accion
            ]);
        } catch (\Exception $e) {
            Log::error("Error en Auditoría ($accion): " . $e->getMessage());
        }
    }

    /**
     * SUBSANADO: Función auxiliar para registrar auditorías de usuarios no autenticados o fallidos.
     */
    private function registrarAuditoriaAnonima($idUsuario, $idRol, Request $request, $accion)
    {
        try {
            DB::table('log_auditoria')->insert([
                'id_log' => (string) Str::uuid(),
                'id_usuario' => $idUsuario, // Será null si el email ingresado no existe en la DB
                'rol' => $idRol,            // Será null si el email ingresado no existe en la DB
                'fecha_hora' => now(),
                'ip' => $request->ip(),
                'navegador' => $request->userAgent(),
                'accion' => $accion
            ]);
        } catch (\Exception $e) {
            Log::error("Error en Auditoría Anónima ($accion): " . $e->getMessage());
        }
    }
}