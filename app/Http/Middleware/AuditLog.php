<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class AuditLog
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Primero dejamos que la petición siga su curso
        $response = $next($request);

        // Si el usuario está autenticado, registramos la acción en la DB
        if (Auth::check()) {
            DB::table('log_auditoria')->insert([
                'id_usuario'   => Auth::id(),
                'rol_snapshot' => Auth::user()->id_rol, // Captura el rol actual
                'accion'       => "Acceso a: " . $request->method() . " " . $request->path(),
                'modulo'       => 'Sistema Web Pet Spa',
                'ip_origen'    => $request->ip(),      // Requerimiento: ¿Desde dónde?
                'user_agent'   => $request->userAgent(), // Requerimiento: Dispositivo/Navegador
                'timestamp'    => now(),               // Requerimiento: ¿Cuándo?
            ]);
        }

        return $response;
    }
}