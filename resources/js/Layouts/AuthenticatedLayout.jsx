import ApplicationLogo from '@/Components/ApplicationLogo';
import Dropdown from '@/Components/Dropdown';
import NavLink from '@/Components/NavLink';
import ResponsiveNavLink from '@/Components/ResponsiveNavLink';
import { Link, usePage } from '@inertiajs/react';
import { useState } from 'react';

export default function AuthenticatedLayout({ header, children }) {
    const user = usePage().props.auth.user;
    const [showingNavigationDropdown, setShowingNavigationDropdown] = useState(false);

    // Mapeo de Roles para visualización profesional
    const roleNames = {
        1: 'Administrador',
        2: 'Recepción',
        3: 'Groomer',
        4: 'Cliente'
    };

    const currentRole = roleNames[user.id_rol] || 'Usuario';

    return (
        <div className="min-h-screen bg-gray-100">
            <nav className="border-b border-gray-100 bg-white">
                <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
                    <div className="flex h-16 justify-between">
                        <div className="flex">
                            {/* Logo */}
                            <div className="flex shrink-0 items-center">
                                <Link href="/">
                                    <ApplicationLogo className="block h-9 w-auto fill-current text-gray-800" />
                                </Link>
                            </div>

                            {/* Enlaces de Navegación (Escritorio) */}
                            <div className="hidden space-x-8 sm:-my-px sm:ms-10 sm:flex">
                                <NavLink
                                    href={route('dashboard')}
                                    active={route().current('dashboard')}
                                >
                                    Dashboard
                                </NavLink>

                                {/* ENLACES EXCLUSIVOS PARA ADMINISTRADOR (ROL 1) */}
                                {user.id_rol === 1 && (
                                    <>
                                        <NavLink
                                            href={route('admin.users')}
                                            active={route().current('admin.users')}
                                        >
                                            Gestionar Personal
                                        </NavLink>

                                        <NavLink
                                            href={route('admin.clients.index')}
                                            active={route().current('admin.clients.index')}
                                        >
                                            Gestionar Clientes
                                        </NavLink>

                                        {/* ACCESO A LOGS DE AUDITORÍA */}
                                        <NavLink
                                            href={route('admin.logs')}
                                            active={route().current('admin.logs')}
                                            className={route().current('admin.logs') ? 'text-red-600 font-bold' : ''}
                                        >
                                            Logs Auditoría
                                        </NavLink>
                                        
                                        <NavLink
                                            href={route('2fa.setup')}
                                            active={route().current('2fa.setup')}
                                        >
                                            Seguridad 2FA
                                        </NavLink>
                                    </>
                                )}

                                {/* ENLACES PARA PERSONAL INTERNO (ROLES 1, 2, 3) */}
                                {[1, 2, 3].includes(user.id_rol) && (
                                    <NavLink
                                        href={route('gestion.citas')}
                                        active={route().current('gestion.citas')}
                                    >
                                        Gestión de Citas
                                    </NavLink>
                                )}
                            </div>
                        </div>

                        {/* Dropdown de Usuario */}
                        <div className="hidden sm:ms-6 sm:flex sm:items-center">
                            <div className="relative ms-3">
                                <Dropdown>
                                    <Dropdown.Trigger>
                                        <span className="inline-flex rounded-md">
                                            <button
                                                type="button"
                                                className="inline-flex items-center rounded-md border border-transparent bg-white px-3 py-2 text-sm font-medium leading-4 text-gray-500 transition duration-150 ease-in-out hover:text-gray-700 focus:outline-none"
                                            >
                                                <span className="font-bold text-indigo-600 mr-1">{user.name}</span> 
                                                <span className="text-gray-400">({currentRole})</span>

                                                <svg className="-me-0.5 ms-2 h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                                                    <path fillRule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clipRule="evenodd" />
                                                </svg>
                                            </button>
                                        </span>
                                    </Dropdown.Trigger>

                                    <Dropdown.Content>
                                        <Dropdown.Link href={route('profile.edit')}>Perfil</Dropdown.Link>
                                        <Dropdown.Link href={route('logout')} method="post" as="button">Cerrar Sesión</Dropdown.Link>
                                    </Dropdown.Content>
                                </Dropdown>
                            </div>
                        </div>

                        {/* Menú Móvil */}
                        <div className="-me-2 flex items-center sm:hidden">
                            <button onClick={() => setShowingNavigationDropdown((p) => !p)} className="p-2 text-gray-400 hover:bg-gray-100 rounded-md">
                                <svg className="h-6 w-6" stroke="currentColor" fill="none" viewBox="0 0 24 24">
                                    <path className={!showingNavigationDropdown ? 'inline-flex' : 'hidden'} strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16" />
                                    <path className={showingNavigationDropdown ? 'inline-flex' : 'hidden'} strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>

                {/* Navegación Móvil */}
                <div className={(showingNavigationDropdown ? 'block' : 'hidden') + ' sm:hidden'}>
                    <div className="space-y-1 pb-3 pt-2">
                        <ResponsiveNavLink href={route('dashboard')} active={route().current('dashboard')}>Dashboard</ResponsiveNavLink>

                        {user.id_rol === 1 && (
                            <>
                                <ResponsiveNavLink href={route('admin.users')} active={route().current('admin.users')}>Gestionar Personal</ResponsiveNavLink>
                                <ResponsiveNavLink href={route('admin.clients.index')} active={route().current('admin.clients.index')}>Gestionar Clientes</ResponsiveNavLink>
                                <ResponsiveNavLink href={route('admin.logs')} active={route().current('admin.logs')}>Logs Auditoría</ResponsiveNavLink>
                                <ResponsiveNavLink href={route('2fa.setup')} active={route().current('2fa.setup')}>Seguridad 2FA</ResponsiveNavLink>
                            </>
                        )}

                        {[1, 2, 3].includes(user.id_rol) && (
                            <ResponsiveNavLink href={route('gestion.citas')} active={route().current('gestion.citas')}>Gestión de Citas</ResponsiveNavLink>
                        )}
                    </div>
                </div>
            </nav>

            {header && (
                <header className="bg-white shadow">
                    <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">{header}</div>
                </header>
            )}

            <main>{children}</main>
        </div>
    );
}