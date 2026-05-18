import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, Link, router, useForm } from '@inertiajs/react';
import { useState } from 'react';

export default function UsersIndex({ auth, users }) {
    // 1. Mapeo de Roles para visualización profesional
    const roleNames = {
        1: 'Administrador',
        2: 'Recepción',
        3: 'Groomer',
        4: 'Cliente'
    };

    // Estados para controlar la edición
    const [isEditing, setIsEditing] = useState(false);
    const [editId, setEditId] = useState(null);

    // Formulario de Inertia para la actualización
    const { data, setData, put, processing, errors, reset } = useForm({
        name: '',
        email: '',
        id_rol: '',
        reset_password: false,
    });

    // Cargar datos en el formulario para editar
    const handleEditClick = (user) => {
        setEditId(user.id_usuario);
        setData({
            name: user.name,
            email: user.email,
            id_rol: user.id_rol,
            reset_password: false,
        });
        setIsEditing(true);
        window.scrollTo({ top: 0, behavior: 'smooth' });
    };

    // Procesar la actualización
    const handleUpdate = (e) => {
        e.preventDefault();
        put(route('admin.users.update', editId), {
            onSuccess: () => {
                setIsEditing(false);
                setEditId(null);
                reset();
            },
        });
    };

    // Procesar la eliminación (Borrado Físico) con protección de auto-eliminación
    const handleDelete = (id, name) => {
        if (id === auth.user.id_usuario) {
            alert("No puedes eliminar tu propia cuenta de administrador.");
            return;
        }

        if (confirm(`¿ESTÁS SEGURO? Vas a eliminar permanentemente a "${name}". Esta acción no se puede deshacer.`)) {
            router.delete(route('admin.users.destroy', id));
        }
    };

    // Cambiar estado (Activo/Inactivo - Borrado Lógico) con protección de auto-suspensión
    const handleToggleStatus = (id, currentStatus) => {
        if (id === auth.user.id_usuario) {
            alert("Acción denegada: No puedes suspender tu propia cuenta de acceso.");
            return;
        }

        const action = currentStatus ? 'suspender' : 'activar';
        if (confirm(`¿Estás seguro de que deseas ${action} a este usuario?`)) {
            router.patch(route('admin.users.status', id), {}, { preserveScroll: true });
        }
    };

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={<h2 className="font-semibold text-xl text-gray-800 leading-tight">Gestión de Personal Interno</h2>}
        >
            <Head title="Personal" />

            <div className="py-12">
                <div className="max-w-7xl mx-auto sm:px-6 lg:px-8 space-y-6">
                    
                    {/* FORMULARIO DE EDICIÓN DINÁMICO */}
                    {isEditing && (
                        <div className="bg-indigo-50 border-l-4 border-indigo-500 p-6 shadow-md rounded-lg animate-in fade-in slide-in-from-top-4 duration-300">
                            <h3 className="text-lg font-bold text-indigo-900 mb-4">Modificar Datos de Empleado</h3>
                            <form onSubmit={handleUpdate} className="space-y-4">
                                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700">Nombre Completo</label>
                                        <input 
                                            type="text" 
                                            value={data.name} 
                                            onChange={e => setData('name', e.target.value)}
                                            className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500" 
                                        />
                                        {errors.name && <div className="text-red-500 text-xs mt-1">{errors.name}</div>}
                                    </div>
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700">Email Corporativo</label>
                                        <input 
                                            type="email" 
                                            value={data.email} 
                                            onChange={e => setData('email', e.target.value)}
                                            className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500" 
                                        />
                                        {errors.email && <div className="text-red-500 text-xs mt-1">{errors.email}</div>}
                                    </div>
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700">Rol asignado</label>
                                        <select 
                                            value={data.id_rol} 
                                            onChange={e => setData('id_rol', e.target.value)}
                                            className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500"
                                        >
                                            <option value="1">Administrador</option>
                                            <option value="2">Recepción</option>
                                            <option value="3">Groomer</option>
                                        </select>
                                    </div>
                                </div>

                                <div className="flex items-center space-x-6 pt-2">
                                    <label className="inline-flex items-center cursor-pointer">
                                        <input 
                                            type="checkbox" 
                                            checked={data.reset_password}
                                            onChange={e => setData('reset_password', e.target.checked)}
                                            className="rounded border-gray-300 text-indigo-600 focus:ring-indigo-500 h-5 w-5"
                                        />
                                        <span className="ml-2 text-sm font-semibold text-red-600">Restablecer contraseña a "passwordSpa"</span>
                                    </label>

                                    <div className="flex space-x-3">
                                        <button 
                                            type="submit" 
                                            disabled={processing}
                                            className="bg-indigo-600 text-white px-6 py-2 rounded-md hover:bg-indigo-700 transition font-bold shadow-sm"
                                        >
                                            {processing ? 'Guardando...' : 'Guardar Cambios'}
                                        </button>
                                        <button 
                                            type="button" 
                                            onClick={() => { setIsEditing(false); reset(); }}
                                            className="bg-gray-200 text-gray-700 px-6 py-2 rounded-md hover:bg-gray-300 transition"
                                        >
                                            Cancelar
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    )}

                    {/* TABLA DE EMPLEADOS */}
                    <div className="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6 border border-gray-200">
                        <div className="flex justify-between items-center mb-6">
                            <h3 className="text-lg font-bold text-gray-900">Personal Registrado</h3>
                            <Link
                                href={route('admin.register.personal')}
                                className="bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700 transition shadow-sm"
                            >
                                + Nuevo Empleado
                            </Link>
                        </div>

                        <table className="min-w-full divide-y divide-gray-200">
                            <thead className="bg-gray-50">
                                <tr>
                                    <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">Nombre</th>
                                    <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">Email</th>
                                    <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">Rol</th>
                                    <th className="px-6 py-3 text-left text-xs font-bold text-gray-500 uppercase">Estado</th>
                                    <th className="px-6 py-3 text-center text-xs font-bold text-gray-500 uppercase">Acciones</th>
                                </tr>
                            </thead>
                            <tbody className="bg-white divide-y divide-gray-200">
                                {users.map((user) => (
                                    <tr key={user.id_usuario} className="hover:bg-gray-50 transition">
                                        <td className="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-900">{user.name}</td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{user.email}</td>
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            <span className={`px-3 py-1 inline-flex text-xs leading-5 font-bold rounded-full ${
                                                user.id_rol === 1 ? 'bg-purple-100 text-purple-800 border border-purple-200' : 'bg-blue-100 text-blue-800 border border-blue-200'
                                            }`}>
                                                {roleNames[user.id_rol] || 'Sin Rol'}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            <span className={`px-3 py-1 inline-flex text-xs leading-5 font-bold rounded-full ${
                                                user.activo ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                                            }`}>
                                                {user.activo ? 'Activo' : 'Suspendido'}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-sm text-center font-medium">
                                            <button 
                                                onClick={() => handleEditClick(user)}
                                                className="text-indigo-600 hover:text-indigo-900 mx-2 font-bold"
                                            >
                                                Editar
                                            </button>

                                            {/* PROTECCIÓN: Si el usuario de la fila es el mismo que el logueado, ocultamos acciones destructivas */}
                                            {user.id_usuario !== auth.user.id_usuario ? (
                                                <>
                                                    <button 
                                                        onClick={() => handleToggleStatus(user.id_usuario, user.activo)}
                                                        className={`mx-2 font-bold ${
                                                            user.activo ? 'text-red-600 hover:text-red-800' : 'text-green-600 hover:text-green-800'
                                                        }`}
                                                    >
                                                        {user.activo ? 'Suspender' : 'Reactivar'}
                                                    </button>

                                                    <button 
                                                        onClick={() => handleDelete(user.id_usuario, user.name)}
                                                        className="text-red-600 hover:text-red-900 mx-2 font-bold"
                                                    >
                                                        Eliminar
                                                    </button>
                                                </>
                                            ) : (
                                                <span className="text-gray-400 italic text-xs mx-2">
                                                    (Tu cuenta)
                                                </span>
                                            )}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </AuthenticatedLayout>
    );
}