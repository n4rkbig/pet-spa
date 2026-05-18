# Pet Spa - Sistema de Gestión Operativa Seguro

Plataforma de gestión operativa para mascotas desarrollada bajo estándares de seguridad y trazabilidad forense orientada a mitigar vectores de ataque del OWASP Top 10.

## Tecnologías Utilizadas
* Backend: Laravel 13 / PHP 8.3+
* Frontend: React + Inertia.js (Tailwind CSS)
* Base de Datos: PostgreSQL

## Características de Seguridad Implementadas
1. Arquitectura de Roles (RBAC): Control de acceso vertical y horizontal estricto para roles (SuperAdmin, Recepción, Groomer, Cliente).
2. Trazabilidad Forense (Logs de Auditoría): Registro inalterable en la base de datos de cada acción crítica (Usuario, Fecha/Hora, Acción, IP y User-Agent), capturando intentos anónimos o fallidos de inicio de sesión.
3. Mitigación de Fuerza Bruta: Políticas de bloqueo de cuenta persistente en PostgreSQL tras 5 intentos fallidos y Rate Limiting a nivel de ruta (throttle:login).
4. Protección de Cuentas Críticas: Restricciones en controladores que impiden la auto-suspensión o auto-eliminación del Administrador raíz.
5. Hardening de Entorno: Desactivación del modo de depuración (APP_DEBUG=false) y cifrado de cookies de sesión para prevenir fugas de información.

## Instrucciones de Despliegue Local (Para Auditoría / Pentesting)

1. Clonar el repositorio:
   ```bash
   git clone [https://github.com/n4rkbig/pet-spa.git](https://github.com/n4rkbig/pet-spa.git)
   cd pet-spa
   # Pet Spa - Sistema de Gestión Operativa Seguro

Plataforma de gestión operativa para mascotas desarrollada bajo estándares de seguridad y trazabilidad forense orientada a mitigar vectores de ataque del OWASP Top 10.

## Tecnologías Utilizadas
* Backend: Laravel 13 / PHP 8.3+
* Frontend: React + Inertia.js (Tailwind CSS)
* Base de Datos: PostgreSQL

## Características de Seguridad Implementadas
1. Arquitectura de Roles (RBAC): Control de acceso vertical y horizontal estricto para roles (SuperAdmin, Recepción, Groomer, Cliente).
2. Trazabilidad Forense (Logs de Auditoría): Registro inalterable en la base de datos de cada acción crítica (Usuario, Fecha/Hora, Acción, IP y User-Agent), capturando intentos anónimos o fallidos de inicio de sesión.
3. Mitigación de Fuerza Bruta: Políticas de bloqueo de cuenta persistente en PostgreSQL tras 5 intentos fallidos y Rate Limiting a nivel de ruta (throttle:login).
4. Protección de Cuentas Críticas: Restricciones en controladores que impiden la auto-suspensión o auto-eliminación del Administrador raíz.
5. Hardening de Entorno: Desactivación del modo de depuración (APP_DEBUG=false) y cifrado de cookies de sesión para prevenir fugas de información.

## Instrucciones de Despliegue Local (Para Auditoría / Pentesting)

1. Clonar el repositorio:

   ```bash
   git clone [https://github.com/n4rkbig/pet-spa.git](https://github.com/n4rkbig/pet-spa.git)
   cd pet-spa

2. Instalar dependencias del Backend (PHP):

    ```Bash
    composer install

3. Instalar dependencias del Frontend (JavaScript):

    ```Bash

    npm install
    npm run dev

4. Configurar el entorno:

    - Duplica el archivo de ejemplo: cp .env.example .env

    - Genera la llave de seguridad: php artisan key:generate

    - Abre el archivo .env y configura las credenciales de tu PostgreSQL local junto con el entorno seguro:

    ```Ini, TOML

        APP_ENV=production
        APP_DEBUG=false

        DB_CONNECTION=pgsql
        DB_HOST=127.0.0.1
        DB_PORT=5432
        DB_DATABASE=spa_mascotas_db
        DB_USERNAME=tu_usuario_postgres
        DB_PASSWORD=tu_contraseña_postgres

5. Importar la Base de Datos:

    - Crea una base de datos en pgAdmin llamada spa_mascotas_db.

    - Ejecuta e importa el script estructurado que se encuentra en la carpeta bdd/database.sql.

6. Iniciar el sistema:

    ```Bash

    php artisan serve