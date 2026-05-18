<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class EnsureTwoFactorIsVerified
{
    /**
     * Maneja una solicitud entrante.
     * * Este middleware actúa como el "portero" de seguridad del sistema Pet Spa.
     * Verifica si el usuario tiene activo el 2FA y si ya validó su identidad
     * en la sesión actual.
     */
    public function handle(Request $request, Closure $next)
    {
        $user = Auth::user();

        /**
         * 1. VERIFICACIÓN DE ESTADO (SEGURIDAD AVANZADA)
         * Usamos la sintaxis {""} debido a que el nombre de la columna inicia con un número,
         * evitando así errores de sintaxis en PHP.
         */
        if (Auth::check() && $user->{"2fa_habilitado"}) {
            
            /**
             * 2. COMPROBACIÓN DE SESIÓN
             * Si el usuario tiene habilitado el 2FA pero no existe la clave '2fa_verified'
             * en su sesión actual, se le restringe el acceso.
             */
            if (!session()->has('2fa_verified')) {
                
                /**
                 * 3. PREVENCIÓN DE BUCLES (EXCEPCIONES)
                 * Permitimos que el tráfico fluya solo hacia la pantalla de verificación 
                 * o hacia el cierre de sesión, de lo contrario, el usuario quedaría atrapado.
                 */
                if (!$request->is('2fa/verify*') && !$request->is('logout')) {
                    return redirect()->route('2fa.verify.index');
                }
            }
        }

        /**
         * Si el usuario no tiene 2FA activo o ya verificó su código,
         * se le permite continuar a su destino (Dashboard, Citas, etc.).
         */
        return $next($request);
    }
}