# Al Sewar Branch Manager App — Development Documentation

**Project:** `carwash_manager`  
**App Name:** Al Sewar Branch Manager  
**Last Updated:** 26 October 2026  

---

## Overview

A dedicated mobile application for branch managers at **Al Sewar Auto Center**.
This app is completely separate from the customer app. It allows a branch manager to manage operations for their assigned branch, view operating hours, access profile and authentication, and manage customers and their vehicles using secure, role-restricted backend APIs.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart SDK `^3.13.5`) |
| State Management | Riverpod 2.x (`flutter_riverpod`, `AsyncNotifier`, `Notifier`) |
| Architecture | MVVM (Model → Service → ViewModel → View) |
| HTTP Client | Dio 5.x |
| Secure Storage | `flutter_secure_storage` 9.x |
| Navigation | GoRouter 14.x |
| Code Generation | `riverpod_generator`, `build_runner` |
| Linting | `flutter_lints`, `riverpod_lint`, `custom_lint` |

---

## Backend Configuration

| Environment | Base URL |
|---|---|
| Android Emulator | `http://10.0.2.2:8001` |
| Physical Device (LAN) | `http://192.168.1.6:8001` |
| Localhost | `http://localhost:8001` |

> **Switch environments** by changing `baseUrl` in `lib/core/constants/api_constants.dart`.

Authentication uses **JWT Bearer tokens** on every request. Token refresh runs automatically upon 401 response without user disruption.

---

## Confirmed API Endpoints

| Method | Endpoint | Purpose |
|---|---|---|
| `POST` | `/api/manager/login/` | Manager authentication |
| `POST` | `/api/manager/token/refresh/` | Refresh expired access token |
| `POST` | `/api/manager/logout/` | Manager server-side logout & token invalidation |
| `GET` | `/api/manager/profile/` | Manager profile information |
| `GET` | `/api/manager/branch/` | Get manager's assigned branch |
| `GET` | `/api/manager/branch/hours/` | Get branch weekly operating hours |
| `GET` | `/api/manager/customers/` | List branch customers (supports `?search=` and `?phone=`) |
| `GET` | `/api/manager/customers/{id}/` | Get customer details and associated vehicles |
| `POST` | `/api/manager/customers/` | Register new customer for the assigned branch |
| `GET` | `/api/manager/vehicles/` | List branch vehicles (supports `?search=`, `?plate_number=`, `?customer_id=`, `?is_active=`) |
| `GET` | `/api/manager/vehicles/{id}/` | Get vehicle details |
| `POST` | `/api/manager/vehicles/` | Register new vehicle for a customer at the assigned branch |
| `PATCH` | `/api/manager/vehicles/{id}/` | Update vehicle details |
| `DELETE` | `/api/manager/vehicles/{id}/` | Soft-deactivate a vehicle |
| `GET` | `/api/manager/vehicles/{id}/history/` | Get lifetime cross-branch service visit history |

> ⚠️ The backend determines the branch from the JWT — no branch ID or manager ID is ever sent by the client.

---

## Project Structure

```
carwash_manager/
├── lib/
│   ├── main.dart                          # App entry point — ProviderScope
│   ├── app.dart                           # Root widget — MaterialApp.router
│   ├── core/
│   │   ├── constants/
│   │   │   └── api_constants.dart         # Base URLs + all endpoint paths
│   │   ├── network/
│   │   │   ├── api_client.dart            # Dio instance + auth interceptor & refresh
│   │   │   └── dio_provider.dart          # Riverpod Provider<Dio>
│   │   ├── router/
│   │   │   └── app_router.dart            # GoRouter — all named routes
│   │   ├── storage/
│   │   │   └── token_storage.dart         # JWT read/write/clear (secure storage)
│   │   └── theme/
│   │       └── app_theme.dart             # Brand theme: black + champagne gold
│   └── features/
│       ├── auth/
│       │   ├── models/
│       │   │   ├── manager_auth_model.dart     # Login response model
│       │   │   └── manager_profile_model.dart  # Profile response model
│       │   ├── services/
│       │   │   ├── auth_service.dart           # Login, logout API + error handling
│       │   │   └── profile_service.dart        # Profile API + error handling
│       │   ├── viewmodels/
│       │   │   ├── login_viewmodel.dart        # LoginState (sealed) + LoginViewModel
│       │   │   └── profile_viewmodel.dart      # AsyncNotifier<ManagerProfileModel>
│       │   └── views/
│       │       ├── splash_screen.dart          # Session check → route decision
│       │       ├── login_screen.dart           # Username/password form
│       │       └── profile_screen.dart         # Manager profile + logout
│       ├── branch/
│       │   ├── models/
│       │   │   └── branch_models.dart          # BranchModel + BusinessHourModel
│       │   ├── services/
│       │   │   └── branch_service.dart         # getMyAssignedBranch() + getMyBranchHours()
│       │   ├── viewmodels/
│       │   │   └── branch_viewmodel.dart       # AsyncNotifier + refresh()
│       │   └── views/
│       │       └── dashboard_screen.dart       # Main dashboard (real API data + quick actions)
│       ├── customer/
│       │   ├── models/
│       │   │   └── customer_models.dart        # CustomerListItem, CustomerVehicle, CustomerDetailModel
│       │   ├── services/
│       │   │   └── customer_service.dart       # getCustomers, getCustomer, registerCustomer
│       │   ├── viewmodels/
│       │   │   └── customer_viewmodel.dart     # List, Detail, and Register ViewModels
│       │   └── views/
│       │       ├── customer_list_screen.dart   # List, search bar, empty/loading/error states
│       │       ├── customer_detail_screen.dart # Detailed info, status badge, vehicles card
│       │       └── customer_register_screen.dart # Registration form with validation
│       └── vehicle/
│           ├── models/
│           │   └── vehicle_models.dart         # VehicleModel, VehicleServiceHistoryModel, VehicleVisitItem
│           ├── services/
│           │   └── vehicle_service.dart        # getVehicles, getVehicle, register, update, delete, getVehicleHistory
│           ├── viewmodels/
│           │   └── vehicle_viewmodel.dart      # List, Detail, History, and Form ViewModels
│           └── views/
│               ├── vehicle_list_screen.dart    # Vehicle listing with search & customer filtering
│               ├── vehicle_detail_screen.dart  # Vehicle details, specifications, owner & branch cards
│               ├── vehicle_form_screen.dart    # Register & edit vehicle forms
│               └── vehicle_history_screen.dart # Cross-branch service history timeline
└── test/
    └── widget_test.dart                   # 52 unit & integration tests
```

---

## Features Implemented

### Phase 1 & 2 — Foundation & Authentication
- Material 3 Desert Luxe palette (black, warm white, champagne gold).
- Secure JWT token persistence via `flutter_secure_storage`.
- Splash session restoration.
- Manager login with form validation and role enforcement.

### Phase 3 — Branch Dashboard, Profile & Session Refresh
- Assigned branch details card, contact info, location info.
- Operating hours with Mon–Sun ordering and formatted timings.
- Silent access token refresh on 401 via `_AuthInterceptor` with recursion protection.
- Server-side logout endpoint integration.
- Dedicated `ProfileScreen` powered by `GET /api/manager/profile/`.

### Phase 4.1 — Customer Management
- `GET /api/manager/customers/`: Customer list with name/username/email search and phone filter.
- `GET /api/manager/customers/{id}/`: Customer detail with account info and associated vehicles.
- `POST /api/manager/customers/`: Customer registration with input validation.

### Phase 4.2 — Vehicle Management
- **Vehicle List (`VehicleListScreen`):**
  - `GET /api/manager/vehicles/`
  - Search across `plate_number`, `make`, `model`, and `vin`.
  - Filterable by specific customer ID (pre-filtered when navigating from Customer Details).
  - Pull-to-refresh, loading indicator, custom empty view with action buttons, retry on failure.
- **Vehicle Details (`VehicleDetailScreen`):**
  - `GET /api/manager/vehicles/{id}/`
  - Hero header with plate number badge and active status pill.
  - Specifications card (Make, Model, Year, Color, VIN).
  - Owner card with customer details and direct navigation button to customer profile.
  - Registered branch card.
- **Register & Edit Vehicle (`VehicleFormScreen`):**
  - `POST /api/manager/vehicles/` for registration.
  - `PATCH /api/manager/vehicles/{id}/` for editing.
  - Form validation: customer ID, plate number (auto-uppercased), make, model required; year (1900-2100), color, VIN optional.
- **Deactivate Vehicle:**
  - `DELETE /api/manager/vehicles/{id}/` with confirmation dialog before soft-deactivating.
  - Preserves service records while updating local state.
- **Cross-Branch Vehicle Service History (`VehicleHistoryScreen`):**
  - `GET /api/manager/vehicles/{id}/history/`
  - Lifetime cross-branch visit timeline showing visit numbers, branch names & codes, stages, services performed, and manager notes.

---

## Testing & Quality Assurance

**File:** `test/widget_test.dart` — **52 tests, all passing** ✅

| Test Suite | Total Tests | Description |
|---|---|---|
| `BranchModel.fromJson` | 2 | Parses all fields, handles nullable coordinates |
| `BusinessHourModel.fromJson` | 5 | Day parsing, closed days, formatting logic |
| `ManagerProfileModel.fromJson` | 5 | All fields, fallback display name, roles, active flags |
| `BranchService` | 4 | 401, 403, 404, network exceptions |
| `ProfileService` | 3 | 401, 404, network exceptions |
| `BranchViewModel` | 3 | Loading, data resolution, 404 error handling |
| `ProfileViewModel` | 3 | Loading, profile data resolution, 401 error handling |
| `CustomerListItem.fromJson` | 2 | JSON parsing and display name fallback |
| `CustomerVehicle.fromJson` | 2 | Vehicle attributes and summary formatting |
| `CustomerDetailModel.fromJson` | 2 | Detail mapping with and without vehicle lists |
| `CustomerService` | 5 | List parsing, search param pass-through, detail, register, 400 validation |
| `CustomerListViewModel` | 1 | Loading and data filtering |
| `CustomerRegisterViewModel` | 2 | State transitions (Idle → Loading → Success) |
| `VehicleModel.fromJson` | 2 | Field mapping, nested customer/branch info, computed titles |
| `VehicleServiceHistoryModel.fromJson` | 1 | Lifetime visit timeline, branches, stages, services |
| `VehicleService` | 11 | List, detail, register (required only & with optionals), PATCH update, DELETE deactivate, history, field-specific error extraction (400 validation, duplicate plate, invalid customer) |
| `VehicleListViewModel` | 1 | Fleet query and search |
| `VehicleFormViewModel` | 2 | Register and deactivate state transitions |

---

## 8. P4.2 Hotfix: Vehicle Registration Validation & Error Extraction

### Root Cause Analysis
1. **Generic Backend Error Extraction Stripped Field Names:**
   - In `VehicleService._extractDetail`, the error extractor looped over `data.values` and took `value.first.toString()` directly, completely stripping out the JSON key (e.g., `customer` or `plate_number`).
   - When Django REST Framework returned validation errors like `{"customer": ["This field is required."]}` or `{"plate_number": ["This field is required."]}`, the UI error banner presented only the generic text `"This field is required."`, concealing which field failed.
2. **Customer Field Key Variance:**
   - Certain DRF serializers expect `customer` while others look for `customer_id`.
   - The registration payload was updated to provide both `'customer': customerId` and `'customer_id': customerId` (integer) to satisfy both backend serializer variants.
3. **Customer Selection UX:**
   - In `VehicleFormScreen`, customer ID was previously a raw text field requiring manual integer entry.
   - Now integrates with `customerListViewModelProvider` so managers can pick registered customers from a dropdown displaying name and ID, with automatic preselection when navigating from Customer Detail and an option to enter an ID manually.
4. **Resilient Deserialization:**
   - `VehicleModel.fromJson` now extracts `customerId` from `json['customer']`, `json['customer_id']`, or nested map `json['customer']['id']` with fallback to `customerDetails?.id`.

**Verification Status:**
```
dart format .    → All files formatted cleanly ✅
flutter analyze  → No issues found! (0 warnings, 0 errors) ✅
flutter test     → 56/56 passed! ✅
```
