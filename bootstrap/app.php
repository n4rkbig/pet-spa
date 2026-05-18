<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        // Registro UNIFICADO de Alias para evitar el error "Target class does not exist"
        $middleware->alias([
            '2fa.verified' => \App\Http\Middleware\EnsureTwoFactorIsVerified::class, // 
            'role'         => \App\Http\Middleware\RoleMiddleware::class,           // 
            'auditoria'    => \App\Http\Middleware\AuditoriaMiddleware::class,      // 
        ]);

        $middleware->web(append: [
            \App\Http\Middleware\HandleInertiaRequests::class,
            \Illuminate\Http\Middleware\AddLinkHeadersForPreloadedAssets::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })->create();