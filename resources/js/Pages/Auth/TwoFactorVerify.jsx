import { useForm } from '@inertiajs/react';

export default function TwoFactorVerify() {
    const { data, setData, post, processing, errors } = useForm({ code: '' });

    const submit = (e) => {
        e.preventDefault();
        post(route('2fa.verify.store'));
    };

    return (
        <div className="min-h-screen flex flex-col justify-center items-center bg-gray-100">
            <div className="w-full max-w-md p-8 bg-white shadow-lg rounded-lg">
                <h2 className="text-2xl font-bold text-center mb-6">Verificación de Seguridad</h2>
                <p className="text-gray-600 mb-6 text-center">Ingrese el código de su aplicación Authenticator para continuar.</p>
                
                <form onSubmit={submit}>
                    <input 
                        type="text" 
                        value={data.code} 
                        onChange={e => setData('code', e.target.value)}
                        className="w-full text-center text-3xl tracking-widest border-gray-300 rounded-md"
                        placeholder="000000"
                        maxLength="6"
                        required
                    />
                    {errors.code && <p className="text-red-500 text-sm mt-2">{errors.code}</p>}
                    
                    <button 
                        className="w-full mt-6 bg-indigo-600 text-white py-3 rounded-lg font-bold hover:bg-indigo-700"
                        disabled={processing}
                    >
                        Confirmar Acceso
                    </button>
                </form>
            </div>
        </div>
    );
}