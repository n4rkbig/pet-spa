<?php

use App\Http\Controllers\ProfileController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\TwoFactorController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

// ---------------------------------------------------------
// PÁGINA DE BIENVENIDA
// ---------------------------------------------------------
Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);
});

// ---------------------------------------------------------
// RUTAS DE VALIDACIÓN 2FA (Después del Login inicial)
// ---------------------------------------------------------
Route::middleware(['auth'])->group(function () {
    // Pantalla donde se pide el código de 6 dígitos
    Route::get('/2fa/verify', [TwoFactorController::class, 'showVerifyForm'])->name('2fa.verify.index');
    // Procesar la validación del código enviado por el usuario
    Route::post('/2fa/verify', [TwoFactorController::class, 'verifyCode'])->name('2fa.verify.store');
});

// ---------------------------------------------------------
// RUTAS PROTEGIDAS (Requieren Auth y verificación del Portero 2FA)
// ---------------------------------------------------------
Route::middleware(['auth', '2fa.verified'])->group(function () {

    // Dashboard común para todos los usuarios autenticados
    Route::get('/dashboard', function () {
        return Inertia::render('Dashboard');
    })->name('dashboard');

    // CONFIGURACIÓN 2FA (Accesible desde el perfil de cada usuario)
    Route::get('/2fa/setup', [TwoFactorController::class, 'showSetupForm'])->name('2fa.setup');
    Route::post('/2fa/enable', [TwoFactorController::class, 'enable2FA'])->name('2fa.enable');

    // -----------------------------------------------------
    // 1. MÓDULO ADMINISTRATIVO (Solo Rol 1)
    // -----------------------------------------------------
    Route::middleware(['role:1'])->group(function () {
        
        // logs
        Route::get('/admin/logs', [UserController::class, 'viewLogs'])->name('admin.logs');
        
        // Gestión de Personal Interno (Admin, Recepción, Groomer)
        Route::get('/admin/usuarios', [UserController::class, 'index'])->name('admin.users');
        
        // Gestión de Cartera de Clientes (Rol 4)
        Route::get('/admin/clientes', [UserController::class, 'indexClientes'])->name('admin.clients.index');

        // Registro de Nuevo Personal
        Route::get('/admin/registrar-personal', function () {
            return Inertia::render('Admin/CreateUser');
        })->name('admin.register.personal');

        Route::post('/admin/registrar-empleado', [UserController::class, 'storeEmpleado'])->name('admin.store.empleado');
        
        // Acciones compartidas de Auditoría y Control (Usa el mismo controlador para todos los roles)
        Route::patch('/admin/usuarios/{id}/status', [UserController::class, 'toggleStatus'])->name('admin.users.status');
        Route::put('/admin/usuarios/{id}', [UserController::class, 'update'])->name('admin.users.update');
        Route::delete('/admin/usuarios/{id}', [UserController::class, 'destroy'])->name('admin.users.destroy');
    });

    // -----------------------------------------------------
    // 2. MÓDULO OPERATIVO (Admin, Recepción y Groomers)
    // -----------------------------------------------------
    Route::middleware(['role:1,2,3'])->group(function () {
        Route::get('/gestion/citas', function () {
            return Inertia::render('Gestion/CitasIndex');
        })->name('gestion.citas');
    });

    // -----------------------------------------------------
    // 3. MÓDULO DE CLIENTES (Solo Rol 4)
    // -----------------------------------------------------
    Route::middleware(['role:4'])->group(function () {
        Route::get('/mis-mascotas', function () {
            return Inertia::render('Clientes/Mascotas');
        })->name('cliente.mascotas');
    });

    // -----------------------------------------------------
    // RUTAS DE PERFIL (Comunes para todos los roles)
    // -----------------------------------------------------
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

require __DIR__.'/auth.php';