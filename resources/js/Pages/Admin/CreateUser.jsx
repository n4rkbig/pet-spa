import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, useForm } from '@inertiajs/react';
import InputLabel from '@/Components/InputLabel';
import TextInput from '@/Components/TextInput';
import InputError from '@/Components/InputError';
import PrimaryButton from '@/Components/PrimaryButton';

export default function CreateUser({ auth }) {
    const { data, setData, post, processing, errors, reset } = useForm({
        name: '',
        email: '',
        id_rol: '',
    });

    const submit = (e) => {
        e.preventDefault();
        post(route('admin.store.empleado'), {
            onFinish: () => reset('name', 'email', 'id_rol'),
        });
    };

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={<h2 className="font-semibold text-xl text-gray-800 leading-tight">Registrar Nuevo Personal Interno</h2>}
        >
            <Head title="Registrar Personal" />

            <div className="py-12">
                <div className="max-w-7xl mx-auto sm:px-6 lg:px-8">
                    <div className="bg-white p-6 shadow sm:rounded-lg border-t-4 border-indigo-500">
                        
                        <div className="mb-6 bg-blue-50 border-l-4 border-blue-400 p-4">
                            <p className="text-sm text-blue-700">
                                <strong>Nota de Seguridad:</strong> Al registrar personal nuevo, el sistema asignará automáticamente la contraseña temporal: <span className="font-mono font-bold">passwordSpa</span>. El empleado deberá cambiarla desde su perfil.
                            </p>
                        </div>

                        <form onSubmit={submit} className="max-w-xl">
                            {/* CAMPO NOMBRE */}
                            <div className="mb-4">
                                <InputLabel htmlFor="name" value="Nombre Completo" />
                                <TextInput 
                                    id="name" 
                                    className="mt-1 block w-full" 
                                    value={data.name} 
                                    onChange={(e) => setData('name', e.target.value)} 
                                    placeholder="Ej. Juan Pérez"
                                    required 
                                />
                                <InputError message={errors.name} className="mt-2" />
                            </div>

                            {/* CAMPO EMAIL */}
                            <div className="mb-4">
                                <InputLabel htmlFor="email" value="Correo Electrónico Corporativo" />
                                <TextInput 
                                    id="email" 
                                    type="email" 
                                    className="mt-1 block w-full" 
                                    value={data.email} 
                                    onChange={(e) => setData('email', e.target.value)} 
                                    placeholder="empleado@petspa.com"
                                    required 
                                />
                                <InputError message={errors.email} className="mt-2" />
                            </div>

                            {/* SELECCIÓN DE ROL (RBAC) */}
                            <div className="mb-6">
                                <InputLabel htmlFor="id_rol" value="Cargo / Rol Asignado" />
                                <select 
                                    id="id_rol"
                                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                                    value={data.id_rol} 
                                    onChange={(e) => setData('id_rol', e.target.value)}
                                    required
                                >
                                    <option value="">Seleccione un cargo...</option>
                                    <option value="1">Administrador</option>
                                    <option value="2">Recepción</option>
                                    <option value="3">Groomer</option>
                                </select>
                                <InputError message={errors.id_rol} className="mt-2" />
                            </div>

                            <div className="flex items-center justify-end mt-4">
                                <PrimaryButton className="ml-4" disabled={processing}>
                                    {processing ? 'Procesando...' : 'Registrar Empleado'}
                                </PrimaryButton>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </AuthenticatedLayout>
    );
}