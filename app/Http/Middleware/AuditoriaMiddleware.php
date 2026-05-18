<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;

class AuditoriaMiddleware
{
    /**
     * Usamos "...$params" para capturar cualquier argumento extra 
     * y evitar el error de "Not enough arguments".
     */
    public function handle(Request $request, \Closure $next, ...$params): \Symfony\Component\HttpFoundation\Response
    {
        // El sistema ahora no se quejará si sobran o faltan argumentos
        $accion = $params[0] ?? 'Acción del sistema';

        $response = $next($request);

        if (\Illuminate\Support\Facades\Auth::check()) {
            \Illuminate\Support\Facades\DB::table('log_auditoria')->insert([
                'id_log' => (string) \Illuminate\Support\Str::uuid(),
                'id_usuario' => \Illuminate\Support\Facades\Auth::id(),
                'rol' => \Illuminate\Support\Facades\Auth::user()->id_rol,
                'fecha_hora' => now(),
                'ip' => $request->ip(),
                'navegador' => $request->header('User-Agent'),
                'accion' => $accion,
            ]);
        }

        return $response;
    }
}