import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import InputError from '@/Components/InputError';
import PrimaryButton from '@/Components/PrimaryButton';
import TextInput from '@/Components/TextInput';
import { Head, useForm } from '@inertiajs/react';

export default function TwoFactorSetup({ auth, qrImage, secret }) {
    const { data, setData, post, processing, errors, reset } = useForm({
        code: '',
        secret: secret, // El secreto que viene del controlador
    });

    const submit = (e) => {
        e.preventDefault();
        post(route('2fa.enable'), {
            onFinish: () => reset('code'),
        });
    };

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={<h2 className="font-semibold text-xl text-gray-800 leading-tight">Seguridad Avanzada</h2>}
        >
            <Head title="Configurar 2FA" />

            <div className="py-12">
                <div className="max-w-2xl mx-auto sm:px-6 lg:px-8">
                    <div className="bg-white overflow-hidden shadow-sm sm:rounded-lg p-8 border">
                        <h3 className="text-lg font-bold mb-4 text-center">Activar Autenticación (2FA)</h3>
                        
                        <p className="mb-6 text-gray-600 text-center">
                            Escanea este código con <strong>Google Authenticator</strong>. 
                            Si no puedes usar la cámara, ingresa la clave manual.
                        </p>

                        {/* Imagen del QR */}
                        <div className="flex justify-center mb-8 border-4 border-gray-100 p-4 rounded-xl inline-block mx-auto max-w-max bg-white">
                            <img src={qrImage} alt="QR Code" className="w-48 h-48" />
                        </div>

                        {/* Clave Manual */}
                        <div className="bg-gray-50 p-4 rounded-lg mb-6 border border-dashed border-gray-300">
                            <p className="text-sm text-gray-500 font-mono text-center">
                                Clave manual: <span className="font-bold text-gray-800 uppercase tracking-widest">{secret}</span>
                            </p>
                        </div>

                        {/* Formulario de Validación */}
                        <form onSubmit={submit} className="space-y-4 max-w-sm mx-auto">
                            <div>
                                <label className="block font-medium text-sm text-gray-700 mb-2 text-center">
                                    Ingresa el código de 6 dígitos:
                                </label>
                                
                                <TextInput
                                    id="code"
                                    type="text"
                                    name="code"
                                    value={data.code}
                                    className="mt-1 block w-full text-center text-2xl tracking-widest font-bold"
                                    onChange={(e) => setData('code', e.target.value)}
                                    placeholder="000000"
                                    required
                                    maxLength="6"
                                />

                                <InputError message={errors.code} className="mt-2 text-center" />
                            </div>

                            <div className="flex items-center justify-center mt-6">
                                <PrimaryButton className="w-full justify-center py-3" disabled={processing}>
                                    {processing ? 'Verificando...' : 'Validar y Activar 2FA'}
                                </PrimaryButton>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </AuthenticatedLayout>
    );
}