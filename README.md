# Clario — App

Cliente móvil de **Clario**, construido en Flutter, conectado al backend Spring Boot de Clario ya desplegado en producción (Railway).

Clario es un SaaS de gestión financiera para autónomos en España: calcula en tiempo real el "Sueldo Neto Disponible" separando automáticamente IVA, IRPF y cuota de autónomos, y emite facturas adaptadas a VeriFactu.

## Stack técnico

- Flutter / Dart
- `http` (conexión con la API REST del backend)
- `shared_preferences` y `flutter_secure_storage` (gestión del token JWT)
- `image_picker` (captura de tickets y facturas para el OCR)

## Pantallas implementadas

- Login y registro de usuario.
- Dashboard con el Sueldo Neto Disponible.
- Gestión de facturas.
- Gestión de gastos.
- Escaneo de tickets y facturas (envía la imagen al backend, que la procesa con IA).

## Cómo ejecutar en local

Requisitos: Flutter SDK instalado.

```bash
git clone https://github.com/Josemi364/clario-app.git
cd clario-app
flutter pub get
flutter run
```

Por defecto, la app apunta al backend ya desplegado en producción. Si quieres apuntar a un backend en local, cambia la constante `baseUrl` en `lib/services/api_service.dart`.

## Estado del proyecto

MVP en desarrollo activo.

## Repositorio relacionado

Backend (Spring Boot): [clario-backend](https://github.com/Josemi364/clario-backend)
