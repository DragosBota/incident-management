# Gestor de Incidencias Post-Venta

Aplicacion movil desarrollada como Trabajo de Fin de Grado del ciclo formativo de Desarrollo de Aplicaciones Multiplataforma (DAM). El proyecto nace de una necesidad real detectada en un entorno industrial B2B, donde la gestion de incidencias post-venta se realiza actualmente mediante correos electronicos, llamadas y hojas de calculo compartidas, lo que dificulta la trazabilidad, la coordinacion entre departamentos y el seguimiento en tiempo real.

La solucion propuesta consiste en una aplicacion construida con Flutter y Supabase para centralizar el registro, seguimiento y gestion de incidencias entre distintos departamentos de la empresa.

## Contexto del proyecto

Este proyecto esta basado en un caso real de gestion post-venta dentro de una empresa fabricante de colchones OEM. Aunque el porcentaje de incidencias es bajo respecto al volumen total de fabricacion, cada caso tiene un impacto directo sobre la relacion con el cliente y requiere coordinacion entre varios departamentos.

La aplicacion busca sustituir un flujo manual y descentralizado por una herramienta unica que permita:

- registrar incidencias de forma estructurada
- conocer en todo momento el estado actual de cada caso
- identificar el departamento responsable
- mantener un historial completo de acciones
- aplicar restricciones segun el departamento del usuario

## Problema que resuelve

La gestion actual de incidencias presenta varios problemas operativos:

- falta de visibilidad centralizada del estado real de cada incidencia
- dependencia de recordatorios manuales entre departamentos
- duplicidad o perdida de informacion
- ausencia de trazabilidad completa sobre las decisiones tomadas
- sobrecarga administrativa en el seguimiento comercial

La aplicacion pretende reducir estos problemas mediante una gestion centralizada, estructurada y orientada al flujo real de trabajo de la empresa.

## Objetivos del sistema

- centralizar la gestion de incidencias post-venta
- facilitar el seguimiento entre departamentos
- registrar el historial de acciones realizadas sobre cada incidencia
- controlar el acceso y las acciones disponibles segun el departamento del usuario
- preparar la base para futuras funcionalidades offline-first y gestion de adjuntos

## Stack tecnologico

- Flutter
- Dart
- Supabase
- PostgreSQL
- Supabase Auth
- Supabase Storage
- SQLite
- Android como plataforma objetivo actual

## Funcionalidades implementadas

- registro de usuarios corporativos asociados a un departamento
- autenticacion de usuarios mediante correo corporativo
- carga de departamentos desde base de datos
- creacion de incidencias
- edicion de incidencias
- eliminacion logica mediante soft delete
- actualizacion de estado y departamento responsable
- historial de acciones sobre cada incidencia
- restricciones basadas en departamento para ciertas acciones
- visualizacion de listado y detalle de incidencias
- filtros de incidencias `Opened`, `Closed` y `Deleted`
- persistencia local con SQLite
- funcionamiento offline-first para incidencias y trazabilidad
- sincronizacion automatica al recuperar conectividad
- sincronizacion manual desde la aplicacion

## Funcionalidades previstas

Estas funcionalidades forman parte del alcance planteado para el TFG, pero todavia no estan completamente implementadas en la version actual del proyecto:

- subida y gestion de adjuntos
- busqueda y filtrado avanzado

## Reglas funcionales principales

- solo el departamento Commercial puede crear incidencias
- solo el departamento Commercial puede editar incidencias
- solo el departamento Commercial puede eliminar incidencias
- el estado `REGISTERED` se asigna automaticamente al crear una incidencia
- solo el departamento Quality puede asignar el estado `IN_REVIEW`
- cualquier usuario autenticado puede asignar `WAITING_DEPARTMENT` y `ACTION_REQUIRED`
- solo el departamento Commercial puede cerrar una incidencia con estado `CLOSED`
- las incidencias eliminadas logicamente no aparecen en el listado principal

## Arquitectura del proyecto

El proyecto sigue una organizacion por funcionalidades (`features`) y separa las principales responsabilidades en capas sencillas:

- `screens`: interfaz de usuario
- `models`: estructuras de datos del dominio
- `services`: acceso a Supabase, persistencia local y logica de aplicacion
- `core`: configuracion general
- `shared`: servicios compartidos

La version actual combina persistencia remota en Supabase con almacenamiento local en SQLite para permitir trabajo offline y sincronizacion posterior.

## Estructura del proyecto

```text
lib/
├── app/
├── core/
│   └── config/
├── features/
│   ├── auth/
│   │   ├── models/
│   │   ├── screens/
│   │   └── services/
│   └── incidents/
│       ├── models/
│       ├── screens/
│       └── services/
└── shared/
    └── services/
```

## Ejecucion del proyecto

### Requisitos previos

- Flutter instalado
- SDK de Dart
- proyecto de Supabase configurado
- archivo `.env` con las credenciales necesarias

### Variables de entorno

El proyecto utiliza un archivo `.env` en la raiz con las siguientes variables:

```env
SUPABASE_URL=tu_url_de_supabase
SUPABASE_ANON_KEY=tu_clave_anonima
```

### Pasos para ejecutar

1. Clonar el repositorio y acceder a la carpeta del proyecto.
2. Crear el archivo `.env` en la raiz e introducir las credenciales de Supabase.
3. Instalar las dependencias del proyecto.
4. Ejecutar la aplicacion en un emulador o dispositivo fisico.

```bash
git clone <url-del-repositorio>
cd incident_management
flutter pub get
flutter run
```

Si se desea ejecutar en un dispositivo concreto, Flutter permite listar los destinos disponibles con:

```bash
flutter devices
```

Y lanzar la aplicacion sobre uno de ellos con:

```bash
flutter run -d <device_id>
```

## Estado actual del proyecto

La version actual ya permite demostrar el flujo principal del sistema:

- autenticacion de usuarios
- creacion y seguimiento de incidencias
- control de estados
- trazabilidad de acciones
- restricciones por departamento
- filtros de visualizacion por estado
- trabajo offline con sincronizacion posterior

La gestion de adjuntos queda planteada como mejora futura para una siguiente iteracion del proyecto.

## Capturas

Pendiente de incorporar capturas reales de:

- pantalla de login
- pantalla de registro
- listado de incidencias
- detalle de incidencia
- cambio de estado

## Autor

Dragos Bota  
Trabajo de Fin de Grado - DAM  
thePower Education
