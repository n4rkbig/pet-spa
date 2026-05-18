import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head } from '@inertiajs/react';

export default function LogsIndex({ auth, logs }) {
    return (
        <AuthenticatedLayout
            user={auth.user}
            header={<h2 className="font-semibold text-xl text-gray-800 leading-tight">Panel de Trazabilidad y Auditoría</h2>}
        >
            <Head title="Logs del Sistema" />

            <div className="py-12">
                <div className="max-w-7xl mx-auto sm:px-6 lg:px-8">
                    <div className="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6 border border-gray-200">
                        <div className="mb-6 flex justify-between items-center">
                            <div>
                                <h3 className="text-lg font-bold text-red-600">Historial de Eventos Críticos</h3>
                                <p className="text-sm text-gray-500 italic">Registros persistentes del esquema "log_auditoria"</p>
                            </div>
                            <span className="bg-gray-100 text-gray-600 text-xs font-bold px-3 py-1 rounded-full border">
                                Total Registros: {logs.length}
                            </span>
                        </div>

                        <div className="overflow-x-auto">
                            <table className="min-w-full divide-y divide-gray-200 border">
                                <thead className="bg-gray-800">
                                    <tr>
                                        <th className="px-4 py-3 text-left text-xs font-bold text-white uppercase">Timestamp</th>
                                        <th className="px-4 py-3 text-left text-xs font-bold text-white uppercase">Usuario</th>
                                        <th className="px-4 py-3 text-left text-xs font-bold text-white uppercase">Acción</th>
                                        <th className="px-4 py-3 text-left text-xs font-bold text-white uppercase">Dirección IP</th>
                                        <th className="px-4 py-3 text-left text-xs font-bold text-white uppercase">Dispositivo/Navegador</th>
                                    </tr>
                                </thead>
                                <tbody className="bg-white divide-y divide-gray-200">
                                    {logs.map((log) => (
                                        <tr key={log.id_log} className="hover:bg-yellow-50 transition">
                                            <td className="px-4 py-3 whitespace-nowrap text-xs font-mono text-gray-600">
                                                {new Date(log.fecha_hora).toLocaleString()}
                                            </td>
                                            <td className="px-4 py-3">
                                                <div className="text-xs font-bold text-gray-900">{log.nombre_responsable}</div>
                                                <div className="text-xs text-gray-500">{log.email_responsable}</div>
                                            </td>
                                            <td className="px-4 py-3">
                                                <span className="px-2 py-1 text-[10px] font-bold rounded bg-indigo-100 text-indigo-700 border border-indigo-200">
                                                    {log.accion}
                                                </span>
                                            </td>
                                            <td className="px-4 py-3 text-xs font-bold text-gray-700">
                                                {log.ip}
                                            </td>
                                            <td className="px-4 py-3 text-[10px] text-gray-400 max-w-xs truncate" title={log.navegador}>
                                                {log.navegador}
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>

                        {logs.length === 0 && (
                            <div className="text-center py-10 text-gray-400">No hay registros de auditoría disponibles.</div>
                        )}
                    </div>
                </div>
            </div>
        </AuthenticatedLayout>
    );
}