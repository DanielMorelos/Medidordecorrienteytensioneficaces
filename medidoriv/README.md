# MedidorIV

[English](#english) · [Español](#español)

---

## English

Flutter app (Android and web) that displays the RMS voltage and current measured by the ESP32-based wireless meter. Data is read from Firebase Realtime Database.

### Features

- Loads the last 100 measurements from Firebase.
- Table with relative time, V<sub>RMS</sub> (V) and I<sub>RMS</sub> (A).
- Voltage and current plots over time.
- Button to upload 100 test samples, useful for validating without the hardware.

### Technologies

Flutter · Dart · Firebase Realtime Database · fl_chart

### Data structure

Each measurement is stored under the `mediciones` node, keyed by its timestamp in milliseconds:

```json
{
  "mediciones": {
    "1759972541765": {
      "voltaje": 119.618,
      "corriente": 4.851,
      "Key": "MEDIDOR_2025"
    }
  }
}
```

### Setup

Requires the Flutter SDK and a Firebase project with Realtime Database enabled.

```bash
flutter pub get
flutterfire configure   # generates lib/firebase_options.dart
flutter run -d chrome   # web
flutter run             # Android
```

For Android, place `google-services.json` in `android/app/`.

### Project structure

```
lib/
  main.dart               UI, Firebase queries and charts
  firebase_options.dart   Firebase configuration
assets/                   graphic resources
```

### Authors

Daniel Jeshua Morelos Villamizar and Kevin Rafael Roa Garcia
Universidad Industrial de Santander, 2025

---

## Español

Aplicación Flutter (Android y web) para visualizar la tensión y corriente eficaces medidas por el medidor inalámbrico basado en ESP32. Los datos se leen desde Firebase Realtime Database.

### Funcionalidades

- Carga de las últimas 100 mediciones desde Firebase.
- Tabla con tiempo relativo, V<sub>RMS</sub> (V) e I<sub>RMS</sub> (A).
- Gráficas de tensión y corriente en el tiempo.
- Botón para subir 100 datos de prueba, útil para validar sin el hardware.

### Tecnologías

Flutter · Dart · Firebase Realtime Database · fl_chart

### Estructura de datos

Cada medición se guarda en el nodo `mediciones`, con el timestamp en milisegundos como clave:

```json
{
  "mediciones": {
    "1759972541765": {
      "voltaje": 119.618,
      "corriente": 4.851,
      "Key": "MEDIDOR_2025"
    }
  }
}
```

### Instalación

Requiere Flutter SDK y un proyecto de Firebase con Realtime Database.

```bash
flutter pub get
flutterfire configure   # genera lib/firebase_options.dart
flutter run -d chrome   # web
flutter run             # Android
```

Para Android, coloca `google-services.json` en `android/app/`.

### Estructura del proyecto

```
lib/
  main.dart               interfaz, consulta a Firebase y gráficas
  firebase_options.dart   configuración de Firebase
assets/                   recursos gráficos
```

### Autores

Daniel Jeshua Morelos Villamizar y Kevin Rafael Roa Garcia
Universidad Industrial de Santander, 2025
