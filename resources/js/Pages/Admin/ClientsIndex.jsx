import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, router, useForm } from '@inertiajs/react';
import { useState } from 'react';

export default function ClientsIndex({ auth, clients }) {
    // 1. Estados para controlar la interfaz de edición
    const [isEditing, setIsEditing] = useState(false);
    const [editId, setEditId] = useState(null);

    // 2. Formulario de Inertia para la actualización
    const { data, setData, put, processing, errors, reset } = useForm({
        name: '',
        email: '',
        id_rol: 4, // El rol de cliente es fijo
        reset_password: false,
    });

    // 3. Función para cargar datos en el formulario
    const handleEditClick = (client) => {
        setEditId(client.id_usuario);
        setData({
            name: client.name,
            email: client.email,
            id_rol: 4,
            reset_password: false,
        });
        setIsEditing(true);
        window.scrollTo({ top: 0, behavior: 'smooth' });
    };

    // 4. Procesar la actualización (Reutiliza tu lógica de UserController)
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

    const handleToggleStatus = (id, currentStatus) => {
        const action = currentStatus ? 'SUSPENDER' : 'ACTIVAR';
        if (confirm(`¿Confirmas ${action} la cuenta de este cliente?`)) {
            router.patch(route('admin.users.status', id), {}, { preserveScroll: true });
        }
    };

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={<h2 className="font-semibold text-xl text-gray-800 leading-tight">Cartera de Clientes - Pet Spa</h2>}
        >
            <Head title="Clientes" />

            <div className="py-12">
                <div className="max-w-7xl mx-auto sm:px-6 lg:px-8 space-y-6">
                    
                    {/* FORMULARIO DE EDICIÓN DINÁMICO */}
                    {isEditing && (
                        <div className="bg-indigo-50 border-l-4 border-indigo-500 p-6 shadow-md rounded-lg animate-in fade-in slide-in-from-top-4 duration-300">
                            <h3 className="text-lg font-bold text-indigo-900 mb-4">Modificar Datos del Cliente</h3>
                            <form onSubmit={handleUpdate} className="space-y-4">
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700">Nombre</label>
                                        <input 
                                            type="text" 
                                            value={data.name} 
                                            onChange={e => setData('name', e.target.value)}
                                            className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500" 
                                        />
                                        {errors.name && <div className="text-red-500 text-xs mt-1">{errors.name}</div>}
                                    </div>
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700">Email</label>
                                        <input 
                                            type="email" 
                                            value={data.email} 
                                            onChange={e => setData('email', e.target.value)}
                                            className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500" 
                                        />
                                        {errors.email && <div className="text-red-500 text-xs mt-1">{errors.email}</div>}
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
                                        <span className="ml-2 text-sm font-semibold text-red-600">Restablecer clave a "passwordSpa"</span>
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

                    <div className="bg-white p-6 shadow sm:rounded-lg border border-gray-200">
                        <h3 className="mb-6 font-bold text-gray-700">Listado de Clientes Registrados</h3>
                        <table className="min-w-full divide-y divide-gray-200">
                            <thead className="bg-gray-50">
                                <tr className="text-xs text-gray-500 font-bold uppercase">
                                    <th className="px-6 py-3 text-left">Cliente</th>
                                    <th className="px-6 py-3 text-left">Email</th>
                                    <th className="px-6 py-3 text-center">Estado</th>
                                    <th className="px-6 py-3 text-center">Acciones</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-gray-200">
                                {clients.map((client) => (
                                    <tr key={client.id_usuario} className="hover:bg-gray-50 transition">
                                        <td className="px-6 py-4 font-semibold text-gray-800">{client.name}</td>
                                        <td className="px-6 py-4 text-gray-600">{client.email}</td>
                                        <td className="px-6 py-4 text-center">
                                            <span className={`px-3 py-1 rounded-full text-xs font-black ${client.activo ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                                                {client.activo ? 'ACTIVO' : 'INACTIVO'}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 text-center space-x-3">
                                            <button 
                                                onClick={() => handleEditClick(client)}
                                                className="text-indigo-600 font-bold hover:text-indigo-900 transition"
                                            >
                                                Editar
                                            </button>
                                            <button 
                                                onClick={() => handleToggleStatus(client.id_usuario, client.activo)}
                                                className={`text-xs font-bold uppercase p-2 rounded border transition ${
                                                    client.activo 
                                                    ? 'border-red-300 text-red-600 hover:bg-red-50' 
                                                    : 'border-green-300 text-green-600 hover:bg-green-50'
                                                }`}
                                            >
                                                {client.activo ? 'Inhabilitar' : 'Habilitar'}
                                            </button>
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