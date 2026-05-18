<?php

return [

    /*
     * Enable / disable Google2FA.
     */
    'enabled' => env('OTP_ENABLED', true),

    /*
     * Lifetime in minutes.
     */
    'lifetime' => env('OTP_LIFETIME', 0), // 0 = eternal

    /*
     * Renew lifetime at every new request.
     */
    'keep_alive' => env('OTP_KEEP_ALIVE', true),

    /*
     * Auth container binding.
     */
    'auth' => 'auth',

    /*
     * Guard.
     */
    'guard' => '',

    /*
     * 2FA verified session var.
     */
    'session_var' => 'google2fa',

    /*
     * One Time Password request input name.
     */
    'otp_input' => 'one_time_password',

    /*
     * One Time Password Window.
     */
    'window' => 1,

    /*
     * Forbid user to reuse One Time Passwords.
     */
    'forbid_old_passwords' => false,

    /*
     * CAMBIO 1: Nombre de la columna en tu tabla 'usuario'
     * Debe coincidir con lo que pusimos en el controlador: '2fa_secreto'
     */
    'otp_secret_column' => '2fa_secreto',

    /*
     * One Time Password View.
     */
    'view' => 'google2fa.index',

    /*
     * One Time Password error message.
     */
    'error_messages' => [
        'wrong_otp'       => "The 'One Time Password' typed was wrong.",
        'cannot_be_empty' => 'One Time Password cannot be empty.',
        'unknown'         => 'An unknown error has occurred. Please try again.',
    ],

    /*
     * Throw exceptions or just fire events?
     */
    'throw_exceptions' => env('OTP_THROW_EXCEPTION', true),

    /*
     * Which image backend to use for generating QR codes?
     */
    'qrcode_image_backend' => \PragmaRX\Google2FALaravel\Support\Constants::QRCODE_IMAGE_BACKEND_SVG,

    /*
     * CAMBIO 2: Motor de renderizado de QR (Soluciona el error Internal Server Error)
     * Requiere que hayas ejecutado: composer require bacon/bacon-qr-code
     */
    // 'qrcode_service' => \PragmaRX\Google2FAQRCode\QRServer\BaconQrCode::class,

];