# Generar APK (Android) e IPA (iOS) para compartir

## Android – APK

### 1. APK de release (para compartir por WhatsApp, correo, etc.)

Desde la carpeta del proyecto:

```bash
cd "/Users/lucas/Desktop/App Cali/cali_app"
flutter build apk --release
```

El archivo queda en:

```
build/app/outputs/flutter-apk/app-release.apk
```

Podés renombrarlo (ej. `cali_app_v1.apk`) y compartirlo. Quien lo reciba puede instalarlo en Android (puede tener que permitir “instalar desde fuentes desconocidas”).

### 2. APK dividido por ABI (más liviano)

Si querés un APK más chico por arquitectura:

```bash
flutter build apk --split-per-abi
```

Se generan varios APK en `build/app/outputs/flutter-apk/`:
- `app-armeabi-v7a-release.apk` (32 bits)
- `app-arm64-v8a-release.apk` (64 bits, la mayoría de los celulares)
- `app-x86_64-release.apk` (emuladores / algunos tablets)

Para compartir a la mayoría de usuarios, suele alcanzar con **`app-arm64-v8a-release.apk`**.

---

## iOS – IPA (para instalar en iPhone/iPad)

### Requisitos

- **Mac** con Xcode instalado.
- **Cuenta Apple Developer** (gratuita sirve para pruebas en tu dispositivo; para TestFlight o App Store hace falta cuenta de pago).

### 1. Build desde Flutter

```bash
cd "/Users/lucas/Desktop/App Cali/cali_app"
flutter build ipa
```

El IPA se genera en:

```
build/ios/ipa/cali_app.ipa
```

### 2. Distribución en iOS

- **Solo tus dispositivos (cuenta gratuita):**  
  Abrí el proyecto en Xcode (`ios/Runner.xcworkspace`), elegí tu equipo en “Signing & Capabilities” y subí a tu iPhone por cable o por “Window → Devices and Simulators”.

- **TestFlight / App Store:**  
  Necesitás cuenta Apple Developer de pago. En Xcode: “Product → Archive”, luego “Distribute App” y elegir TestFlight o App Store.

- **Compartir IPA con otros:**  
  Sin cuenta de pago es limitado: cada dispositivo debe estar registrado en tu equipo (registro de dispositivos). Para compartir con cualquiera sin registro, la vía normal es publicar en TestFlight o App Store.

---

## Resumen rápido

| Plataforma | Comando                    | Dónde queda el archivo                          |
|-----------|----------------------------|-------------------------------------------------|
| Android   | `flutter build apk --release` | `build/app/outputs/flutter-apk/app-release.apk` |
| iOS       | `flutter build ipa`        | `build/ios/ipa/cali_app.ipa`                   |

Antes de construir, conviene tener dependencias al día:

```bash
flutter pub get
flutter clean
flutter build apk --release   # o flutter build ipa
```
