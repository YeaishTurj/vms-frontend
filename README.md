# Vehicle Management System (VMS) — Frontend

Professional corporate vehicle management web application built with **Flutter Web**, **Dart**, and **Material 3**.

---

## Design System & Style Guide

The UI follows the corporate VMS design language:
- **Desktop-first responsive layout:** Fixed left navigation drawer, sticky application header, and high-density data views.
- **Enterprise Blue Palette:**
  - **Deep Blue (`#1F4E79`):** Left sidebar navigation, brand headers, and primary card titles.
  - **Corporate Blue (`#5B9BD5`):** Primary action buttons, active navigation indicators, and focus states.
  - **Soft Gray (`#F5F7FA`):** Clean canvas background.
  - **White (`#FFFFFF`):** Cards, tables, and form containers.
  - **Charcoal (`#1F2937`):** Primary text and dark accents.
  - **Green (`#2E7D32`):** Active / operational status.
  - **Red (`#D32F2F`):** Inactive status, delete buttons, and validation errors.
  - **Amber (`#E65100`):** Under Maintenance status.

---

## Core Feature Overview

### 1. Authentication (Mock Login)
- Centered card layout on soft gray background.
- Pre-filled sample credentials (`admin` / `password123`) for demonstration.
- Form validation and password visibility toggle.
- Navigates to Dashboard upon sign-in.

### 2. Fleet Dashboard
- 4 Operational Metric Cards:
  - **Total Vehicles** (Navy)
  - **Active Vehicles** (Green)
  - **Inactive Vehicles** (Red)
  - **Vehicles Under Maintenance** (Amber)
- Quick overview data table displaying the most recently updated units.
- Direct navigation to registration and full directory.

### 3. Vehicle Inventory Directory
- Comprehensive vehicle table displaying:
  - Vehicle Number
  - Company
  - Type
  - Brand
  - Model
  - Status (Color-coded badge)
  - Actions (Edit & Delete)
- **Search:** Real-time search across Vehicle Number, Company, Brand, and Model.
- **Filters:** Dropdown filters for Status and Type, with a "Clear Filters" action.
- **Pagination:** Configurable rows per page (5, 8, 12) with page counters and navigation.
- **Empty States:** Friendly feedback with filter reset button when queries return 0 results.

### 4. Vehicle Registration & Modification
- Reusable form component handling both **Registering** and **Editing** vehicles.
- Responsive 2-column layout on desktop, 1-column on mobile.
- Required-field validation with error messages.
- **Duplicate Number Prevention:** Validates vehicle number uniqueness against local mock data (excluding the vehicle's own ID during edits).

### 5. Local In-Memory Management
- Managed via `MockVehicleData` singleton with 10 seed corporate vehicles.
- All additions, updates, and deletions reflect instantly across all screens.
- Zero external backend dependencies or network overhead.

---

## Project Structure

```
vms-frontend/
├── lib/
│   ├── main.dart                    # Application bootstrap
│   ├── app.dart                     # MaterialApp & MainShell layout
│   │
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart      # VMS corporate color palette
│   │   │   ├── app_text_styles.dart # Typography scale
│   │   │   └── app_theme.dart       # Material 3 ThemeData
│   │   ├── constants/
│   │   │   └── app_constants.dart   # Layout dimensions & sample credentials
│   │   └── utils/
│   │       └── responsive.dart      # Breakpoint helper
│   │
│   ├── models/
│   │   └── vehicle.dart             # Vehicle entity & VehicleStatus enum
│   │
│   ├── data/
│   │   └── mock_vehicle_data.dart   # In-memory reactive fleet repository
│   │
│   ├── routing/
│   │   └── app_router.dart          # Navigation coordinator & screen state
│   │
│   ├── widgets/
│   │   ├── app_sidebar.dart         # Fixed left drawer with active highlights
│   │   ├── app_header.dart          # Clean white top bar with profile & search
│   │   ├── app_button.dart          # Standardized buttons (Primary, Secondary, Danger)
│   │   ├── app_text_field.dart      # Reusable form field
│   │   ├── app_dropdown.dart        # Reusable dropdown field
│   │   ├── status_badge.dart        # Pill status indicator
│   │   ├── confirmation_dialog.dart # Delete confirmation modal
│   │   └── empty_state.dart         # Clean empty state widget
│   │
│   └── screens/
│       ├── login/
│       │   └── login_screen.dart        # Corporate sign-in card
│       ├── dashboard/
│       │   └── dashboard_screen.dart    # KPI summary cards & overview table
│       └── vehicles/
│           ├── vehicle_list_screen.dart # Filterable data table & pagination
│           └── vehicle_form_screen.dart # Reusable register/edit form
```

---

## Running Locally

### With Host Runner:
```bash
cd /home/yeaish/repos/vms-frontend
./run.sh
```

### With Docker Compose:
```bash
cd /home/yeaish/repos/vms-frontend
docker compose up -d
```
Access at: [http://localhost:8080](http://localhost:8080)
