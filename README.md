# XAUT — Live Gold Price Tracker

<p align="center">
  <img src="assets/images/app_icon.png" width="120" alt="XAUT Logo"/>
</p>

<p align="center">
  <strong>Ultra-reliable XAUUSD gold price tracking with advanced price alerts</strong>
</p>

<p align="center">
  <a href="https://github.com/yourusername/xaut/actions">
    <img src="https://github.com/yourusername/xaut/workflows/XAUT%20-%20Flutter%20CI%2FCD/badge.svg" alt="CI/CD"/>
  </a>
  <img src="https://img.shields.io/badge/Flutter-3.22.0-blue?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Platform-Android-green?logo=android" alt="Android"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License"/>
</p>

---

## Features

### Live Price Engine
- **Second-by-second** XAUUSD price updates
- **Bid / Ask / Spread** display
- Live price direction animations (flash on tick)
- 5-minute scrollable mini chart
- Today's High / Low / Open stats
- Automatic reconnection on network loss
- Cached prices for offline viewing

### Advanced Alert System
- Custom target price with direction (Cross Above / Cross Below)
- Three alert types:
  - Standard notification
  - High-priority heads-up notification
  - Full-screen alarm (wakes device)
- Per-alert configuration:
  - Sound theme selection
  - Vibration pattern
  - Repeat mode (once / every 1m / 5m / 15m / until dismissed)
  - Custom label & notes
- Complete management: create, edit, toggle, delete, bulk actions
- Filter by: All / Active / Inactive / Triggered
- Search alerts by label, price, notes
- Alert history with trigger timestamps

### Home Screen Widget
- Live price display directly on home screen
- Auto-refresh every 30 minutes (system-triggered)
- Real-time updates when app is active
- Dark/light adaptive styling
- Click to open app

### Background Reliability
- Foreground service with persistent notification
- WorkManager for periodic sync
- Boot receiver to restore alerts after reboot
- Wake lock for critical alert delivery
- Battery optimization bypass support
- Exact alarm permission for precise triggers

### UI / UX
- Material Design 3 with dark-first premium design
- DM Sans + Space Mono typography pairing
- Gold (#FFD700) accent throughout
- Smooth animations via flutter_animate + fl_chart
- Onboarding with permission flow

---

## Architecture

```
lib/
├── core/
│   ├── constants/     # AppConstants
│   ├── di/            # GetIt dependency injection
│   ├── theme/         # AppTheme (light + dark)
│   └── utils/         # FormatUtils
├── data/
│   ├── models/        # PriceModel, AlertModel, AppSettings
│   ├── repositories/  # Price, Alert, Settings repos
│   └── services/      # GoldPriceService, NotificationService, AlertEngine
├── presentation/
│   ├── bloc/          # PriceBloc, AlertBloc, SettingsBloc
│   ├── pages/         # Home, Alerts, Settings, Onboarding
│   └── widgets/       # Reusable UI components
└── services/
    └── background/    # WorkManager background tasks
```

---

## Setup & Build

### Prerequisites
- Flutter 3.22.0+
- Java 17
- Android SDK with API 35

### Local Build

```bash
# Install dependencies
flutter pub get

# Run analysis
flutter analyze

# Build release APK
flutter build apk --release --split-per-abi

# Install on device
flutter install
```

### CI/CD (GitHub Actions)

Automatically triggers on push to `main`:
1. **Flutter Analyze** — code quality check
2. **Build Release APK** — split per ABI (arm64, armeabi, x86_64)
3. **Upload Artifacts** — available in GitHub Actions tab
4. **Create Release** — triggered on `v*` tag push

### Signing (Optional)

Add these secrets to GitHub repository:
| Secret | Description |
|--------|-------------|
| `KEY_STORE_BASE64` | Base64-encoded `.jks` keystore |
| `KEY_STORE_PASSWORD` | Keystore password |
| `KEY_ALIAS` | Key alias |
| `KEY_PASSWORD` | Key password |

Generate keystore:
```bash
keytool -genkey -v -keystore xaut-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias xaut

# Encode to base64
base64 xaut-release.jks | pbcopy
```

---

## Data Sources

| Source | Type | Auth |
|--------|------|------|
| metals.live/v1/spot | REST poll | None (free) |
| Yahoo Finance (XAUUSD=X) | REST poll fallback | None |
| Simulated (Brownian motion) | Local fallback | N/A |

The app tries live APIs first. If unavailable, falls back to realistic simulation so the UI always shows live-style data.

---

## Permissions

| Permission | Purpose |
|-----------|---------|
| `INTERNET` | Live price data |
| `POST_NOTIFICATIONS` | Alert notifications |
| `SCHEDULE_EXACT_ALARM` | Precise alert timing |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Continuous background monitoring |
| `FOREGROUND_SERVICE` | Persistent price service |
| `RECEIVE_BOOT_COMPLETED` | Restore alerts after reboot |
| `WAKE_LOCK` | Wake device for critical alarms |
| `VIBRATE` | Alert vibration |

---

## License

MIT © 2024 XAUT
