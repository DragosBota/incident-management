# Gestor de Incidencias Post-Venta

Aplicación móvil desarrollada como Trabajo de Fin de Grado del ciclo formativo de Desarrollo de Aplicaciones Multiplataforma (DAM) en thePower Education.

El proyecto nace de una necesidad real detectada en un entorno industrial B2B, concretamente en la gestión de incidencias post-venta de una empresa fabricante de colchones OEM. En este contexto, las reclamaciones de clientes requieren la intervención de distintos departamentos y una trazabilidad clara desde su creación hasta su cierre.

La solución propuesta consiste en una aplicación móvil desarrollada con Flutter y Supabase que permite centralizar el registro, seguimiento y gestión interna de incidencias post-venta, sustituyendo un flujo manual basado en correos electrónicos, llamadas y hojas de cálculo compartidas.

---

## Contexto del proyecto

En el entorno empresarial analizado, la gestión principal de pedidos, producción, compras, facturación y logística se realiza mediante un sistema ERP corporativo. Sin embargo, la gestión específica de incidencias post-venta se realiza de forma descentralizada mediante distintos canales de comunicación.

Aunque el volumen de incidencias es reducido en comparación con el total de unidades fabricadas, cada caso tiene un impacto directo sobre la relación con el cliente y puede implicar decisiones comerciales, productivas, logísticas o de calidad.

Por este motivo, se detecta la necesidad de una herramienta específica que permita:

- Registrar incidencias de forma estructurada.
- Conocer el estado actual de cada caso.
- Identificar el departamento responsable.
- Mantener un historial de acciones.
- Aplicar restricciones según el departamento del usuario.
- Permitir el funcionamiento básico sin conexión.
- Sincronizar los datos cuando se recupere la conectividad.

---

## Problema que resuelve

La gestión actual de incidencias presenta varios problemas operativos:

- Falta de visibilidad centralizada del estado real de cada incidencia.
- Dependencia de recordatorios manuales entre departamentos.
- Duplicidad o pérdida de información.
- Ausencia de trazabilidad completa sobre las decisiones tomadas.
- Sobrecarga administrativa en el seguimiento comercial.
- Dificultad para coordinar a los departamentos implicados.
- Riesgo de retrasos en la resolución de reclamaciones.

La aplicación pretende reducir estos problemas mediante una gestión centralizada, estructurada y adaptada al flujo real de trabajo de la empresa.

---

## Objetivos del sistema

Los objetivos principales del sistema son:

- Centralizar la gestión de incidencias post-venta.
- Facilitar el seguimiento entre departamentos.
- Registrar el historial de acciones realizadas sobre cada incidencia.
- Controlar el acceso y las acciones disponibles según el departamento del usuario.
- Permitir la creación, consulta y modificación de incidencias.
- Aplicar eliminación lógica mediante soft delete.
- Permitir el funcionamiento offline mediante persistencia local.
- Sincronizar los cambios pendientes cuando exista conexión.
- Generar una versión funcional instalable para Android.

---

## Stack tecnológico

El proyecto utiliza las siguientes tecnologías y herramientas:

- Flutter: framework principal para el desarrollo de la aplicación móvil.
- Dart: lenguaje de programación utilizado por Flutter.
- Supabase: backend remoto de la aplicación.
- Supabase Auth: autenticación de usuarios mediante email y contraseña.
- PostgreSQL: base de datos relacional utilizada por Supabase.
- SQLite: base de datos local para permitir funcionamiento offline.
- sqflite: paquete utilizado para gestionar SQLite desde Flutter.
- shared_preferences: almacenamiento local de datos auxiliares y caché.
- connectivity: detección del estado de conexión del dispositivo.
- flutter_dotenv: carga de variables de entorno.
- uuid: generación de identificadores únicos.
- Git y GitHub: control de versiones y alojamiento del código.
- Android: plataforma objetivo principal de la versión actual.

---

## Funcionalidades implementadas

La versión actual del proyecto incluye las siguientes funcionalidades:

### Gestión de usuarios

- Registro de usuarios corporativos.
- Autenticación mediante correo electrónico y contraseña.
- Asociación de usuarios a un departamento.
- Carga de perfil y departamento del usuario autenticado.
- Restricción del registro a correos corporativos.

### Gestión de incidencias

- Creación de incidencias post-venta.
- Generación automática de código interno de incidencia.
- Visualización de incidencias en listado.
- Consulta de detalle de incidencia.
- Edición de datos principales.
- Eliminación lógica mediante soft delete.
- Visualización de incidencias abiertas, cerradas y eliminadas.

### Gestión de estados

- Estado inicial automático REGISTERED.
- Actualización del estado de una incidencia.
- Actualización del departamento responsable.
- Control de estados disponibles según el departamento del usuario.

Estados contemplados:

- REGISTERED
- IN_REVIEW
- WAITING_DEPARTMENT
- ACTION_REQUIRED
- CLOSED

### Trazabilidad

- Registro automático de acciones realizadas sobre una incidencia.
- Historial asociado a cada incidencia.
- Registro de creación, modificación, cambio de estado y eliminación lógica.
- Almacenamiento del usuario responsable y fecha de cada acción.

### Restricciones por departamento

La aplicación aplica reglas de permisos según el departamento del usuario:

- Solo usuarios del área comercial pueden crear incidencias.
- Solo usuarios del área comercial pueden editar incidencias.
- Solo usuarios del área comercial pueden eliminar incidencias.
- El estado REGISTERED se asigna automáticamente al crear una incidencia.
- Solo usuarios del departamento de calidad pueden asignar el estado IN_REVIEW.
- Solo usuarios del área comercial pueden cerrar una incidencia con estado CLOSED.
- Las incidencias eliminadas quedan en modo solo lectura.

### Funcionamiento offline-first

- Persistencia local de incidencias mediante SQLite.
- Persistencia local del historial de acciones.
- Creación de incidencias sin conexión.
- Modificación de incidencias sin conexión.
- Eliminación lógica sin conexión.
- Consulta de incidencias almacenadas localmente.
- Marcado de registros pendientes de sincronización.

### Sincronización

- Sincronización automática al recuperar conexión.
- Sincronización manual desde la aplicación.
- Gestión de estados de sincronización:

  - PENDING_CREATE
  - PENDING_UPDATE
  - PENDING_DELETE
  - SYNCED

- Envío de incidencias pendientes al servidor.
- Envío de acciones de historial pendientes.
- Mantenimiento de registros pendientes en caso de error de sincronización.

---

## Funcionalidades no implementadas

Durante el desarrollo se priorizó el núcleo funcional de la aplicación. Algunas funcionalidades previstas inicialmente quedaron fuera del alcance final y se documentan como mejoras futuras.

No se ha implementado en la versión actual:

- Subida de archivos adjuntos.
- Gestión de imágenes o documentos asociados a incidencias.
- Sincronización offline de archivos adjuntos.
- Búsqueda avanzada por cliente, pedido SAP, fecha o usuario.
- Integración directa con el ERP corporativo.
- Generación de informes o métricas avanzadas.
- Notificaciones push.

---

## Trabajos futuros

Las principales líneas de evolución del proyecto son:

### Gestión de adjuntos

Incorporar la posibilidad de asociar imágenes, documentos PDF u otros archivos a una incidencia. Esta mejora resulta especialmente útil para adjuntar evidencias visuales o documentales relacionadas con una reclamación.

La funcionalidad debería contemplar:

- Subida de archivos en modo online.
- Almacenamiento temporal de archivos en modo offline.
- Sincronización posterior de archivos.
- Consulta de archivos asociados a una incidencia.
- Control de permisos sobre los adjuntos.

### Filtros y búsqueda avanzada

Ampliar el filtrado actual para permitir búsquedas por:

- Cliente.
- Código interno de incidencia.
- Pedido SAP.
- Estado.
- Departamento responsable.
- Fecha de creación.
- Usuario creador.

### Notificaciones

Incorporar avisos automáticos cuando:

- Una incidencia cambie de estado.
- Una incidencia sea asignada a un departamento.
- Existan incidencias pendientes de revisión.
- Se produzcan errores de sincronización.

### Informes y métricas

Añadir cuadros de mando o informes que permitan consultar:

- Número de incidencias por cliente.
- Incidencias por estado.
- Incidencias por departamento.
- Tiempo medio de resolución.
- Evolución mensual de reclamaciones.
- Incidencias cerradas frente a abiertas.

### Integración con sistemas corporativos

Estudiar una futura integración con el ERP corporativo para recuperar datos de pedidos, clientes o referencias, reduciendo la introducción manual de información y mejorando la coherencia entre sistemas.

---

## Arquitectura del proyecto

El proyecto sigue una organización por funcionalidades y separa las responsabilidades principales en distintas capas.

Estructura general:

- screens: pantallas e interfaz de usuario.
- models: modelos de datos del dominio.
- services: lógica de aplicación, acceso a Supabase, persistencia local y sincronización.
- core: configuración general del proyecto.
- shared: servicios compartidos entre módulos.

La aplicación combina persistencia remota en Supabase con almacenamiento local en SQLite, lo que permite trabajar sin conexión y sincronizar los cambios posteriormente.

---

## Estructura del proyecto


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

## Autor

Dragos Bota  
Trabajo de Fin de Grado - DAM  
thePower Education
