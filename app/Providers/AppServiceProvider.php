<?php

namespace App\Providers;

use Illuminate\Support\Facades\Vite;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Event;
use Illuminate\Auth\Events\Verified;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Vite::prefetch(concurrency: 3);

        /**
         * REGISTRO DE TRAZABILIDAD (5 pts)
         * Este evento se dispara cuando el usuario hace clic en el enlace 
         * de verificación de su correo electrónico.
         */
        Event::listen(Verified::class, function ($event) {
            DB::table('log_auditoria')->insert([
                'id_log' => (string) Str::uuid(),
                'id_usuario' => $event->user->id_usuario, // Quién
                'rol' => $event->user->id_rol,
                'fecha_hora' => now(), // Cuándo
                'ip' => request()->ip(), // Desde dónde
                'navegador' => request()->header('User-Agent'), // Navegador/OS
                'accion' => 'ACTIVACIÓN DE CUENTA: El usuario completó la verificación por correo.', // Qué hizo
            ]);
        });

        // NUEVO: Limitador estricto para el Login del Pet Spa
        RateLimiter::for('login', function (Request $request) {
            return Limit::perMinute(5)->by($request->ip())->response(function () {
                return back()->withErrors([
                    'email' => 'Demasiados intentos de inicio de sesión. Por favor, intente de nuevo en 60 segundos.'
                ]);
            });
        });
    }
}