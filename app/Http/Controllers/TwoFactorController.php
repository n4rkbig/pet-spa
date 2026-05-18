<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class TwoFactorController extends Controller
{
    /**
     * PASO 1: Configuración inicial (Generar QR)
     */
    public function showSetupForm()
    {
        $user = Auth::user();
        $google2fa = app('pragmarx.google2fa');
        
        // Generamos la clave secreta única
        $secret = $google2fa->generateSecretKey();
        
        // Generamos la URL para el QR
        $qrUrl = $google2fa->getQRCodeUrl(
            'Pet Spa Mascotas',
            $user->email,
            $secret
        );

        // API externa para renderizar el QR de forma segura
        $qrImage = "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=" . urlencode($qrUrl);

        return Inertia::render('Profile/TwoFactorSetup', [
            'qrImage' => $qrImage,
            'secret' => $secret,
        ]);
    }

    /**
     * PASO 2: Activación inicial en el perfil
     */
    public function enable2FA(Request $request)
    {
        $request->validate([
            'code' => 'required|digits:6',
            'secret' => 'required',
        ]);

        $user = Auth::user();
        $google2fa = app('pragmarx.google2fa');

        // Verificamos el código con una ventana de tiempo de 1 (margen de 30s)
        $valid = $google2fa->verifyKey($request->secret, $request->code, 1);

        if ($valid) {
            $user->update([
                '2fa_secreto' => $request->secret,
                '2fa_habilitado' => true,
            ]);

            // Al activar, liberamos la sesión actual
            session(['2fa_verified' => true]);

            $this->registrarLog($request, 'SEGURIDAD: El usuario habilitó exitosamente el 2FA.');

            return redirect()->route('dashboard')->with('message', 'Autenticación de dos factores activada.');
        }

        return back()->withErrors(['code' => 'Código de verificación inválido. Reintente.']);
    }

    /**
     * PASO 3: Mostrar pantalla de reto 2FA (Post-Login)
     */
    public function showVerifyForm()
    {
        return Inertia::render('Auth/TwoFactorVerify');
    }

    /**
     * PASO 4: Validar el código de inicio de sesión
     */
    public function verifyCode(Request $request)
{
    $request->validate([
        'code' => 'required|digits:6',
    ]);

    $user = Auth::user();
    $google2fa = app('pragmarx.google2fa');

    // CORRECCIÓN: Acceso seguro a columna que empieza por número
    $secret = $user->{"2fa_secreto"}; 

    if (!$secret) {
        return redirect()->route('login')->withErrors([
            'email' => 'Error: No se encontró la configuración de seguridad en su cuenta.'
        ]);
    }

    // Verificación con margen de tiempo (window = 1)
    $valid = $google2fa->verifyKey($secret, $request->code, 1);

    if ($valid) {
        session(['2fa_verified' => true]);
        $this->registrarLog($request, 'ACCESO: Segundo factor verificado correctamente.');
        return redirect()->intended(route('dashboard'));
    }

    // Trazabilidad de fallos
    $this->registrarLog($request, 'ADVERTENCIA: Intento de 2FA fallido.');

    return back()->withErrors(['code' => 'Código de seguridad incorrecto o expirado.']);
    }
    /**
     * Función privada para Auditoría (Trazabilidad - 5 pts)
     */
    private function registrarLog(Request $request, $accion)
    {
        try {
            DB::table('log_auditoria')->insert([
                'id_log' => (string) Str::uuid(),
                'id_usuario' => Auth::user()->id_usuario,
                'rol' => Auth::user()->id_rol,
                'fecha_hora' => now(),
                'ip' => $request->ip(),
                'navegador' => $request->header('User-Agent'),
                'accion' => $accion,
            ]);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error("Error grabando auditoría 2FA: " . $e->getMessage());
        }
    }
}