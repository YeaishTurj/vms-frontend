# Vehicle Management System (VMS) — Frontend

Professional corporate fleet and vehicle management web application built with **Flutter Web**, **Dart**, and **Material 3**.

---

## Architecture Overview

This project is the standalone web frontend for the Vehicle Management System. In accordance with architectural boundaries:
- **Zero Backend Coupling:** Operates using local in-memory reactive state and rich mock data.
- **Corporate Blue & White Design System:** High-density desktop layouts, enterprise data tables, fixed sidebar navigation, and standardized form elements.
- **Clean & Beginner-Friendly Architecture:** No bloated state management dependencies; built on native `ChangeNotifier` and `ListenableBuilder`.

---

## Directory Structure

```
vms-frontend/
├── web/
│   ├── index.html               # Web bootstrap & loading splash
│   └── manifest.json            # PWA web manifest
├── lib/
│   ├── main.dart                # App entry point
│   ├── app.dart                 # Root MaterialApp & MainShell layout
│   │
│   ├── core/                    # Foundation & cross-cutting concerns
│   │   ├── theme/
│   │   │   ├── app_colors.dart      # Corporate blue palette & status tokens
│   │   │   ├── app_text_styles.dart # Desktop-first typography scale
│   │   │   └── app_theme.dart       # Material 3 ThemeData definition
│   │   ├── constants/
│   │   │   └── app_constants.dart   # Layout dimensions & route names
│   │   └── utils/
│   │       └── responsive.dart      # Desktop / tablet responsive utility
│   │
│   ├── models/                  # Domain entities
│   │   └── vehicle.dart             # Vehicle entity, VehicleStatus, VehicleType, FuelType
│   │
│   ├── data/                    # In-memory mock repositories
│   │   └── mock_vehicle_data.dart   # Seed data & reactive CRUD operations
│   │
│   ├── routing/                 # Application routing
│   │   └── app_router.dart          # Central navigation coordinator
│   │
│   ├── widgets/                 # Reusable UI components
│   │   ├── app_header.dart          # Fixed enterprise top bar
│   │   ├── app_sidebar.dart         # Fixed left navigation drawer
│   │   ├── app_button.dart          # Primary, secondary, outlined & danger buttons
│   │   ├── app_text_field.dart      # Standardized form input field
│   │   ├── status_badge.dart        # Vehicle status badge
│   │   └── confirmation_dialog.dart # Modal dialog for destructive actions
│   │
│   └── screens/                 # Application screens
│       ├── login/
│       │   └── login_screen.dart        # Corporate portal login
│       ├── dashboard/
│       │   └── dashboard_screen.dart    # KPI metrics & fleet summary
│       └── vehicles/
│           ├── vehicle_list_screen.dart # Filterable data table & search
│           └── vehicle_form_screen.dart # Vehicle create & edit form
│
├── analysis_options.yaml        # Strict Dart linter configuration
└── pubspec.yaml                 # Flutter project specification
```

---

## Design System Tokens

| Token | Hex Value | Purpose |
| :--- | :--- | :--- |
| **Primary Navy** | `#1E3A8A` | Corporate brand identity, primary buttons |
| **Primary Light** | `#3B82F6` | Active states, links, accents |
| **Primary Container** | `#DBEAFE` | Subtle blue badge backgrounds |
| **Background** | `#F8FAFC` | Light grey canvas background |
| **Surface** | `#FFFFFF` | Card, table, and modal background |
| **Status Active** | `#16A34A` | Ready for dispatch |
| **Status In Service** | `#2563EB` | Currently on route |
| **Status Maintenance**| `#D97706` | In service bay |
| **Status Inactive** | `#DC2626` | Retired / Decommissioned |

---

## Running Locally

### With Flutter installed on host:
```bash
flutter pub get
flutter run -d chrome
```

### With Docker:
```bash
docker run --rm -p 8080:8080 -v "$PWD:/app" -w /app instrumentisto/flutter:3.41.0 \
  sh -c "flutter pub get && flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0"
```
