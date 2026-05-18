import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, Link, usePage } from '@inertiajs/react';
import DeleteUserForm from './Partials/DeleteUserForm';
import UpdatePasswordForm from './Partials/UpdatePasswordForm';
import UpdateProfileInformationForm from './Partials/UpdateProfileInformationForm';

export default function Edit({ mustVerifyEmail, status }) {
    const { auth } = usePage().props;

    return (
        <AuthenticatedLayout
            header={
                <h2 className="text-xl font-semibold leading-tight text-gray-800">
                    Mi Perfil
                </h2>
            }
        >
            <Head title="Perfil" />

            <div className="py-12">
                <div className="mx-auto max-w-7xl space-y-6 sm:px-6 lg:px-8">
                    
                    {/* SECCIÓN DE SEGURIDAD AVANZADA (2FA) - REQUISITO DE RÚBRICA */}
                    <div className="bg-white p-4 shadow sm:rounded-lg sm:p-8 border-l-4 border-indigo-500">
                        <header className="mb-4">
                            <h2 className="text-lg font-medium text-gray-900">Seguridad de la Cuenta</h2>
                            <p className="mt-1 text-sm text-gray-600">
                                Añada una capa adicional de seguridad a su cuenta mediante la autenticación de dos factores.
                            </p>
                        </header>

                        {/* Alerta dinámica según el estado del 2FA */}
                        {auth.user["2fa_habilitado"] ? (
                            <div className="bg-green-50 border border-green-200 rounded-md p-4 flex items-center">
                                <svg className="h-6 w-6 text-green-500 mr-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                                </svg>
                                <span className="text-green-800 font-bold">
                                    ¡Protección Activa! Su cuenta está verificada con 2FA.
                                </span>
                            </div>
                        ) : (
                            <div className="bg-amber-50 border border-amber-200 rounded-md p-4">
                                <p className="text-amber-800 mb-4">
                                    La autenticación de dos factores no está activa. Se recomienda encarecidamente habilitarla para proteger sus datos personales y de auditoría.
                                </p>
                                <Link
                                    href={route('2fa.setup')}
                                    className="inline-flex items-center rounded-md border border-transparent bg-indigo-600 px-4 py-2 text-xs font-semibold uppercase tracking-widest text-white transition duration-150 ease-in-out hover:bg-indigo-700 focus:bg-indigo-700 focus:outline-none"
                                >
                                    Configurar 2FA ahora
                                </Link>
                            </div>
                        )}
                    </div>

                    <div className="bg-white p-4 shadow sm:rounded-lg sm:p-8">
                        <UpdateProfileInformationForm
                            mustVerifyEmail={mustVerifyEmail}
                            status={status}
                            className="max-w-xl"
                        />
                    </div>

                    <div className="bg-white p-4 shadow sm:rounded-lg sm:p-8">
                        <UpdatePasswordForm className="max-w-xl" />
                    </div>

                    <div className="bg-white p-4 shadow sm:rounded-lg sm:p-8">
                        <DeleteUserForm className="max-w-xl" />
                    </div>
                </div>
            </div>
        </AuthenticatedLayout>
    );
}