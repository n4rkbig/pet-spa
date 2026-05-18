<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log; 
use Inertia\Inertia;

class UserController extends Controller
{
    /**
     * Muestra la lista de personal interno (Admin, Recepción, Groomer)
     * Excluye a los Clientes (Rol 4)
     */
    public function index()
    {
        $users = DB::table('usuario')
            ->whereIn('id_rol', [1, 2, 3])
            ->orderBy('id_usuario', 'desc')
            ->get();

        return Inertia::render('Admin/UsersIndex', [
            'users' => $users
        ]);
    }

    /**
     * Muestra la lista exclusiva de Clientes (Rol 4)
     */
    public function indexClientes()
    {
        $clients = DB::table('usuario')
            ->where('id_rol', 4)
            ->orderBy('id_usuario', 'desc')
            ->get();

        return Inertia::render('Admin/ClientsIndex', [
            'clients' => $clients
        ]);
    }

    /**
     * Registro de nuevo personal con clave por defecto
     */
    public function storeEmpleado(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:50',
            'email' => 'required|string|email|max:120|unique:usuario,email',
            'id_rol' => 'required|in:1,2,3',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make('passwordSpa'),
            'id_rol' => $request->id_rol,
            'activo' => true,
        ]);

        $this->registrarLog("CREACIÓN: Admin registró nuevo personal ({$user->email}) con rol {$user->id_rol}.");

        return redirect()->route('admin.users.index')->with('status', 'Empleado registrado con éxito.');
    }

    /**
     * Actualizar datos y/o Restablecer Contraseña
     */
    public function update(Request $request, $id)
    {
        $request->validate([
            'name' => 'required|string|max:50',
            'email' => 'required|email|unique:usuario,email,'.$id.',id_usuario',
            'id_rol' => 'required|in:1,2,3,4',
        ]);

        $updateData = [
            'name' => $request->name,
            'email' => $request->email,
            'id_rol' => $request->id_rol,
        ];

        if ($request->reset_password) {
            $updateData['password'] = Hash::make('passwordSpa');
            $accionLog = "SEGURIDAD: Datos editados y clave restablecida para {$request->email}";
        } else {
            $accionLog = "ACTUALIZACIÓN: Datos de perfil editados para {$request->email}";
        }

        DB::table('usuario')->where('id_usuario', $id)->update($updateData);
        
        $this->registrarLog($accionLog);

        return back()->with('status', 'Usuario actualizado correctamente.');
    }

    /**
     * Alternar estado (Activo/Inactivo - Borrado Lógico)
     */
    public function toggleStatus($id)
    {
        // SEGURIDAD CRÍTICA: Bloqueo a nivel de servidor usando el ID de sesión
        // Auth::id() obtiene el valor de la columna 'id_usuario' del Admin logueado
        if ($id == Auth::id()) {
            return back()->withErrors(['error' => 'Acción denegada: No puedes auto-suspender tu propia cuenta de acceso.']);
        }

        $user = DB::table('usuario')->where('id_usuario', $id)->first();

        if ($user) {
            $nuevoEstado = !$user->activo;
            DB::table('usuario')->where('id_usuario', $id)->update(['activo' => $nuevoEstado]);

            $this->registrarLog(($nuevoEstado ? 'ACTIVACIÓN' : 'SUSPENSIÓN') . " de cuenta: {$user->email}");

            return back()->with('status', 'Estado de acceso actualizado.');
        }
        return back()->withErrors(['error' => 'Usuario no encontrado.']);
    }

    /**
     * Eliminación Física (Solo si es estrictamente necesario)
     */
    public function destroy($id)
    {
        // SEGURIDAD CRÍTICA: Impedir auto-eliminación
        if ($id == Auth::id()) {
            return back()->withErrors(['error' => 'Operación denegada: Imposible eliminar la cuenta en uso.']);
        }

        $user = DB::table('usuario')->where('id_usuario', $id)->first();

        if ($user) {
            DB::table('usuario')->where('id_usuario', $id)->delete();
            $this->registrarLog("ELIMINACIÓN PERMANENTE: Usuario {$user->email} borrado físicamente.");
            return back()->with('status', 'Usuario eliminado permanentemente.');
        }

        return back()->withErrors(['error' => 'Usuario no encontrado.']);
    }

    /**
     * Muestra el historial de auditoría (Trazabilidad)
     */
    public function viewLogs()
    {
        $logs = DB::table('log_auditoria')
            ->join('usuario', 'log_auditoria.id_usuario', '=', 'usuario.id_usuario')
            ->select(
                'log_auditoria.*', 
                'usuario.name as nombre_responsable',
                'usuario.email as email_responsable'
            )
            ->orderBy('log_auditoria.fecha_hora', 'desc')
            ->get();

        return Inertia::render('Admin/LogsIndex', [
            'logs' => $logs
        ]);
    }

    /**
     * Sistema de Trazabilidad para Rúbrica (5 pts)
     */
    private function registrarLog($accion)
    {
        try {
            DB::table('log_auditoria')->insert([
                'id_log' => (string) Str::uuid(),
                'id_usuario' => Auth::id(),
                'rol' => Auth::user()->id_rol,
                'fecha_hora' => now(),
                'ip' => request()->ip(),
                'navegador' => request()->header('User-Agent'),
                'accion' => $accion,
            ]);
        } catch (\Exception $e) {
            Log::error("Fallo Crítico en Sistema de Auditoría: " . $e->getMessage());
        }
    }
}