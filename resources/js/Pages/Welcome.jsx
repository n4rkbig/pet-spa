import { Head, Link } from '@inertiajs/react';

export default function Welcome({ auth }) {
    return (
        <>
            <Head title="Bienvenido" />
            
            <div className="min-h-screen bg-gray-50 text-slate-800 flex flex-col justify-between antialiased">
                
                {/* Navbar Superior */}
                <header className="bg-white border-b border-gray-200 w-full">
                    <div className="max-w-7xl mx-auto px-6 py-4 flex justify-between items-center">
                        <div className="flex items-center space-x-3">
                            {/* Icono de huella adaptado a la nueva paleta viva */}
                            <svg className="w-9 h-9 text-[#00a2c7]" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 14c1.66 0 3-1.34 3-3s-1.34-3-3-3-3 1.34-3 3 1.34 3 3 3zm-4.5-2.5c.83 0 1.5-.67 1.5-1.5s-.67-1.5-1.5-1.5-1.5.67-1.5 1.5.67 1.5 1.5 1.5zm9 0c.83 0 1.5-.67 1.5-1.5s-.67-1.5-1.5-1.5-1.5.67-1.5 1.5.67 1.5 1.5 1.5zm-7.75 6c.69 0 1.25-.56 1.25-1.25s-.56-1.25-1.25-1.25-1.25.56-1.25 1.25.56 1.25 1.25 1.25zm6.5 0c.69 0 1.25-.56 1.25-1.25s-.56-1.25-1.25-1.25-1.25.56-1.25 1.25.56 1.25 1.25 1.25z"/>
                            </svg>
                            <span className="text-xl font-black tracking-wider text-slate-900">
                                PET SPA
                            </span>
                        </div>

                        <nav className="flex space-x-4">
                            {auth.user ? (
                                <Link
                                    href={route('dashboard')}
                                    className="bg-[#00a2c7] hover:bg-[#008cb0] text-white px-5 py-2 rounded-md font-bold shadow-sm transition-all duration-200"
                                >
                                    Ir al Dashboard
                                </Link>
                            ) : (
                                <>
                                    <Link
                                        href={route('login')}
                                        className="text-slate-600 hover:text-[#00a2c7] px-3 py-2 font-bold transition duration-200"
                                    >
                                        Iniciar Sesión
                                    </Link>
                                    <Link
                                        href={route('register')}
                                        className="bg-[#00a2c7] hover:bg-[#008cb0] text-white px-5 py-2 rounded-md font-bold shadow-sm transition-all duration-200"
                                    >
                                        Registrarse
                                    </Link>
                                </>
                            )}
                        </nav>
                    </div>
                </header>

                {/* Sección Hero Principal */}
                <main className="max-w-4xl mx-auto px-6 text-center flex flex-col items-center justify-center flex-grow py-20">
                    <div className="inline-flex items-center space-x-2 bg-blue-50 border border-blue-200 px-4 py-1.5 rounded-full text-[#00a2c7] text-xs font-bold mb-8 uppercase tracking-wider">
                        <span>🌟 Estética y Cuidado Seguro</span>
                    </div>
                    
                    <h1 className="text-4xl md:text-5xl font-black tracking-tight text-slate-950 mb-6 leading-tight">
                        Cuidado profesional para tus mascotas
                    </h1>

                    <p className="text-xl md:text-2xl text-slate-600 font-medium max-w-2xl mb-12 leading-relaxed">
                        Con amor y cariño como se lo merecen ellos.
                    </p>

                    <div className="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4">
                        {!auth.user ? (
                            <>
                                <Link
                                    href={route('register')}
                                    className="bg-[#00a2c7] hover:bg-[#008cb0] text-white font-bold px-8 py-3.5 rounded-md shadow-md hover:shadow-lg transition-all duration-200 text-base"
                                >
                                    Comenzar como Cliente
                                </Link>
                                <Link
                                    href={route('login')}
                                    className="bg-white border border-gray-300 text-slate-700 hover:bg-gray-50 font-bold px-8 py-3.5 rounded-md shadow-sm transition-all duration-200 text-base"
                                >
                                    Acceso de Personal
                                </Link>
                            </>
                        ) : (
                            <Link
                                href={route('dashboard')}
                                className="bg-[#00a2c7] hover:bg-[#008cb0] text-white font-bold px-8 py-3.5 rounded-md shadow-md transition-all text-base"
                            >
                                Volver a tu Panel de Control
                            </Link>
                        )}
                    </div>
                </main>

                {/* Footer Simplificado Exacto */}
                <footer className="w-full text-center py-6 bg-white border-t border-gray-200 text-sm font-semibold text-slate-500">
                    <p>&copy; {new Date().getFullYear()} Pet Spa</p>
                </footer>
            </div>
        </>
    );
}