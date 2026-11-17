# Vehicle Management System (VMS) — Frontend

Professional corporate vehicle management web application built with **Flutter Web**, **Dart**, and **Material 3**, fully integrated with a **Java Spring Boot REST API** backend.

---

## Design System & Style Guide

The UI strictly follows the corporate VMS design language:
- **Desktop-first responsive layout:** Fixed left navigation drawer, sticky application header, and high-density corporate data views.
- **Enterprise Blue Palette:**
  - **Deep Blue (`#1F4E79`):** Left sidebar navigation, brand headers, and primary card titles.
  - **Corporate Blue (`#5B9BD5`):** Primary action buttons, active navigation indicators, and focus states.
  - **Soft Gray (`#F5F7FA`):** Clean canvas background.
  - **White (`#FFFFFF`):** Cards, tables, and form containers.
  - **Charcoal (`#1F2937`):** Primary text and dark accents.
  - **Green (`#2E7D32`):** Active / operational status.
  - **Red (`#D32F2F`):** Inactive status, delete actions, and validation errors.
  - **Amber (`#E65100`):** Under Maintenance status.

---

## Core Feature Overview

### 1. Spring Boot JWT Authentication
- Centered sign-in card layout on soft gray background.
- Connects to Spring Boot backend `POST /auth/login`.
- Transmits credentials securely; passwords are never logged, exposed, or permanently stored.
- Secure session management using browser tab-isolated `sessionStorage`.
- Detects expired sessions and invalid tokens (HTTP 401), automatically returning to login with a friendly session-expired banner.
- Secure logout clearing all session state and cached tokens.

### 2. Fleet Dashboard
- 4 Operational Metric KPI Cards:
  - **Total Vehicles** (Navy)
  - **Active Vehicles** (Green)
  - **Inactive Vehicles** (Red)
  - **Vehicles Under Maintenance** (Amber)
- Quick overview data table displaying the most recently registered and updated units.
- Fast navigation to registration form and full vehicle directory.

### 3. Vehicle Inventory Directory (Paginated REST API)
- Comprehensive vehicle table displaying:
  - Vehicle Number
  - Company
  - Type
  - Brand
  - Model
  - Status (Color-coded badge)
  - Actions (Edit & Delete)
- **Real-Time REST Integration:** Fetches paginated vehicle records via `GET /vehicles?page=X&size=Y`.
- **Search & Filters:** Real-time client and server-aligned filtering across Vehicle Number, Company, Brand, and Model.
- **Pagination Controls:** Configurable page sizes (5, 8, 12, 20) with page indicators and navigation buttons.
- **State Handling:** Loading skeletons, error state with retry button, and friendly empty-state feedback.

### 4. Vehicle Registration & Modification (CRUD)
- Reusable form component handling both **Registering** (`POST /vehicles`) and **Editing** (`PUT /vehicles/{id}`).
- Pre-populates existing vehicle data during editing.
- Client-side validation combined with backend validation error display.
- **Duplicate Number Handling:** Displays friendly error banner when the backend returns HTTP 409 Conflict.
- **Success Feedback:** Snackbars confirm successful creation and updates.

### 5. Vehicle Deletion
- Delete vehicle action with confirmation modal dialog (`DELETE /vehicles/{id}`).
- Immediately removes vehicle upon confirmation and reloads the directory.

---

## Project Structure

```
vms-frontend/
├── lib/
│   ├── main.dart                               # Application bootstrap
│   ├── app.dart                                # MaterialApp & Shell layout
│   │
│   ├── core/
│   │   ├── config/
│   │   │   └── api_config.dart                 # API base URL & endpoint builder
│   │   ├── constants/
│   │   │   └── app_constants.dart              # Layout dimensions & defaults
│   │   ├── theme/
│   │   │   ├── app_colors.dart                 # VMS corporate color palette
│   │   │   ├── app_text_styles.dart            # Typography scale
│   │   │   └── app_theme.dart                  # Material 3 ThemeData
│   │   └── utils/
│   │       └── responsive.dart                 # Responsive breakpoint helpers
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── auth_session.dart               # JWT token & session model
│   │   │   ├── paginated_vehicles.dart         # Spring Page response wrapper
│   │   │   └── vehicle.dart                    # Vehicle entity & VehicleStatus enum
│   │   ├── repositories/
│   │   │   └── vehicle_repository.dart         # Vehicle repository abstraction
│   │   └── services/
│   │       ├── api_client.dart                 # HTTP client with JWT interceptor
│   │       ├── api_exception.dart              # Standardized API exception model
│   │       ├── auth_service.dart               # Authentication & session service
│   │       ├── vehicle_api_service.dart        # Vehicle REST API client
│   │       └── session_storage/                # Platform-specific session storage
│   │           ├── session_storage.dart
│   │           ├── session_storage_base.dart
│   │           ├── session_storage_stub.dart
│   │           └── session_storage_web.dart
│   │
│   ├── routing/
│   │   └── app_router.dart                     # Screen navigation coordinator
│   │
│   ├── screens/
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart           # KPI cards & overview table
│   │   ├── login/
│   │   │   └── login_screen.dart               # Corporate sign-in form
│   │   └── vehicles/
│   │       ├── vehicle_form_screen.dart        # Register & Edit vehicle form
│   │       └── vehicle_list_screen.dart        # Paginated vehicle directory
│   │
│   └── widgets/
│       ├── app_button.dart                     # Standardized buttons (Primary, Secondary, Danger)
│       ├── app_dropdown.dart                   # Styled dropdown selector
│       ├── app_header.dart                     # Header bar with user profile & logout
│       ├── app_sidebar.dart                    # Fixed left navigation drawer
│       ├── app_text_field.dart                 # Standardized text input
│       ├── confirmation_dialog.dart            # Modal confirmation dialog
│       ├── empty_state.dart                    # Empty state illustration widget
│       └── status_badge.dart                   # Status pill badge
│
├── test/                                       # Unit and Widget test suite
├── web/                                        # Web assets and index.html
├── Dockerfile                                  # Multi-stage Docker build
├── docker-compose.yml                          # Container orchestration
├── run.sh                                      # Automated local launcher
├── pubspec.yaml                                # Dependencies & package manifest
└── README.md
```

---

## Configuration & Environment

The backend REST API base URL is configurable at compile time:

```bash
# Default points to local Spring Boot backend: http://localhost:8081
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8081

# Production with HTTPS:
flutter build web --dart-define=API_BASE_URL=https://api.vms.company.com
```

### Security Considerations:
- **No Secrets in Source:** No passwords, private keys, or API tokens are hardcoded or tracked in Git.
- **Secure Sessions:** JWT tokens are stored only in memory and browser `sessionStorage` (cleared automatically upon tab closure).
- **Transport Security:** Enforces HTTPS for all remote non-loopback endpoints in production mode.

---

## Running Locally

### Option 1: Using Flutter CLI Directly
```bash
cd /home/yeaish/repos/vms-frontend

# Install dependencies
flutter pub get

# Run in Chrome
flutter run -d chrome --web-port=8080
```

### Option 2: Automated Launcher
```bash
cd /home/yeaish/repos/vms-frontend
./run.sh
```

### Option 3: With Docker Compose
```bash
cd /home/yeaish/repos/vms-frontend
docker compose up -d
```
Access the application at: [http://localhost:8080](http://localhost:8080)

---

## Quality Assurance & Testing

Run static analysis:
```bash
flutter analyze
```

Run test suite:
```bash
flutter test
```

Build production web bundle:
```bash
flutter build web
```
