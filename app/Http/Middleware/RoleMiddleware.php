<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    /**
     * Maneja el acceso basado en roles y registra auditoría de denegación.
     */
    public function handle(Request $request, \Closure $next, ...$roles): Response
    {
        // 1. Verificar si el usuario está autenticado y si su rol está permitido [cite: 6, 8]
        if (!Auth::check() || !in_array((string)Auth::user()->id_rol, $roles)) {
            
            // 2. Trazabilidad: Registrar el intento de acceso no autorizado (SEG-05) [cite: 34, 41]
            DB::table('log_auditoria')->insert([
                'id_log' => (string) Str::uuid(),
                'id_usuario' => Auth::check() ? Auth::user()->id_usuario : null,
                'rol' => Auth::check() ? Auth::user()->id_rol : 'Invitado',
                'fecha_hora' => now(), // ¿Cuándo? [cite: 37]
                'ip' => $request->ip(), // ¿Desde dónde? [cite: 39]
                'navegador' => $request->header('User-Agent'), // ¿Desde dónde? [cite: 39]
                'accion' => 'ACCESO DENEGADO: Intento de entrar a ruta restringida (' . $request->path() . ')', // ¿Qué hizo? [cite: 41]
            ]);

            // 3. Bloqueo de seguridad: Retornar error 403 (Prohibido) [cite: 5]
            abort(403, 'No tienes permisos para acceder a esta sección.');
        }

        return $next($request);
    }
}