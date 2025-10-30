# FlutterChallenge — GreenGo Logistics

Resumen
-------
Proyecto Flutter (prototipo) para gestionar entregas/repartidores. Durante el desarrollo se unificó el concepto de "tarea" como "entrega" y se implementaron funcionalidades clave: CRUD de entregas, asignación a repartidores, persistencia local, login con hashing, bloqueo por intentos fallidos y mejoras UI/UX responsivas con animaciones.

Qué se hizo (alto nivel)
------------------------
- Unificación: las "tareas" dejaron de ser una entidad separada. Ahora todo se modela como `Delivery`.
- CRUD completo para entregas (crear, editar, eliminar, marcar como completada).
- Gestión por repartidor: vista "Por Repartidor" agrupa entregas por assignedTo.
- IDs legibles y consistentes: formato secuencial `D-1001`, `D-1002`, ...
- Persistencia local: SharedPreferences para guardar entregas y sesión (simulación de persistencia).
- Seguridad:
  - Hashing SHA-256 (package `crypto`) para contraseñas en memoria.
  - Bloqueo temporal tras N intentos fallidos (configurable).
  - Compatibilidad para "updateActivity()" (puede adaptarse si se desea inactividad).
- UI/UX: diseño responsivo para móvil/tablet, tarjetas animadas, mejor layout y diálogo de edición con animaciones.
- Reactividad: uso nativo de Provider + ChangeNotifier para actualizar vistas (rebuild inmediato al `notifyListeners()`).

Archivos creados / modificados
------------------------------
Principales archivos tocados o añadidos (resumen):
- lib/main.dart — registro de providers y arranque.
- lib/models/delivery.dart — modelo Delivery con `toJson()` / `fromJson()`.
- lib/providers/delivery_provider.dart — lógica CRUD, generación de IDs, persistencia (SharedPreferences), notifyListeners().
- lib/providers/auth_provider.dart — hashing, bloqueo por intentos, persistencia de sesión (SharedPreferences), método `updateActivity()` (compatibilidad).
- lib/screens/login_screen.dart — login con animación, validación y bloqueo.
- lib/screens/supervisor_screen.dart — vista supervisor, CRUD, UI responsiva y animada.
- lib/screens/rider_screen.dart — vista repartidor (ver sus entregas), opción logout y tarjetas animadas.
- lib/models/task.dart, lib/providers/task_provider.dart — reemplazados/neutralizados; ya no se usan.
- README.md — este archivo (resumen).

Dependencias importantes
------------------------
- provider
- intl
- crypto (SHA-256): para hashing de contraseñas
- shared_preferences: persistencia local

Instalación y ejecución
-----------------------
1. Asegúrate de tener Flutter instalado y configurado.
2. Desde la raíz del proyecto:
   - Añade dependencias si no se han agregado:
     - `flutter pub add crypto`
     - `flutter pub add shared_preferences`
   - Ejecuta:
     - `flutter pub get`
3. Ejecuta la app:
   - `flutter run` (o desde tu IDE preferido)

Usuarios de ejemplo
-------------------
En `AuthProvider` se añadieron usuarios de ejemplo (contraseña en texto en código, **sólo para prototipo**):
- `juan` / `1234` → role: rider
- `maria` / `abcd` → role: rider
- `admin` / `admin` → role: supervisor

Configuraciones útiles
----------------------
- Cambiar formato ID: en `DeliveryProvider._generateId()` puedes ajustar el prefijo o secuencia.
- Bloqueo/seguridad:
  - `AuthProvider.maxFailedAttempts` (por defecto 3)
  - `AuthProvider.lockDurationSeconds` (por defecto 30)
- Persistencia:
  - `SharedPreferences` guarda `deliveries_json` y `auth_current_user` (simulación local).

Notas de diseño y UX
--------------------
- UI responsive: `LayoutBuilder` adaptando tamaños y paddings en móviles/tablerts.
- Animaciones: `AnimatedContainer`, `AnimatedSwitcher`, `TweenAnimationBuilder` para transiciones suaves.
- Cards con sombras, chips y acciones claras (editar/eliminar) en cada entrega.
- Dialogs con validación mínima (campos requeridos).

Comportamiento en tiempo real
-----------------------------
- La app usa `ChangeNotifier` (Provider) para la reactividad local. Cada operación CRUD llama `notifyListeners()` y las vistas que consumen los providers se reconstruyen automáticamente.
- No se implementó comunicación remota (WebSockets) en este prototipo; se puede integrar un adaptador que llame a los métodos del provider si se requiere sincronización externa.

Pruebas y verificación
----------------------
- Inicia sesión como `admin`, crea/edita/borra entregas y observa que la vista de `rider` se actualiza al volver o abrirla.
- Inicia sesión como `juan`/`maria` para verificar que sólo ven sus entregas.
- Verifica persistencia cerrando y reabriendo la app (SharedPreferences conserva las entregas y la sesión).



Contacto / Creditos
-------------------
- JuanSe2731
- C34z4r
