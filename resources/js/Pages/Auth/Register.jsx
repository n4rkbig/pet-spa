import InputError from '@/Components/InputError';
import InputLabel from '@/Components/InputLabel';
import PrimaryButton from '@/Components/PrimaryButton';
import TextInput from '@/Components/TextInput';
import GuestLayout from '@/Layouts/GuestLayout';
import { Head, Link, useForm } from '@inertiajs/react';

export default function Register() {
    const { data, setData, post, processing, errors, reset } = useForm({
        name: '', // Recuerda que en el controlador mapearemos esto a 'nombre_usuario'
        email: '',
        password: '',
        password_confirmation: '',
    });

    // Lógica para calcular la fuerza de la contraseña (Requerimiento 3.1)
    const getStrength = (password) => {
        let strength = 0;
        if (password.length >= 8) strength++; // Longitud mínima
        if (/[A-Z]/.test(password)) strength++; // Mayúsculas
        if (/[0-9]/.test(password)) strength++; // Números
        if (/[^A-Za-z0-9]/.test(password)) strength++; // Símbolos
        return strength;
    };

    const strength = getStrength(data.password);

    const submit = (e) => {
        e.preventDefault();
        post(route('register'), {
            onFinish: () => reset('password', 'password_confirmation'),
        });
    };

    return (
        <GuestLayout>
            <Head title="Registro de Cliente" />

            <form onSubmit={submit}>
                <div>
                    <InputLabel htmlFor="name" value="Nombre de Usuario" />
                    <TextInput
                        id="name"
                        name="name"
                        value={data.name}
                        className="mt-1 block w-full"
                        autoComplete="name"
                        isFocused={true}
                        onChange={(e) => setData('name', e.target.value)}
                        required
                    />
                    <InputError message={errors.name} className="mt-2" />
                </div>

                <div className="mt-4">
                    <InputLabel htmlFor="email" value="Correo Electrónico" />
                    <TextInput
                        id="email"
                        type="email"
                        name="email"
                        value={data.email}
                        className="mt-1 block w-full"
                        autoComplete="username"
                        onChange={(e) => setData('email', e.target.value)}
                        required
                    />
                    <InputError message={errors.email} className="mt-2" />
                </div>

                {/* Campo de Contraseña con Medidor de Fuerza */}
                <div className="mt-4">
                    <InputLabel htmlFor="password" value="Contraseña" />
                    <TextInput
                        id="password"
                        type="password"
                        name="password"
                        value={data.password}
                        className="mt-1 block w-full"
                        autoComplete="new-password"
                        onChange={(e) => setData('password', e.target.value)}
                        required
                    />

                    {/* Visualización del Medidor de Fuerza */}
                    <div className="mt-2 flex gap-1 h-1.5">
                        {[...Array(4)].map((_, i) => (
                            <div
                                key={i}
                                className={`flex-1 rounded-full transition-colors duration-500 ${
                                    i < strength
                                        ? ['bg-red-400', 'bg-yellow-400', 'bg-orange-400', 'bg-green-500'][strength - 1]
                                        : 'bg-gray-200'
                                }`}
                            />
                        ))}
                    </div>
                    <p className="text-[10px] text-gray-500 mt-1 uppercase tracking-wider">
                        {strength === 0 && 'Muy débil'}
                        {strength === 1 && 'Débil (Usa 8+ caracteres)'}
                        {strength === 2 && 'Media (Agrega números)'}
                        {strength === 3 && 'Fuerte (Agrega mayúsculas)'}
                        {strength === 4 && 'Excelente (Seguridad máxima)'}
                    </p>

                    <InputError message={errors.password} className="mt-2" />
                </div>

                <div className="mt-4">
                    <InputLabel
                        htmlFor="password_confirmation"
                        value="Confirmar Contraseña"
                    />
                    <TextInput
                        id="password_confirmation"
                        type="password"
                        name="password_confirmation"
                        value={data.password_confirmation}
                        className="mt-1 block w-full"
                        autoComplete="new-password"
                        onChange={(e) => setData('password_confirmation', e.target.value)}
                        required
                    />
                    <InputError message={errors.password_confirmation} className="mt-2" />
                </div>

                <div className="mt-4 flex items-center justify-end">
                    <Link
                        href={route('login')}
                        className="rounded-md text-sm text-gray-600 underline hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
                    >
                        ¿Ya tienes cuenta? Inicia sesión
                    </Link>

                    <PrimaryButton className="ms-4" disabled={processing}>
                        Registrarse
                    </PrimaryButton>
                </div>
            </form>
        </GuestLayout>
    );
}