--
-- PostgreSQL database dump
--

\restrict VXCdINCdINCXxc6wOxMPjt04hDpWadTXKDpXVKG9tC5BtWza055zN2msySJ48gX

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-05-17 21:55:58

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 3 (class 3079 OID 16695)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 5178 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 2 (class 3079 OID 16392)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 5179 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 931 (class 1247 OID 16454)
-- Name: canal_notif; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.canal_notif AS ENUM (
    'EMAIL',
    'WHATSAPP',
    'SMS'
);


ALTER TYPE public.canal_notif OWNER TO postgres;

--
-- TOC entry 919 (class 1247 OID 16414)
-- Name: estado_cita; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.estado_cita AS ENUM (
    'PENDIENTE',
    'CONFIRMADA',
    'EN_CURSO',
    'COMPLETADA',
    'CANCELADA'
);


ALTER TYPE public.estado_cita OWNER TO postgres;

--
-- TOC entry 922 (class 1247 OID 16426)
-- Name: estado_ficha; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.estado_ficha AS ENUM (
    'ABIERTA',
    'CERRADA'
);


ALTER TYPE public.estado_ficha OWNER TO postgres;

--
-- TOC entry 925 (class 1247 OID 16432)
-- Name: tamano_pet; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.tamano_pet AS ENUM (
    'XS',
    'S',
    'M',
    'L',
    'XL'
);


ALTER TYPE public.tamano_pet OWNER TO postgres;

--
-- TOC entry 928 (class 1247 OID 16444)
-- Name: temperamento_pet; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.temperamento_pet AS ENUM (
    'TRANQUILO',
    'NERVIOSO',
    'AGRESIVO',
    'DESCONOCIDO'
);


ALTER TYPE public.temperamento_pet OWNER TO postgres;

--
-- TOC entry 283 (class 1255 OID 16761)
-- Name: controlar_acceso_fallido(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.controlar_acceso_fallido(p_email character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE USUARIO 
    SET intentos_fallidos = intentos_fallidos + 1,
        bloqueado_hasta = CASE 
            WHEN intentos_fallidos + 1 >= 5 THEN NOW() + INTERVAL '15 minutes' 
            ELSE NULL 
        END
    WHERE email = p_email;
END;
$$;


ALTER FUNCTION public.controlar_acceso_fallido(p_email character varying) OWNER TO postgres;

--
-- TOC entry 285 (class 1255 OID 16833)
-- Name: generar_token_activacion(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.generar_token_activacion(p_email character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_token VARCHAR(255);
BEGIN
    v_token := encode(gen_random_bytes(32), 'hex');
    
    UPDATE USUARIO 
    SET token_activacion = v_token,
        token_expiracion = NOW() + INTERVAL '15 minutes' -- 
    WHERE email = p_email;
    
    RETURN v_token;
END;
$$;


ALTER FUNCTION public.generar_token_activacion(p_email character varying) OWNER TO postgres;

--
-- TOC entry 286 (class 1255 OID 16851)
-- Name: limpiar_sesiones_expiradas(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.limpiar_sesiones_expiradas() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Elimina sesiones que ya pasaron su fecha de expiración
    DELETE FROM SESION_USUARIO 
    WHERE fecha_expiracion < NOW();
END;
$$;


ALTER FUNCTION public.limpiar_sesiones_expiradas() OWNER TO postgres;

--
-- TOC entry 284 (class 1255 OID 16832)
-- Name: registrar_intento_fallido(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.registrar_intento_fallido(p_email character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE USUARIO 
    SET intentos_fallidos = intentos_fallidos + 1,
        bloqueado_hasta = CASE 
            WHEN intentos_fallidos + 1 >= 5 THEN NOW() + INTERVAL '15 minutes' 
            ELSE NULL 
        END
    WHERE email = p_email;
END;
$$;


ALTER FUNCTION public.registrar_intento_fallido(p_email character varying) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 227 (class 1259 OID 17015)
-- Name: cache; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cache (
    key character varying(255) NOT NULL,
    value text NOT NULL,
    expiration bigint NOT NULL
);


ALTER TABLE public.cache OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 17026)
-- Name: cache_locks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cache_locks (
    key character varying(255) NOT NULL,
    owner character varying(255) NOT NULL,
    expiration bigint NOT NULL
);


ALTER TABLE public.cache_locks OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 17068)
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.failed_jobs OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 17067)
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.failed_jobs_id_seq OWNER TO postgres;

--
-- TOC entry 5180 (class 0 OID 0)
-- Dependencies: 232
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- TOC entry 231 (class 1259 OID 17053)
-- Name: job_batches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_batches (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    total_jobs integer NOT NULL,
    pending_jobs integer NOT NULL,
    failed_jobs integer NOT NULL,
    failed_job_ids text NOT NULL,
    options text,
    cancelled_at integer,
    created_at integer NOT NULL,
    finished_at integer
);


ALTER TABLE public.job_batches OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 17038)
-- Name: jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
    queue character varying(255) NOT NULL,
    payload text NOT NULL,
    attempts smallint NOT NULL,
    reserved_at integer,
    available_at integer NOT NULL,
    created_at integer NOT NULL
);


ALTER TABLE public.jobs OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 17037)
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.jobs_id_seq OWNER TO postgres;

--
-- TOC entry 5181 (class 0 OID 0)
-- Dependencies: 229
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- TOC entry 234 (class 1259 OID 17086)
-- Name: log_auditoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log_auditoria (
    id_log uuid NOT NULL,
    rol character varying(255),
    fecha_hora timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ip inet NOT NULL,
    navegador text NOT NULL,
    accion character varying(255) NOT NULL,
    id_usuario bigint
);


ALTER TABLE public.log_auditoria OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16970)
-- Name: migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


ALTER TABLE public.migrations OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16969)
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migrations_id_seq OWNER TO postgres;

--
-- TOC entry 5182 (class 0 OID 0)
-- Dependencies: 221
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- TOC entry 225 (class 1259 OID 16994)
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


ALTER TABLE public.password_reset_tokens OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 17133)
-- Name: rol; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rol (
    id_rol integer NOT NULL,
    nombre_rol character varying(50) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.rol OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 17003)
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    id character varying(255) NOT NULL,
    user_id bigint,
    ip_address character varying(45),
    user_agent text,
    payload text NOT NULL,
    last_activity integer NOT NULL
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16980)
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario (
    id_usuario bigint CONSTRAINT users_id_not_null NOT NULL,
    name character varying(255) CONSTRAINT users_name_not_null NOT NULL,
    email character varying(255) CONSTRAINT users_email_not_null NOT NULL,
    email_verified_at timestamp(0) without time zone,
    password character varying(255) CONSTRAINT users_password_not_null NOT NULL,
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    "2fa_secreto" text,
    activo boolean DEFAULT true NOT NULL,
    id_rol integer DEFAULT 4,
    intentos_fallidos integer DEFAULT 0,
    bloqueado_hasta timestamp without time zone,
    "2fa_habilitado" boolean DEFAULT false
);


ALTER TABLE public.usuario OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16979)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 5183 (class 0 OID 0)
-- Dependencies: 223
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.usuario.id_usuario;


--
-- TOC entry 4974 (class 2604 OID 17071)
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- TOC entry 4973 (class 2604 OID 17041)
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- TOC entry 4967 (class 2604 OID 16973)
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- TOC entry 4968 (class 2604 OID 16983)
-- Name: usuario id_usuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id_usuario SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 5164 (class 0 OID 17015)
-- Dependencies: 227
-- Data for Name: cache; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cache (key, value, expiration) FROM stdin;
\.


--
-- TOC entry 5165 (class 0 OID 17026)
-- Dependencies: 228
-- Data for Name: cache_locks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cache_locks (key, owner, expiration) FROM stdin;
\.


--
-- TOC entry 5170 (class 0 OID 17068)
-- Dependencies: 233
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.failed_jobs (id, uuid, connection, queue, payload, exception, failed_at) FROM stdin;
\.


--
-- TOC entry 5168 (class 0 OID 17053)
-- Dependencies: 231
-- Data for Name: job_batches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_batches (id, name, total_jobs, pending_jobs, failed_jobs, failed_job_ids, options, cancelled_at, created_at, finished_at) FROM stdin;
\.


--
-- TOC entry 5167 (class 0 OID 17038)
-- Dependencies: 230
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jobs (id, queue, payload, attempts, reserved_at, available_at, created_at) FROM stdin;
\.


--
-- TOC entry 5171 (class 0 OID 17086)
-- Dependencies: 234
-- Data for Name: log_auditoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log_auditoria (id_log, rol, fecha_hora, ip, navegador, accion, id_usuario) FROM stdin;
adbfb2be-63e6-499b-a8e3-a3586c1dce7b	1	2026-05-08 08:33:30	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	\N
d77eff5a-9861-4381-b0af-1a9260865b8e	1	2026-05-08 08:41:59	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
1d4858c9-4be9-4951-a549-98af74fb3011	1	2026-05-08 08:42:16	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
df1bf91d-c321-4627-864c-1aa06ac2885d	1	2026-05-08 08:42:27	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
62698e1c-3ec9-4fc7-a284-af69ff6f7f76	1	2026-05-08 08:42:42	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
760f55a2-e380-4614-bdf0-cb15525663ac	1	2026-05-08 08:44:51	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
eeb3f458-c1c9-4d77-b920-52994990f3a0	1	2026-05-08 08:45:07	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
f1b76c59-c986-4394-ab55-455d95244c20	1	2026-05-08 08:45:07	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
7f5094a4-035d-4610-a20c-9a37cca17315	1	2026-05-08 09:00:27	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
12a274f3-bef1-4960-93bc-20105de1d8d1	1	2026-05-08 09:00:44	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
2cc1bc89-c1c0-4c95-8ad3-be8505511680	1	2026-05-08 09:00:44	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
a9c0645d-0f01-4b5e-98e0-9bcbcabaad6e	1	2026-05-08 09:58:04	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	CREACIÓN DE PERSONAL: Admin registró a juan@petspa.com (Rol: 2)	1
896bb1c0-8fd0-4d30-a959-ed24562fe917	1	2026-05-08 10:36:00	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	SUSPENSIÓN de cuenta: juan@petspa.com	1
e037e781-2bc8-42b1-bd34-8de8ff6e5fe4	1	2026-05-08 10:36:06	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACTIVACIÓN de cuenta: juan@petspa.com	1
dd21133c-fca8-4891-b136-f4b6941c8c27	1	2026-05-08 10:37:34	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	SUSPENSIÓN de cuenta: juan@petspa.com	1
71635697-9e77-4b7f-b2a7-70cabecdcfae	1	2026-05-08 10:37:39	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACTIVACIÓN de cuenta: juan@petspa.com	1
02d9bb4f-093c-4bff-bbd3-5de7c5a834f1	1	2026-05-08 10:48:45	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACTUALIZACIÓN: Datos editados y clave restablecida para juan@petspa.com	1
1a2f7556-fcc4-4253-a8d8-02879cce25d7	1	2026-05-08 10:49:01	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	SUSPENSIÓN de cuenta: juan@petspa.com	1
a23921da-2408-4c13-beb5-7769f556980f	1	2026-05-08 10:49:04	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACTIVACIÓN de cuenta: juan@petspa.com	1
56bbeca4-fb1e-480d-a500-3143da42daf6	1	2026-05-08 10:49:10	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
f4e530f2-6578-4c63-907c-19a886f08e12	2	2026-05-08 10:49:24	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	2
efc982ea-397e-40c9-81ea-6c06be50f255	2	2026-05-08 10:49:24	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	2
4e06a7b5-a1f3-46ba-8f6c-7c30f18d8916	2	2026-05-08 10:49:51	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	2
99246c8d-df02-422e-9b55-27fb52ff137c	1	2026-05-08 10:50:16	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
82d9b37e-b310-405e-a3f8-9c453c1f647a	1	2026-05-08 10:50:16	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
973abbae-f0e1-4633-8e5b-92b81e3e99ac	1	2026-05-08 10:53:41	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ELIMINACIÓN: Usuario juan@petspa.com eliminado del sistema.	1
541e2567-d077-494e-9542-ae2c832af9d8	1	2026-05-08 10:53:58	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	CREACIÓN: Admin registró a juan@petspa.com con clave inicial.	1
127657df-c4a6-4d70-b53d-c2d4b59ad39c	1	2026-05-08 10:54:02	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
d3337f8b-50a6-4f94-b5fd-e7d2ea321d23	2	2026-05-08 10:54:13	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	3
be0d5897-5360-4e0c-b173-6d582e5fe590	2	2026-05-08 10:54:13	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	3
d30f968e-39ba-49cf-8e74-ce2ebbcbfca3	2	2026-05-08 10:54:21	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	3
90afd61c-69e0-4957-a65b-4b7c5f208803	2	2026-05-08 10:55:31	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	3
533b952f-0503-4ea9-9899-ca24fdd2f538	2	2026-05-08 10:55:31	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	3
7fe003af-b7d7-4fec-8f11-be4de1d16e93	2	2026-05-08 10:56:49	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	3
8c80c7ea-c800-439f-983d-fec42d181551	2	2026-05-08 10:57:15	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	3
5bc9579a-3fe3-40c6-a834-3eb7f4546bf8	2	2026-05-08 10:57:15	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	3
e5df984e-790a-4ca6-b4b1-b9f630dce47a	2	2026-05-08 10:59:37	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	3
cd6a9087-aaae-413d-8470-bc12c6ca6ade	1	2026-05-08 10:59:54	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
685ced42-e980-44b9-b972-f67b77193c6d	1	2026-05-08 10:59:54	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
0587ad4d-1f1d-4463-9141-600c2f19a849	1	2026-05-08 11:00:02	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACTUALIZACIÓN: Datos editados y clave restablecida para juan@petspa.com	1
39582082-73ad-40f2-b386-cfe6c13a8392	1	2026-05-08 11:00:07	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
6bcecbc9-8795-4444-89d0-49512cc98a32	2	2026-05-08 11:00:40	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	3
2c13aea1-fee9-44d0-89b0-3db8f9822fc1	2	2026-05-08 11:00:40	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	3
ed6e1e8d-8699-4a32-b695-1179dc88980e	2	2026-05-08 11:02:42	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	3
a0cf3af8-0046-4375-9519-51f295a72b4c	1	2026-05-08 11:03:06	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
336788e9-1876-42bb-8f3c-0358cc3e46e7	1	2026-05-08 11:03:06	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
6960686d-7af1-468e-8202-88a834aa3988	1	2026-05-08 11:03:46	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	SUSPENSIÓN de cuenta: juan@petspa.com	1
dcb92ccf-905d-42c8-bae8-8bd162dfe92b	1	2026-05-08 11:03:50	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
80db47d3-c61b-4841-a310-d4ffcf8304dc	2	2026-05-08 11:04:04	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	3
eb58f7c9-578f-4f40-a407-8ef2fa9473e0	2	2026-05-08 11:04:57	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	3
2a5d878b-d8d8-44ac-bdd8-2b26b126b2d4	1	2026-05-08 11:05:24	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
8c9aefb6-ff44-4c1c-9d69-42cfd56ef712	1	2026-05-08 11:05:24	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
101a778c-a590-458d-9576-9864bdde0280	1	2026-05-08 11:16:03	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
76d7d285-22b8-4e0c-99ac-d702d68ca633	2	2026-05-08 11:16:12	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Intento de acceso: CUENTA SUSPENDIDA	3
de38530f-6c6a-45fb-b049-475c6313ebc6	1	2026-05-08 11:16:37	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
c2dbe9c6-6524-449c-8605-8008b0ec87e3	1	2026-05-08 11:16:38	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
dd3ffaa1-92f8-4df2-acd4-3a637f191f2e	1	2026-05-08 11:16:44	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACTIVACIÓN de cuenta: juan@petspa.com	1
61e37288-ea10-48d9-95ac-c93a36112a80	1	2026-05-08 11:16:57	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
d1b56be4-19f0-4c08-9af7-6608ce635666	2	2026-05-08 11:17:06	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	3
4367cc2c-2295-4079-9391-3123f2493411	2	2026-05-08 11:17:06	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	3
b3b40f53-c83b-417f-b18b-4e6a91c87b96	2	2026-05-08 11:31:06	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	3
bb7b4fa0-cf73-433f-a9c6-9a47e4b98b61	1	2026-05-08 11:35:05	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
e18d214d-fa8c-44ce-bb39-73f15c9ec747	1	2026-05-08 11:35:05	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
9e4e1af8-8a1c-4eb4-be80-b8bb01d74680	1	2026-05-08 11:35:36	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	CREACIÓN: Admin registró a ana@petspa.com con clave inicial.	1
a690c3b6-24df-4005-9e7b-d81aa8f42420	1	2026-05-08 11:39:38	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	SUSPENSIÓN de cuenta: juan@petspa.com	1
36f5b037-268b-4654-a192-8a4998b4d878	1	2026-05-08 11:40:13	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
57de31c3-8447-4adc-9444-cd169d80e368	2	2026-05-08 11:40:28	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Intento de acceso: CUENTA SUSPENDIDA	3
d0ff95e2-71e5-4b84-882b-2e1da65f4224	1	2026-05-08 11:48:56	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
ee4f5baf-5480-4514-b36d-29d6d674680c	1	2026-05-08 11:48:56	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
3381401d-6d03-40f7-9e50-0d6dc1845959	1	2026-05-08 11:54:06	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
4b64b254-d042-445f-b6f9-296117fd15ad	1	2026-05-08 11:54:57	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
8addaee7-4e10-4ade-9605-8438ecbd782a	1	2026-05-08 11:54:57	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
abe9e89d-8251-45bc-8238-34b268bf538b	1	2026-05-08 11:55:22	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	CREACIÓN: Admin registró a pedro@petspa.com con clave inicial.	1
6df3ca1f-7082-42c9-9b0e-d82ddf8e7fbd	1	2026-05-08 11:55:30	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
c278b25d-cc76-4533-9795-0ac3d7946f3d	3	2026-05-08 11:55:59	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	5
628e171c-2a1c-4dbf-857d-f001ade42c38	3	2026-05-08 11:55:59	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	5
d877a1c9-5a53-4561-bca1-2f7c9724d442	3	2026-05-08 11:56:10	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	5
8333ea76-bb5e-4164-8ee2-066ab9d58f4b	3	2026-05-08 11:56:26	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	5
27feadb9-ef7c-4987-ac8f-4bbd57546676	3	2026-05-08 11:56:26	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	5
c4b403d3-f988-404d-9e44-554e8d6cda3c	3	2026-05-08 11:57:19	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	5
b88ef238-0470-4ce0-8183-94be3e48288f	3	2026-05-08 12:01:58	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	4
3e241664-ffae-4660-a9d0-d37a3027ee6a	3	2026-05-08 12:01:59	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	4
0fed363c-95df-4147-ac30-b4aae8b8ccb2	3	2026-05-08 12:02:03	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	4
ca4f67c4-4c9b-47dd-b386-7b7d8f61fe38	2	2026-05-08 12:03:15	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Intento de acceso: CUENTA SUSPENDIDA	3
ee862174-be7a-4b20-8202-98cffbaa1e61	1	2026-05-08 12:03:43	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
b934b159-95b9-4f13-a7db-f18b4d6e4bfc	1	2026-05-08 12:03:43	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
b577e288-2d69-43b8-b95c-4183f9889fbd	1	2026-05-08 12:03:58	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACTIVACIÓN de cuenta: juan@petspa.com	1
d8aae4d9-a344-49b8-aa85-00c296ac3781	1	2026-05-08 12:04:04	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	SUSPENSIÓN de cuenta: juan@petspa.com	1
c28c7e97-a8b2-41c6-83c7-ac794c0ab709	1	2026-05-08 12:04:14	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ELIMINACIÓN: Usuario pedro@petspa.com eliminado del sistema.	1
e52ffed9-445d-4879-9998-00906cdb00ca	1	2026-05-08 12:05:27	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACTIVACIÓN de cuenta: juan@petspa.com	1
8440f731-b6ed-4e79-abd8-2dcd3a7ce56f	1	2026-05-08 12:05:31	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
79d2d1f3-dbd0-4dd9-a05e-472fd9251c96	2	2026-05-08 12:05:45	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	3
338e473d-6d3d-4ea7-9fb3-87fc254cf5d2	2	2026-05-08 12:05:45	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	3
9d1bd717-a7cb-4448-88fc-4254d0782a5f	1	2026-05-12 16:01:56	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
93805c7f-92c1-4ec6-b1a8-11bcde2b6a34	1	2026-05-12 16:01:56	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
2c51d23d-ec96-4b7b-a9c4-9d644201f189	1	2026-05-12 16:03:50	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
a98a980c-e7fb-49cc-bddc-d4f60c02c469	2	2026-05-12 16:05:11	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	3
3790cfcb-c728-4b87-8889-c805038795cc	2	2026-05-12 16:05:11	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	3
65a7ef5f-5a58-4a85-a106-e1365dbcc9d0	2	2026-05-12 16:11:43	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	3
cfffebba-1b68-4997-8bd5-0979d635ef58	1	2026-05-12 16:12:15	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
cc08f1d9-f6f0-4a67-9a60-9a943ee09c27	1	2026-05-12 16:12:15	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
4e5d5d56-7030-46a8-9a32-72f49668f157	1	2026-05-12 16:16:51	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
fc9ba067-9bac-4767-930f-731052da38cc	1	2026-05-12 17:08:08	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
0f6b2708-26ad-4324-879f-15c0d22c5256	1	2026-05-12 17:08:08	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
ed0c4eae-b024-4553-89c0-104ad14f7d79	1	2026-05-12 17:11:19	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	SUSPENSIÓN de cuenta: juan@petspa.com	1
af6279a9-1425-48b7-824d-ef1778db0fab	1	2026-05-12 17:11:25	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACTIVACIÓN de cuenta: juan@petspa.com	1
a3ec55fc-e7b5-466e-993a-992ea230c295	1	2026-05-12 17:11:49	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
44bfb27e-9373-4158-acc6-0f10d2594c86	1	2026-05-12 19:31:53	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
0f7de1f7-385e-4bc8-9ea7-782c4d5cc430	1	2026-05-12 19:31:53	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
74d184bf-6d36-433c-b5af-0355ef44e209	1	2026-05-13 23:06:50	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
10255a53-f208-4273-baab-75f53175fc4b	1	2026-05-13 23:06:50	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
dd630061-73c8-4693-a878-18dc737e3f79	1	2026-05-13 23:14:34	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	SEGURIDAD: El usuario habilitó exitosamente el 2FA.	1
caa26477-6b58-41aa-a690-d0dcbcf68dc7	1	2026-05-13 23:18:10	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
3b0b9e37-8d6b-409a-9999-807cf2954491	1	2026-05-13 23:19:13	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
be24d6ca-17a7-4013-94ca-86b496c5058a	1	2026-05-13 23:19:13	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
69ed2c9d-de9c-4000-a243-f5212c27063e	1	2026-05-13 23:19:31	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACCESO: Segundo factor verificado correctamente.	1
be536515-ceed-4fda-9b2a-1b6782b2894c	1	2026-05-13 23:19:35	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
b28ed21c-48b4-41a3-bd99-7f4079d53388	2	2026-05-13 23:20:06	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	3
cf244d38-49e2-4818-b015-31ebeda16e04	2	2026-05-13 23:20:06	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	3
d45fd051-372f-45a4-aed8-ab660054baa7	2	2026-05-13 23:20:42	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	3
1585481c-2602-43b0-999a-06e2099c944c	1	2026-05-13 23:21:00	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
d25a6cad-13ec-467a-8ea3-da9ff65dbefc	1	2026-05-13 23:21:00	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
adbf771a-8e50-4769-8223-3bf7c545cc34	1	2026-05-13 23:21:25	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACCESO: Segundo factor verificado correctamente.	1
36ea4e8a-2e66-4b6a-b148-bbd66c6e0583	1	2026-05-13 23:32:09	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
3ce2636d-567d-4cbd-86ed-42aef0005bcf	4	2026-05-13 23:53:17	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	AUTO-REGISTRO: Nuevo cliente registrado en el sistema.	6
82af13ea-4925-45af-b436-1f3b437eab46	4	2026-05-13 23:53:44	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	6
482651ac-4fbd-4b0d-b4ba-e5f288c61f6e	4	2026-05-13 23:54:14	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	6
e2ef4b44-c8bd-4bbf-bd4b-61975565afc9	4	2026-05-13 23:54:14	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	6
9f3ecb79-5151-4af0-a7cf-b8cfe0c282b1	4	2026-05-13 23:54:19	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	6
5c2031a3-2381-4ce8-846b-fe102095c097	1	2026-05-13 23:54:42	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
c9ca6247-8e51-48f1-bda4-2aa9f24dce40	1	2026-05-13 23:54:42	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
25590d60-b6fe-45ba-84db-22fd10ff6f09	1	2026-05-13 23:55:08	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACCESO: Segundo factor verificado correctamente.	1
548a7f14-bf56-444c-864a-d1a32547fec3	1	2026-05-14 01:41:24	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
84d150a8-8b60-469b-94f7-506a42781b27	3	2026-05-14 01:42:21	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	4
42eed9a2-46a5-4dd6-9ee6-72d44ceacf2a	3	2026-05-14 01:42:21	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	4
d0309462-60f8-473f-8755-02c170ac4bb9	3	2026-05-14 01:42:28	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	4
61f1c75c-4935-4056-bfa2-7c4c78a37dac	4	2026-05-14 01:43:09	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	6
e31ee9cc-84bb-47f1-8000-c0d7e042d720	4	2026-05-14 01:43:09	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	6
81690eb1-9bad-498f-a9f7-e5189c534706	4	2026-05-14 01:43:14	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	6
ef8fa75c-21ac-4ab2-984a-418f814e9d2c	1	2026-05-14 01:44:01	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
326fc9f6-9a79-4e7d-bb9c-627bf0c3ea51	1	2026-05-14 01:44:01	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
6618eaa5-de3f-40ab-9984-924eaea9cd22	1	2026-05-14 01:44:26	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACCESO: Segundo factor verificado correctamente.	1
b65af759-8ff5-4711-883f-2fc5fb206a5e	1	2026-05-14 15:08:16	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
a33b2845-64d6-4ee0-9f37-6d3a84d36113	1	2026-05-14 15:08:16	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
0575edd7-1d17-4b92-89de-54ef1cf4a6bb	1	2026-05-14 15:08:44	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACCESO: Segundo factor verificado correctamente.	1
70fe5116-a09f-4a80-9193-19c654be9d83	1	2026-05-14 15:11:52	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
d4f49f50-e851-4851-83f5-7cb5aca1673d	4	2026-05-14 15:19:28	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	6
3830d8cd-e26b-471a-b570-68040fe2da34	4	2026-05-14 15:19:28	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	6
487debea-ae28-480d-8d1d-1a8a4264a68a	4	2026-05-14 15:19:30	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACCESO DENEGADO: Intento de entrar a ruta restringida (admin/usuarios)	6
82dac510-1542-476d-899c-f1c35e70c405	4	2026-05-14 15:20:15	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	6
19f558a7-2eec-48ea-9505-770033ec61c4	1	2026-05-14 15:20:43	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
ef35f74e-88f6-4e81-a3c0-6c382fe75455	1	2026-05-14 15:20:43	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
ab1feb79-e8c7-4406-9989-47eaf1ca0bae	1	2026-05-14 15:21:07	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACCESO: Segundo factor verificado correctamente.	1
b16cffd6-2971-4294-9b09-7a61c9e41633	1	2026-05-14 15:22:46	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
17e73afc-4623-4ac8-a52d-963641480748	1	2026-05-14 15:23:33	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
cdeb5fc3-d952-4a21-8ddd-d04a3a3694c6	1	2026-05-14 15:23:33	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
3ad7e0a0-7041-4a49-a982-87cc2270cc32	1	2026-05-14 15:23:55	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACCESO: Segundo factor verificado correctamente.	1
4b036f59-438f-446e-a79f-20bc07f91f17	1	2026-05-14 15:24:25	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
40ec2218-6eab-4309-bedd-46ac1f191272	1	2026-05-14 15:28:29	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
7e48f3ba-2ce8-47eb-a49f-fcfa584cc89f	1	2026-05-14 15:28:29	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
abf91644-d73f-4f76-ac37-4b7c3b72d459	1	2026-05-14 15:28:47	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACCESO: Segundo factor verificado correctamente.	1
6573ea57-12fd-42e5-ab71-17ce83763cca	1	2026-05-14 16:10:06	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
d26d4f09-42eb-483e-a1d6-907ee6109f51	4	2026-05-14 16:10:32	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	6
e2fa0280-7d4a-4925-a7b6-7429ff1932b6	4	2026-05-14 16:10:32	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	6
1a674db2-8e3d-4bfc-b17e-a265470b04df	4	2026-05-14 16:10:55	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	6
0617dcda-9b45-4fad-b5ef-1edcc829c311	1	2026-05-14 17:05:15	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
f63931af-e6d5-46bd-9dac-6b79dd1a39f3	1	2026-05-14 17:05:15	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
7e6768b6-11cf-4898-8cc0-3618d61460d9	1	2026-05-14 17:05:29	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACCESO: Segundo factor verificado correctamente.	1
deef7ca7-226a-4aea-93ff-6a76fa97e6e0	1	2026-05-14 17:06:11	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	SUSPENSIÓN de cuenta: ana@petspa.com	1
10703a71-ac45-4f8c-9903-190e60c14d50	1	2026-05-14 17:08:52	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	1
1cfab8bf-baeb-4c76-9be5-442b68bb9ef4	3	2026-05-14 17:10:15	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Intento de acceso: CUENTA SUSPENDIDA	4
02f44ed2-794a-41cb-a27b-1bd977f7e602	4	2026-05-14 17:11:31	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	6
30c448b0-6522-4fe5-9a61-0437f0f6549f	4	2026-05-14 17:11:31	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	6
e548ec3d-4f5b-495f-b812-91b42a1c41c7	4	2026-05-14 17:12:00	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Cierre de sesión	6
7d2ca13b-1fda-4f57-a38c-f7ebcae88e4d	1	2026-05-18 01:12:07	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
9f6557d5-2d21-4825-a594-5036894798b2	1	2026-05-18 01:12:07	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	INGRESO: Inicio de sesión exitoso	1
812b653f-8af0-46f1-9ce0-fdc7d43a252a	1	2026-05-18 01:12:26	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACCESO: Segundo factor verificado correctamente.	1
14928efb-bb09-423e-b0ca-05fa4ae24b7d	1	2026-05-18 01:13:34	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	EGRESO: Cierre de sesión	1
2ec50abd-3916-4eb8-83a0-8c68e6106f2f	2	2026-05-18 01:13:41	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ALERTA: Intento fallido de inicio de sesión para el correo: juan@petspa.com	3
2368ae9d-a96e-4d87-87d9-59e4e4b8636c	2	2026-05-18 01:13:45	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ALERTA: Intento fallido de inicio de sesión para el correo: juan@petspa.com	3
35beff4c-6265-435e-b93b-4a4c6d42ab36	2	2026-05-18 01:13:48	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ALERTA: Intento fallido de inicio de sesión para el correo: juan@petspa.com	3
ff1b9b2f-5a9f-49ee-9032-e6a8ee778f9a	2	2026-05-18 01:13:51	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ALERTA: Intento fallido de inicio de sesión para el correo: juan@petspa.com	3
29f55e02-404b-414e-869e-ba7ffbbf901a	2	2026-05-18 01:13:54	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ALERTA: Intento fallido de inicio de sesión para el correo: juan@petspa.com	3
dfdd0bea-141d-41cb-b7c1-64f2622e7c4c	1	2026-05-18 01:15:38	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	Inicio de sesión exitoso	1
877614bc-c0d6-42a2-922a-12b39bff2eee	1	2026-05-18 01:15:38	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	INGRESO: Inicio de sesión exitoso	1
62481dc7-497b-4dc6-aabc-f17125d525e0	1	2026-05-18 01:15:50	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ACCESO: Segundo factor verificado correctamente.	1
346a5c37-2ed5-45be-9884-ef48168246a6	1	2026-05-18 01:16:45	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	EGRESO: Cierre de sesión	1
16813845-5f58-44f2-a7f1-6d8c57993522	2	2026-05-18 01:16:58	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ALERTA: Intento fallido de inicio de sesión para el correo: juan@petspa.com	3
9472737a-d0ac-4130-a2ef-972f8fb947ec	\N	2026-05-18 01:17:17	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ALERTA: Intento fallido de inicio de sesión para el correo: pedro@petspa.com	\N
ff050a6e-88de-4ca9-96db-ef440f3f9e3b	\N	2026-05-18 01:22:22	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:151.0) Gecko/20100101 Firefox/151.0	ALERTA: Intento fallido de inicio de sesión para el correo: pedro@petspa.com	\N
\.


--
-- TOC entry 5159 (class 0 OID 16970)
-- Dependencies: 222
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.migrations (id, migration, batch) FROM stdin;
1	0001_01_01_000000_create_users_table	1
2	0001_01_01_000001_create_cache_table	1
3	0001_01_01_000002_create_jobs_table	1
4	2026_05_08_063452_create_log_auditoria_table	1
5	2026_05_08_070807_add_2fa_columns_to_usuario_table	2
\.


--
-- TOC entry 5162 (class 0 OID 16994)
-- Dependencies: 225
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.password_reset_tokens (email, token, created_at) FROM stdin;
\.


--
-- TOC entry 5172 (class 0 OID 17133)
-- Dependencies: 235
-- Data for Name: rol; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rol (id_rol, nombre_rol, created_at, updated_at) FROM stdin;
1	Administrador	2026-05-13 19:42:25.360222	2026-05-13 19:42:25.360222
2	Recepción	2026-05-13 19:42:25.360222	2026-05-13 19:42:25.360222
3	Groomer	2026-05-13 19:42:25.360222	2026-05-13 19:42:25.360222
4	Cliente	2026-05-13 19:42:25.360222	2026-05-13 19:42:25.360222
\.


--
-- TOC entry 5163 (class 0 OID 17003)
-- Dependencies: 226
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sessions (id, user_id, ip_address, user_agent, payload, last_activity) FROM stdin;
\.


--
-- TOC entry 5161 (class 0 OID 16980)
-- Dependencies: 224
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuario (id_usuario, name, email, email_verified_at, password, remember_token, created_at, updated_at, "2fa_secreto", activo, id_rol, intentos_fallidos, bloqueado_hasta, "2fa_habilitado") FROM stdin;
3	Juan	juan@petspa.com	2026-05-08 10:55:08	$2y$12$q.B8tHRVKJyEXy1cqgUZ3exUtOQDFCrI8VkDL66s5qdPROXsv9LdK	\N	2026-05-08 10:53:58	2026-05-18 01:13:54	\N	t	2	0	2026-05-18 01:28:54	f
6	cliente	cliente1@email.com	\N	$2y$12$0rXqdxP6hE5nv0Q7EAtpoOP0NU8NMYKy0RN5NRAuKP9UNbS.GLZCu	\N	2026-05-13 23:53:17	2026-05-13 23:53:17	\N	t	4	0	\N	f
1	SuperAdmin	admin@petspa.com	2026-05-08 04:25:43	$2y$12$kNmOZV/w0WvJshXmyT8Tnu5fqGsbpfRPtkq5vMXtBcJPyAREoVr8a	\N	2026-05-08 04:07:43	2026-05-14 15:20:43	JKMUU7WUJ4UWINWA	t	1	0	\N	t
4	Ana	ana@petspa.com	\N	$2y$12$7l0nlVUSlRakq4PSFtmQCOk9ehkV6HJDVeSjAgevUHRcOXXYek5Nq	\N	2026-05-08 11:35:36	2026-05-14 01:42:21	\N	f	3	0	\N	f
\.


--
-- TOC entry 5184 (class 0 OID 0)
-- Dependencies: 232
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 1, false);


--
-- TOC entry 5185 (class 0 OID 0)
-- Dependencies: 229
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.jobs_id_seq', 1, false);


--
-- TOC entry 5186 (class 0 OID 0)
-- Dependencies: 221
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.migrations_id_seq', 5, true);


--
-- TOC entry 5187 (class 0 OID 0)
-- Dependencies: 223
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 6, true);


--
-- TOC entry 4996 (class 2606 OID 17035)
-- Name: cache_locks cache_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cache_locks
    ADD CONSTRAINT cache_locks_pkey PRIMARY KEY (key);


--
-- TOC entry 4993 (class 2606 OID 17024)
-- Name: cache cache_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cache
    ADD CONSTRAINT cache_pkey PRIMARY KEY (key);


--
-- TOC entry 5003 (class 2606 OID 17083)
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- TOC entry 5005 (class 2606 OID 17085)
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- TOC entry 5001 (class 2606 OID 17066)
-- Name: job_batches job_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_batches
    ADD CONSTRAINT job_batches_pkey PRIMARY KEY (id);


--
-- TOC entry 4998 (class 2606 OID 17051)
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- TOC entry 5007 (class 2606 OID 17099)
-- Name: log_auditoria log_auditoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_auditoria
    ADD CONSTRAINT log_auditoria_pkey PRIMARY KEY (id_log);


--
-- TOC entry 4980 (class 2606 OID 16978)
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- TOC entry 4986 (class 2606 OID 17002)
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);


--
-- TOC entry 5009 (class 2606 OID 17141)
-- Name: rol rol_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rol
    ADD CONSTRAINT rol_pkey PRIMARY KEY (id_rol);


--
-- TOC entry 4989 (class 2606 OID 17012)
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 4982 (class 2606 OID 16993)
-- Name: usuario users_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- TOC entry 4984 (class 2606 OID 17106)
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 4991 (class 1259 OID 17025)
-- Name: cache_expiration_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cache_expiration_index ON public.cache USING btree (expiration);


--
-- TOC entry 4994 (class 1259 OID 17036)
-- Name: cache_locks_expiration_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX cache_locks_expiration_index ON public.cache_locks USING btree (expiration);


--
-- TOC entry 4999 (class 1259 OID 17052)
-- Name: jobs_queue_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX jobs_queue_index ON public.jobs USING btree (queue);


--
-- TOC entry 4987 (class 1259 OID 17014)
-- Name: sessions_last_activity_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sessions_last_activity_index ON public.sessions USING btree (last_activity);


--
-- TOC entry 4990 (class 1259 OID 17013)
-- Name: sessions_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sessions_user_id_index ON public.sessions USING btree (user_id);


--
-- TOC entry 5010 (class 2606 OID 17142)
-- Name: usuario fk_usuario_rol; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT fk_usuario_rol FOREIGN KEY (id_rol) REFERENCES public.rol(id_rol);


-- Completed on 2026-05-17 21:55:58

--
-- PostgreSQL database dump complete
--

\unrestrict VXCdINCdINCXxc6wOxMPjt04hDpWadTXKDpXVKG9tC5BtWza055zN2msySJ48gX

