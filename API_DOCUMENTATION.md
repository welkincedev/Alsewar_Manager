# Al Sewar API Documentation for Frontend Developers

Comprehensive API reference for the **Al Sewar** backend.  
Base URL in local development: `http://localhost:8000`
**Base URL (Local Network / LAN):** `http://192.168.1.2:8001`
---

## Table of Contents

1. [Authentication & Authorization Overview](#1-authentication--authorization-overview)
2. [User Object Schema](#2-user-object-schema)
3. [Registration & User Management APIs](#3-registration--user-management-apis)
   - [Customer Self-Registration (`POST /api/customer/signup/`)](#31-customer-self-registration)
   - [Manager Registers Customer (`POST /api/manager/customers/`)](#32-manager-registers-a-customer)
   - [Admin Manager Management (`/api/admin/managers/`)](#33-admin-manager-management)
     - [List Managers (`GET /api/admin/managers/`)](#331-list-managers)
     - [Create Manager (`POST /api/admin/managers/`)](#332-create-manager)
     - [Get Manager Detail (`GET /api/admin/managers/{id}/`)](#333-get-manager-detail)
     - [Update Manager (`PATCH /api/admin/managers/{id}/`)](#334-update-manager)
     - [Safely Deactivate Manager (`DELETE /api/admin/managers/{id}/`)](#335-safely-deactivate-manager)
4. [Authentication & Session Endpoints](#4-authentication--session-endpoints)
   - [General Login (`POST /api/auth/login/`)](#41-general-login)
   - [Admin Portal Login (`POST /api/admin/login/`)](#42-admin-portal-login)
   - [Manager Portal Login (`POST /api/manager/login/`)](#43-manager-portal-login)
   - [Customer Portal Login (`POST /api/customer/login/`)](#44-customer-portal-login)
   - [Profile Endpoints (`GET /api/*/me/`)](#45-current-user-profile-endpoints)
   - [Refresh Token (`POST /api/auth/token/refresh/`)](#46-refresh-access-token)
   - [Logout (`POST /api/auth/logout/`)](#47-logout)
5. [Branches Module API Reference](#5-branches-module-api-reference)
   - [Admin Branch Management (`/api/admin/branches/`)](#51-admin-branch-management)
   - [Admin Business-Hours Management (`/api/admin/branch-hours/`)](#52-admin-business-hours-management)
   - [Admin Manager-to-Branch Assignment (`/api/admin/branches/assign-manager/`)](#53-admin-manager-to-branch-assignment)
   - [Customer Branch Endpoints (`/api/customer/branches/`)](#54-customer-branch-endpoints-read-only)
   - [Manager Branch Endpoints (`/api/manager/branch/`)](#55-manager-branch-endpoints)
6. [Managers Module API Reference](#6-managers-module-api-reference)
   - [Manager Profile (`GET /api/manager/profile/`)](#61-manager-profile-endpoint)
7. [Customer & Vehicle Management Module API Reference](#7-customer--vehicle-management-module-api-reference)
   - [Overview & Walk-In Service Flow](#71-overview--walk-in-service-flow)
   - [Manager Customer Listing & Detail (`/api/manager/customers/`)](#72-manager-customer-listing--detail)
   - [Manager Vehicle Management (`/api/manager/vehicles/`)](#73-manager-vehicle-management)
     - [Manager Cross-Branch Vehicle History (`/api/manager/vehicles/{id}/history/`)](#736-manager-cross-branch-vehicle-service-history)
   - [Customer Self-Service Vehicle Access (`/api/customer/vehicles/`)](#74-customer-self-service-vehicle-access)
     - [Customer Vehicle Service History (`/api/customer/vehicles/{id}/history/`)](#744-customer-vehicle-service-history)
   - [Customer Profile Management & Profile Picture (`/api/customer/profile/`)](#75-customer-profile-management--profile-picture)
8. [Service Catalogue & Branch Services Module API Reference](#8-service-catalogue--branch-services-module-api-reference)
   - [Admin Service Category Management (`/api/admin/service-categories/`)](#81-admin-service-category-management)
   - [Admin Service Catalogue Management (`/api/admin/services/`)](#82-admin-service-catalogue-management)
   - [Admin Branch Service Assignments (`/api/admin/branch-services/`)](#83-admin-branch-service-assignments)
   - [Manager Branch Services (`/api/manager/branch/services/`)](#84-manager-branch-services)
   - [Customer Service Categories & Browsing (`/api/customer/`)](#85-customer-service-categories--browsing)
9. [Service Visits & Service Status Workflow Module API Reference](#9-service-visits--service-status-workflow-module-api-reference)
   - [Overview & Walk-In Operational Workflow](#91-overview--walk-in-operational-workflow)
   - [Admin Service Status Stage Configuration (`/api/admin/stages/`)](#92-admin-service-status-stage-configuration)
   - [Admin Service Visits Oversight (`/api/admin/visits/`)](#93-admin-service-visits-oversight)
   - [Manager Service Visits & Status Updates (`/api/manager/visits/`)](#94-manager-service-visits--status-updates)
   - [Customer Service Visits & Live Tracking (`/api/customer/visits/`)](#95-customer-service-visits--live-tracking)
10. [Customer Reviews & Admin Moderation Module API Reference](#10-customer-reviews--admin-moderation-module-api-reference)
   - [Overview & Review Eligibility Rules](#101-overview--review-eligibility-rules)
   - [Customer Review Endpoints (`/api/customer/reviews/`)](#102-customer-review-endpoints)
   - [Manager Branch Reviews Endpoints (`/api/manager/reviews/`)](#103-manager-branch-reviews-endpoints)
   - [Admin Review Oversight & Moderation (`/api/admin/reviews/`)](#104-admin-review-oversight--moderation)
11. [Admin Dashboard & Basic Reports Module API Reference](#11-admin-dashboard--basic-reports-module-api-reference)
   - [Overview & Security Architecture](#111-overview--security-architecture)
   - [Admin Dashboard Summary (`GET /api/admin/dashboard/`)](#112-admin-dashboard-summary)
   - [Admin Reports Overview (`GET /api/admin/reports/`)](#113-admin-reports-overview)
   - [Admin Service Visits Report (`GET /api/admin/reports/visits/`)](#114-admin-service-visits-report)
   - [Admin Customer Reviews Report (`GET /api/admin/reports/reviews/`)](#115-admin-customer-reviews-report)
12. [Notifications & Device Tokens Module API Reference](#12-notifications--device-tokens-module-api-reference)
   - [Overview & Push Architecture](#121-overview--push-architecture)
   - [Customer Device Endpoints (`/api/customer/devices/`)](#122-customer-device-endpoints)
   - [Customer In-App Notifications (`/api/customer/notifications/`)](#123-customer-in-app-notifications)
   - [Manager Device & Notification Endpoints (`/api/manager/`)](#124-manager-device--notification-endpoints)
   - [Unified Authenticated Endpoints (`/api/notifications/`)](#125-unified-authenticated-endpoints)
   - [Admin Device & Dispatch Oversight (`/api/admin/`)](#126-admin-device--dispatch-oversight)
13. [Banner Management Module API Reference](#13-banner-management-module-api-reference)
   - [Overview & Multi-App Distribution](#131-overview--multi-app-distribution)
   - [Admin Banner Management (`/api/admin/banners/`)](#132-admin-banner-management)
   - [Customer Promotional Banners (`/api/customer/banners/`)](#133-customer-promotional-banners)
   - [Manager Announcements & Banners (`/api/manager/banners/`)](#134-manager-announcements--banners)
14. [Database Migrations & Test Verification](#14-database-migrations--test-verification)
15. [Frontend Integration Guide (Axios Example)](#15-frontend-integration-guide-axios-example)

---

## 1. Authentication & Authorization Overview

* **Token Format:** JSON Web Tokens (JWT) via SimpleJWT.
* **Header Format:** Authenticated requests must include:
  ```http
  Authorization: Bearer <access_token>
  Content-Type: application/json
  ```
* **Token Lifetimes:**
  * Access Token: `1 day`
  * Refresh Token: `7 days` (Rotation enabled)
* **Roles:**
  * `ADMIN`: Superuser / management access to all portals and managers.
  * `MANAGER`: Branch and customer management.
  * `CUSTOMER`: Store customers, browsing, ordering.

---

## 2. User Object Schema

All user-returning endpoints return the following standardized user object structure:

| Field | Type | Description |
|---|---|---|
| `id` | `integer` | Unique ID of the user. |
| `username` | `string` | Unique username. |
| `email` | `string` | User email address. |
| `role` | `string` | One of `"ADMIN"`, `"MANAGER"`, `"CUSTOMER"`. |
| `phone` | `string` or `null` | Phone number (unique if provided, or `null`). |
| `first_name` | `string` | User's first name. |
| `last_name` | `string` | User's last name. |
| `profile_picture` | `string` or `null` | Absolute URL to customer profile picture (or `null` if none uploaded). |
| `is_active` | `boolean` | `true` if account is active, `false` if deactivated. |

**Example User Object:**
```json
{
  "id": 12,
  "username": "sarah_k",
  "email": "sarah@example.com",
  "role": "CUSTOMER",
  "phone": "9876543210",
  "first_name": "Sarah",
  "last_name": "Khan",
  "profile_picture": "http://192.168.1.2:8001/media/profile_pictures/customer_12/3fa85f64-5717-4562-b3fc-2c963f66afa6.jpg",
  "is_active": true
}
```

---

## 3. Registration & User Management APIs

### 3.1 Customer Self-Registration
Allows new customers to create an account from the customer portal/app.

* **URL:** `POST /api/customer/signup/`
* **Access:** **Public** (no authentication required)
* **Headers:** `Content-Type: application/json`

#### Request Body:
| Field | Type | Required | Constraints |
|---|---|---|---|
| `username` | `string` | **Yes** | 3–150 characters, unique across all users. |
| `email` | `string` | **Yes** | Valid email format, unique across all users. |
| `password` | `string` | **Yes** | Minimum 6 characters. |
| `phone` | `string` | *Optional* | Max 15 chars; must be unique if provided. |
| `first_name` | `string` | *Optional* | First name. |
| `last_name` | `string` | *Optional* | Last name. |

> **Security Note:** If a client passes `"role"`, the backend automatically ignores it and forces `CUSTOMER`.

#### Example Request:
```json
POST /api/customer/signup/
Content-Type: application/json

{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "SecretPassword123!",
  "phone": "9876543210",
  "first_name": "John",
  "last_name": "Doe"
}
```

#### Success Response:
`HTTP 201 Created`
```json
{
  "id": 15,
  "username": "john_doe",
  "email": "john@example.com",
  "role": "CUSTOMER",
  "phone": "9876543210",
  "first_name": "John",
  "last_name": "Doe",
  "is_active": true
}
```

#### Error Responses:
* `HTTP 400 Bad Request` (Duplicate username / email):
  ```json
  {
    "username": ["A user with this username already exists."],
    "email": ["A user with this email already exists."]
  }
  ```
* `HTTP 400 Bad Request` (Invalid email):
  ```json
  {
    "email": ["Enter a valid email address."]
  }
  ```

---

### 3.2 Manager Registers a Customer
Allows a logged-in Manager to register a walk-in or phone customer.

* **URL:** `POST /api/manager/customers/`
* **Access:** **Authenticated Managers only** (`IsManagerRole`)
* **Headers:**
  ```http
  Authorization: Bearer <manager_access_token>
  Content-Type: application/json
  ```

#### Request Body:
Same validation rules as customer self-registration.

| Field | Type | Required | Constraints |
|---|---|---|---|
| `username` | `string` | **Yes** | Unique across all users. |
| `email` | `string` | **Yes** | Valid email, unique across all users. |
| `password` | `string` | **Yes** | Minimum 6 characters. |
| `phone` | `string` | *Optional* | Unique phone number. |
| `first_name` | `string` | *Optional* | First name. |
| `last_name` | `string` | *Optional* | Last name. |

#### Example Request:
```json
POST /api/manager/customers/
Authorization: Bearer <manager_access_token>
Content-Type: application/json

{
  "username": "walkin_customer1",
  "email": "walkin1@example.com",
  "password": "TemporaryPassword123!",
  "phone": "9123456789"
}
```

#### Success Response:
`HTTP 201 Created`
```json
{
  "id": 16,
  "username": "walkin_customer1",
  "email": "walkin1@example.com",
  "role": "CUSTOMER",
  "phone": "9123456789",
  "first_name": "",
  "last_name": "",
  "is_active": true
}
```

#### Error Responses:
* `HTTP 401 Unauthorized` (Token missing or expired):
  ```json
  {
    "detail": "Authentication credentials were not provided."
  }
  ```
* `HTTP 403 Forbidden` (User is not a Manager, e.g. Customer):
  ```json
  {
    "detail": "Manager access required."
  }
  ```

---

### 3.3 Admin Manager Management

All endpoints under `/api/admin/managers/` require **Admin authentication** (`IsAdminRole`).

#### 3.3.1 List Managers
Retrieves all users with the `MANAGER` role.

* **URL:** `GET /api/admin/managers/`
* **Access:** **Admin only**
* **Headers:** `Authorization: Bearer <admin_access_token>`

#### Success Response:
`HTTP 200 OK`
```json
[
  {
    "id": 4,
    "username": "branch_mgr_dubai",
    "email": "dubai_mgr@alsewar.com",
    "role": "MANAGER",
    "phone": "971501112233",
    "first_name": "Tariq",
    "last_name": "Al-Mansoor",
    "is_active": true
  },
  {
    "id": 8,
    "username": "branch_mgr_sharjah",
    "email": "sharjah_mgr@alsewar.com",
    "role": "MANAGER",
    "phone": "971509998877",
    "first_name": "Rashid",
    "last_name": "Salem",
    "is_active": false
  }
]
```

---

#### 3.3.2 Create Manager
Creates a new user with the `MANAGER` role automatically assigned.

* **URL:** `POST /api/admin/managers/`
* **Access:** **Admin only**
* **Headers:**
  ```http
  Authorization: Bearer <admin_access_token>
  Content-Type: application/json
  ```

#### Request Body:
| Field | Type | Required | Constraints |
|---|---|---|---|
| `username` | `string` | **Yes** | 3–150 chars, unique across all users. |
| `email` | `string` | **Yes** | Valid email format, unique across all users. |
| `password` | `string` | **Yes** | Minimum 6 characters. |
| `phone` | `string` | *Optional* | Unique phone number. |
| `first_name` | `string` | *Optional* | First name. |
| `last_name` | `string` | *Optional* | Last name. |

#### Example Request:
```json
POST /api/admin/managers/
Authorization: Bearer <admin_access_token>
Content-Type: application/json

{
  "username": "branch_mgr_abu_dhabi",
  "email": "ad_mgr@alsewar.com",
  "password": "ManagerPassword123!",
  "first_name": "Fahad",
  "last_name": "Al-Nuaimi",
  "phone": "971502233445"
}
```

#### Success Response:
`HTTP 201 Created`
```json
{
  "id": 18,
  "username": "branch_mgr_abu_dhabi",
  "email": "ad_mgr@alsewar.com",
  "role": "MANAGER",
  "phone": "971502233445",
  "first_name": "Fahad",
  "last_name": "Al-Nuaimi",
  "is_active": true
}
```

---

#### 3.3.3 Get Manager Detail
Retrieves a single manager by ID. (Non-manager IDs return 404).

* **URL:** `GET /api/admin/managers/{id}/`
* **Access:** **Admin only**
* **Headers:** `Authorization: Bearer <admin_access_token>`

#### Success Response:
`HTTP 200 OK`
```json
{
  "id": 18,
  "username": "branch_mgr_abu_dhabi",
  "email": "ad_mgr@alsewar.com",
  "role": "MANAGER",
  "phone": "971502233445",
  "first_name": "Fahad",
  "last_name": "Al-Nuaimi",
  "is_active": true
}
```

#### Error Response:
* `HTTP 404 Not Found`:
  ```json
  {
    "detail": "No User matches the given query."
  }
  ```

---

#### 3.3.4 Update Manager
Updates permitted manager details.

* **URL:** `PATCH /api/admin/managers/{id}/`
* **Access:** **Admin only**
* **Headers:**
  ```http
  Authorization: Bearer <admin_access_token>
  Content-Type: application/json
  ```

#### Permitted Fields to Update:
* `first_name` (`string`)
* `last_name` (`string`)
* `email` (`string`, must be unique if changed)
* `phone` (`string`, must be unique if changed)
* `username` (`string`, must be unique if changed)
* `is_active` (`boolean`, toggle account active state)

> **Security Note:** Privileged `role` escalation is strictly blocked. Any `"role"` sent in the request body is ignored.

#### Example Request:
```json
PATCH /api/admin/managers/18/
Authorization: Bearer <admin_access_token>
Content-Type: application/json

{
  "first_name": "Fahad Updated",
  "phone": "971509990000"
}
```

#### Success Response:
`HTTP 200 OK`
```json
{
  "id": 18,
  "username": "branch_mgr_abu_dhabi",
  "email": "ad_mgr@alsewar.com",
  "role": "MANAGER",
  "phone": "971509990000",
  "first_name": "Fahad Updated",
  "last_name": "Al-Nuaimi",
  "is_active": true
}
```

---

#### 3.3.5 Safely Deactivate Manager
Deactivates the manager account by setting `is_active = false`. The user record is **not permanently deleted** from the database and can be reactivated if needed.

* **URL:** `DELETE /api/admin/managers/{id}/`
* **Access:** **Admin only**
* **Headers:** `Authorization: Bearer <admin_access_token>`

#### Success Response:
`HTTP 200 OK`
```json
{
  "detail": "Manager deactivated successfully.",
  "user": {
    "id": 18,
    "username": "branch_mgr_abu_dhabi",
    "email": "ad_mgr@alsewar.com",
    "role": "MANAGER",
    "phone": "971509990000",
    "first_name": "Fahad Updated",
    "last_name": "Al-Nuaimi",
    "is_active": false
  }
}
```

---

## 4. Authentication & Session Endpoints

### 4.1 General Login
Login endpoint available for any valid user (Admin, Manager, or Customer).

* **URL:** `POST /api/auth/login/`
* **Access:** **Public**

#### Request Body:
```json
{
  "username": "your_username",
  "password": "your_password"
}
```

#### Success Response (`HTTP 200 OK`):
```json
{
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 15,
    "username": "john_doe",
    "email": "john@example.com",
    "role": "CUSTOMER",
    "phone": "9876543210",
    "first_name": "John",
    "last_name": "Doe",
    "is_active": true
  }
}
```

---

### 4.2 Admin Portal Login
Login strictly for users with the `ADMIN` role. Rejects managers or customers with `"Access denied for this role portal."`

* **URL:** `POST /api/admin/login/`
* **Access:** **Public**
* **Payload:** `{"username": "...", "password": "..."}`
* **Response:** Returns `refresh`, `access`, and `user` object.

---

### 4.3 Manager Portal Login
Login strictly for users with the `MANAGER` role. Rejects admins or customers with `"Access denied for this role portal."`

* **URL:** `POST /api/manager/login/`
* **Access:** **Public**
* **Payload:** `{"username": "...", "password": "..."}`
* **Response:** Returns `refresh`, `access`, and `user` object.

---

### 4.4 Customer Portal Login
Login strictly for users with the `CUSTOMER` role. Rejects admins or managers with `"Access denied for this role portal."`

* **URL:** `POST /api/customer/login/`
* **Access:** **Public**
* **Payload:** `{"username": "...", "password": "..."}`
* **Response:** Returns `refresh`, `access`, and `user` object.

---

### 4.5 Current User Profile Endpoints

Fetches the currently authenticated user's profile based on their Bearer token.

* `GET /api/auth/me/` — Any authenticated user (`IsAuthenticated`)
* `GET /api/admin/me/` — Authenticated Admin (`IsAuthenticated` + `IsAdminRole`)
* `GET /api/manager/me/` — Authenticated Manager (`IsAuthenticated` + `IsManagerRole`)
* `GET /api/customer/me/` — Authenticated Customer (`IsAuthenticated` + `IsCustomerRole`)

#### Headers:
```http
Authorization: Bearer <access_token>
```

#### Success Response (`HTTP 200 OK`):
```json
{
  "id": 15,
  "username": "john_doe",
  "email": "john@example.com",
  "role": "CUSTOMER",
  "phone": "9876543210",
  "first_name": "John",
  "last_name": "Doe",
  "profile_picture": "http://192.168.1.2:8001/media/profile_pictures/customer_15/8e4df45e-bf33-4f18-b2ef-3eaee50df7a2.jpg",
  "is_active": true
}
```

> **Note on Profile Picture:** If the customer has uploaded a profile picture via `/api/customer/profile/`, an absolute URL is returned in `profile_picture`. If no picture has been uploaded, `profile_picture` is `null`.

---

### 4.6 Refresh Access Token
Obtains a new access token using a valid refresh token.

* **URL:** `POST /api/auth/token/refresh/`
* **Access:** **Public**

#### Request Body:
```json
{
  "refresh": "<refresh_token>"
}
```

#### Success Response (`HTTP 200 OK`):
```json
{
  "access": "<new_access_token>",
  "refresh": "<new_rotated_refresh_token>"
}
```

---

### 4.7 Logout
Blacklists the refresh token so it cannot be used again.

* **URL:** `POST /api/auth/logout/`
* **Access:** **Authenticated**
* **Headers:** `Authorization: Bearer <access_token>`

#### Request Body:
```json
{
  "refresh": "<refresh_token_to_blacklist>"
}
```

#### Success Response (`HTTP 200 OK`):
```json
{
  "detail": "Logout successful."
}
```

---

## 5. Branches Module API Reference

### Overview & Access Matrix

| Role | Endpoint Prefix | Allowed Actions |
|---|---|---|
| **ADMIN** | `/api/admin/branches/`<br>`/api/admin/branch-hours/`<br>`/api/admin/branches/assign-manager/`<br>`/api/admin/branches/assignments/` | Full CRUD on Branches, safe deactivation (`is_active=False`), Business Hours management, and Manager-to-Branch assignments. |
| **CUSTOMER** | `/api/customer/branches/` | Read-only listing and detail of **active** branches and their operating hours. |
| **MANAGER** | `/api/manager/branch/` | Read-only access to manager's assigned branch and business hours (strictly isolated to assigned branch). |

---

### 5.1 Admin Branch Management

#### 5.1.1 List All Branches
* **Method & URL:** `GET /api/admin/branches/`
* **Access:** `IsAuthenticated` + `IsAdminRole`
* **Headers:** `Authorization: Bearer <admin_access_token>`
* **Success Response (`200 OK`):**
```json
[
  {
    "id": 1,
    "name": "Dubai Downtown Branch",
    "code": "DXB-DT-01",
    "address": "Sheikh Zayed Road, Building 4",
    "city": "Dubai",
    "phone": "+97141234567",
    "whatsapp_number": "+96891234567",
    "email": "downtown@alsewar.com",
    "latitude": "25.2048493",
    "longitude": "55.2707828",
    "is_active": true,
    "created_at": "2026-10-09T10:00:00Z",
    "updated_at": "2026-10-09T10:00:00Z"
  }
]
```

#### 5.1.2 Create Branch
* **Method & URL:** `POST /api/admin/branches/`
* **Access:** `IsAuthenticated` + `IsAdminRole`
* **Headers:**
  ```http
  Authorization: Bearer <admin_access_token>
  Content-Type: application/json
  ```
* **Request Body:**
```json
{
  "name": "Dubai Downtown Branch",
  "code": "DXB-DT-01",
  "address": "Sheikh Zayed Road, Building 4",
  "city": "Dubai",
  "phone": "+97141234567",
  "whatsapp_number": "+96891234567",
  "email": "downtown@alsewar.com",
  "latitude": 25.2048493,
  "longitude": 55.2707828,
  "is_active": true
}
```
* **Validation Rules:**
  * `name`, `code`, `address`, `city`: Required, non-empty.
  * `code`: Must be unique across all branches (case-insensitive).
  * `whatsapp_number`: Optional string in international format (e.g. `+96891234567`), or blank for branches without WhatsApp.
  * `latitude`: Optional decimal between `-90.0` and `90.0`.
  * `longitude`: Optional decimal between `-180.0` and `180.0`.
* **Success Response (`201 Created`):**
```json
{
  "id": 1,
  "name": "Dubai Downtown Branch",
  "code": "DXB-DT-01",
  "address": "Sheikh Zayed Road, Building 4",
  "city": "Dubai",
  "phone": "+97141234567",
  "whatsapp_number": "+96891234567",
  "email": "downtown@alsewar.com",
  "latitude": "25.2048493",
  "longitude": "55.2707828",
  "is_active": true,
  "created_at": "2026-10-09T10:00:00Z",
  "updated_at": "2026-10-09T10:00:00Z"
}
```
* **Error Response (`400 Bad Request`):**
```json
{
  "code": ["A branch with this code already exists."],
  "whatsapp_number": ["WhatsApp number must be in international format (e.g. +96891234567)."],
  "latitude": ["Latitude must be between -90 and 90 degrees."]
}
```

#### 5.1.3 Retrieve Branch Detail
* **Method & URL:** `GET /api/admin/branches/<id>/`
* **Access:** `IsAuthenticated` + `IsAdminRole`
* **Success Response (`200 OK`):** Returns single branch object.
* **Error Response (`404 Not Found`):** `{"detail": "No Branch matches the given query."}`

#### 5.1.4 Update Branch
* **Method & URL:** `PUT /api/admin/branches/<id>/` (full) or `PATCH /api/admin/branches/<id>/` (partial)
* **Access:** `IsAuthenticated` + `IsAdminRole`
* **Request Body (PATCH example):**
```json
{
  "name": "Dubai Downtown Flagship",
  "phone": "+97149998888",
  "whatsapp_number": "+96898765432"
}
```
* **Success Response (`200 OK`):** Returns updated branch object.

#### 5.1.5 Safely Deactivate Branch
* **Method & URL:** `DELETE /api/admin/branches/<id>/`
* **Access:** `IsAuthenticated` + `IsAdminRole`
* **Behavior:** Sets `is_active = False` on the branch. Does **not** physically delete database records.
* **Success Response (`200 OK`):**
```json
{
  "detail": "Branch deactivated successfully.",
  "branch": {
    "id": 1,
    "name": "Dubai Downtown Flagship",
    "code": "DXB-DT-01",
    "address": "Sheikh Zayed Road, Building 4",
    "city": "Dubai",
    "phone": "+97149998888",
    "whatsapp_number": "+96898765432",
    "email": "downtown@alsewar.com",
    "latitude": "25.2048493",
    "longitude": "55.2707828",
    "is_active": false,
    "created_at": "2026-10-09T10:00:00Z",
    "updated_at": "2026-10-09T10:15:00Z"
  }
}
```

---

### 5.2 Admin Business-Hours Management

#### 5.2.1 List Business Hours
* **Method & URL:** `GET /api/admin/branch-hours/` (or filter: `GET /api/admin/branch-hours/?branch=<branch_id>`)
* **Access:** `IsAuthenticated` + `IsAdminRole`
* **Success Response (`200 OK`):**
```json
[
  {
    "id": 1,
    "branch": 1,
    "branch_name": "Dubai Downtown Branch",
    "day_of_week": 0,
    "day_name": "Monday",
    "opening_time": "09:00:00",
    "closing_time": "18:00:00",
    "is_closed": false
  },
  {
    "id": 2,
    "branch": 1,
    "branch_name": "Dubai Downtown Branch",
    "day_of_week": 6,
    "day_name": "Sunday",
    "opening_time": null,
    "closing_time": null,
    "is_closed": true
  }
]
```

#### 5.2.2 Create Business Hour
* **Method & URL:** `POST /api/admin/branch-hours/`
* **Access:** `IsAuthenticated` + `IsAdminRole`
* **Request Body (Open Day):**
```json
{
  "branch": 1,
  "day_of_week": 0,
  "opening_time": "09:00:00",
  "closing_time": "18:00:00",
  "is_closed": false
}
```
* **Request Body (Closed Day):**
```json
{
  "branch": 1,
  "day_of_week": 6,
  "is_closed": true
}
```
* **Validation Rules:**
  * Open days (`is_closed: false`): Require both `opening_time` and `closing_time`, with `closing_time > opening_time`.
  * Closed days (`is_closed: true`): Allowed without times.
  * Unique constraint: Only one schedule entry allowed per `(branch, day_of_week)`.
* **Success Response (`201 Created`):** Returns created business hour object.
* **Error Response (`400 Bad Request`):**
```json
{
  "non_field_errors": [
    "Business hours for this branch on this weekday already exist."
  ]
}
```

#### 5.2.3 Retrieve / Update / Delete Business Hour
* `GET /api/admin/branch-hours/<id>/` &rarr; Returns business hour object (`200 OK`).
* `PUT/PATCH /api/admin/branch-hours/<id>/` &rarr; Updates hour record (`200 OK`).
* `DELETE /api/admin/branch-hours/<id>/` &rarr; Physically deletes schedule record:
```json
{
  "detail": "Branch business hour deleted successfully."
}
```

---

### 5.3 Admin Manager-to-Branch Assignment

Admins have full authority to assign or reassign branch managers to branches, unassign managers, and query all assignments.

* **Business Rules:**
  * Every manager (`role="MANAGER"`) can be assigned to **at most one branch** at any time.
  * Reassigning a manager to another branch automatically updates their single assigned branch.
  * Multiple managers **can** be assigned to the same branch.
  * Non-manager accounts (`CUSTOMER` or `ADMIN`) cannot be assigned to branches.
  * Branch managers cannot assign themselves or manipulate branch IDs.

#### 5.3.1 Assign / Reassign / Unassign Manager
* **Method & URL:** `POST /api/admin/branches/assign-manager/` (or without trailing slash)
* **Access:** `IsAuthenticated` + `IsAdminRole`
* **Headers:**
  ```http
  Authorization: Bearer <admin_access_token>
  Content-Type: application/json
  ```

##### Request Body (Assign or Reassign to Branch):
```json
{
  "manager_id": 4,
  "branch_id": 1
}
```

##### Request Body (Unassign Manager from Branch):
```json
{
  "manager_id": 4,
  "branch_id": null
}
```

##### Success Response (`HTTP 200 OK` — Assigned):
```json
{
  "detail": "Manager 'sarah_mgr' assigned to branch 'Dubai Downtown Branch' successfully.",
  "assignment": {
    "id": 1,
    "manager_id": 4,
    "manager_username": "sarah_mgr",
    "manager_email": "sarah@alsewar.com",
    "branch_id": 1,
    "branch_name": "Dubai Downtown Branch",
    "assigned_at": "2026-10-10T11:27:00Z"
  }
}
```

##### Success Response (`HTTP 200 OK` — Unassigned):
```json
{
  "detail": "Manager 'sarah_mgr' unassigned from branch successfully.",
  "assignment": {
    "id": 1,
    "manager_id": 4,
    "manager_username": "sarah_mgr",
    "manager_email": "sarah@alsewar.com",
    "branch_id": null,
    "branch_name": null,
    "assigned_at": "2026-10-10T11:28:00Z"
  }
}
```

##### Error Responses:
* `HTTP 400 Bad Request` — Non-manager user:
  ```json
  {
    "manager_id": [
      "The selected user is not a Manager."
    ]
  }
  ```
* `HTTP 400 Bad Request` — Manager user not found:
  ```json
  {
    "manager_id": [
      "Manager user does not exist."
    ]
  }
  ```
* `HTTP 400 Bad Request` — Branch not found:
  ```json
  {
    "branch_id": [
      "The selected branch does not exist."
    ]
  }
  ```
* `HTTP 401 Unauthorized` — Missing or invalid token.
* `HTTP 403 Forbidden` — Authenticated as non-Admin.

---

#### 5.3.2 List Manager Assignments
* **Method & URL:** `GET /api/admin/branches/assignments/` (or without trailing slash)
* **Access:** `IsAuthenticated` + `IsAdminRole`
* **Optional Query Filters:**
  * `?branch=<branch_id>` — List only managers assigned to a specific branch.
* **Headers:**
  ```http
  Authorization: Bearer <admin_access_token>
  ```

##### Success Response (`HTTP 200 OK`):
```json
[
  {
    "id": 1,
    "manager_id": 4,
    "manager_username": "sarah_mgr",
    "manager_email": "sarah@alsewar.com",
    "branch_id": 1,
    "branch_name": "Dubai Downtown Branch",
    "assigned_at": "2026-10-10T11:27:00Z"
  },
  {
    "id": 2,
    "manager_id": 5,
    "manager_username": "tariq_mgr",
    "manager_email": "tariq@alsewar.com",
    "branch_id": 1,
    "branch_name": "Dubai Downtown Branch",
    "assigned_at": "2026-10-10T11:27:30Z"
  }
]
```

---

### 5.4 Customer Branch Endpoints (Read-Only)

All customer branch endpoints require customer authentication (`IsAuthenticated` + `IsCustomerRole`).  
**Inactive branches (`is_active=False`) are completely hidden and return `404 Not Found`.**

#### 5.4.1 List Active Branches
* **Method & URL:** `GET /api/customer/branches/` (or without trailing slash)
* **Access:** `IsAuthenticated` + `IsCustomerRole`
* **Headers:** `Authorization: Bearer <customer_access_token>`
* **Success Response (`HTTP 200 OK`):**
```json
[
  {
    "id": 1,
    "name": "Dubai Downtown Branch",
    "code": "DXB-DT-01",
    "address": "Sheikh Zayed Road, Building 4",
    "city": "Dubai",
    "phone": "+97141234567",
    "whatsapp_number": "+96891234567",
    "email": "downtown@alsewar.com",
    "latitude": "25.2048493",
    "longitude": "55.2707828",
    "is_active": true
  }
]
```

#### 5.4.2 Retrieve Active Branch Detail
* **Method & URL:** `GET /api/customer/branches/<id>/` (or without trailing slash)
* **Access:** `IsAuthenticated` + `IsCustomerRole`
* **Success Response (`HTTP 200 OK`):**
```json
{
  "id": 1,
  "name": "Dubai Downtown Branch",
  "code": "DXB-DT-01",
  "address": "Sheikh Zayed Road, Building 4",
  "city": "Dubai",
  "phone": "+97141234567",
  "whatsapp_number": "+96891234567",
  "email": "downtown@alsewar.com",
  "latitude": "25.2048493",
  "longitude": "55.2707828",
  "is_active": true
}
```
* **Error Response (`HTTP 404 Not Found`):** If branch does not exist or `is_active=False`.

#### 5.4.3 Retrieve Branch Operating Hours
* **Method & URL:** `GET /api/customer/branches/<id>/hours/` (or without trailing slash)
* **Access:** `IsAuthenticated` + `IsCustomerRole`
* **Success Response (`HTTP 200 OK`):**
```json
[
  {
    "id": 1,
    "day_of_week": 0,
    "day_name": "Monday",
    "opening_time": "09:00:00",
    "closing_time": "18:00:00",
    "is_closed": false
  },
  {
    "id": 2,
    "day_of_week": 6,
    "day_name": "Sunday",
    "opening_time": null,
    "closing_time": null,
    "is_closed": true
  }
]
```
* **Error Response (`HTTP 404 Not Found`):** If parent branch does not exist or `is_active=False`.

---

### 5.5 Manager Branch Endpoints

Branch managers use these endpoints to securely view their assigned store details and operating hours.

* **Method & URL:**
  * `GET /api/manager/branch/` — Retrieve the manager's assigned branch.
  * `GET /api/manager/branch/hours/` — Retrieve business hours of the assigned branch.
* **Access:** `IsAuthenticated` + `IsManagerRole`
* **Headers:** `Authorization: Bearer <manager_access_token>`
* **Security & Isolation Enforcement:**
  * Never trusts branch ID or manager ID from client parameters; resolves exclusively via `request.user` & `ManagerProfile`.
  * Attempting to append query parameters (such as `?branch_id=2`) has no effect; the manager will only receive their assigned branch.
  * A manager cannot modify their own assignment or access another branch.

#### 5.5.1 When Manager is Assigned to a Branch
* **`GET /api/manager/branch/` (`HTTP 200 OK`):**
```json
{
  "id": 1,
  "name": "Dubai Downtown Branch",
  "code": "DXB-DT-01",
  "address": "Sheikh Zayed Road, Building 4",
  "city": "Dubai",
  "phone": "+97141234567",
  "whatsapp_number": "+96891234567",
  "email": "downtown@alsewar.com",
  "latitude": "25.2048493",
  "longitude": "55.2707828",
  "is_active": true,
  "created_at": "2026-10-09T10:00:00Z",
  "updated_at": "2026-10-09T10:00:00Z"
}
```

* **`GET /api/manager/branch/hours/` (`HTTP 200 OK`):**
```json
[
  {
    "id": 1,
    "day_of_week": 0,
    "day_name": "Monday",
    "opening_time": "09:00:00",
    "closing_time": "18:00:00",
    "is_closed": false
  },
  {
    "id": 2,
    "day_of_week": 6,
    "day_name": "Sunday",
    "opening_time": null,
    "closing_time": null,
    "is_closed": true
  }
]
```

#### 5.5.2 When Manager Has No Assigned Branch
* **Both endpoints return `HTTP 404 Not Found`:**
```json
{
  "detail": "No branch is currently assigned to this manager."
}
```

---

---

## 6. Managers Module API Reference

### Overview & Access Matrix

| Role | Endpoint | Method | Allowed Actions |
|---|---|---|---|
| **MANAGER** | `/api/manager/profile/` | `GET` | Retrieve the authenticated manager's personal profile details and assigned branch information. |

---

### 6.1 Manager Profile Endpoint

Returns the authenticated manager's existing User profile information along with their assigned branch details (or `null` if unassigned).

* **Method & URL:** `GET /api/manager/profile/` (and `/api/manager/profile`)
* **Access:** `IsAuthenticated` + `IsManagerRole`
* **Headers:**
  ```http
  Authorization: Bearer <manager_access_token>
  ```
* **Security & Isolation Enforcement:**
  * Uses `request.user` exclusively.
  * Never accepts a manager ID or branch ID from query parameters or request body.
  * A manager cannot access or view another manager's profile.

#### 6.1.1 Success Response — Manager Assigned to a Branch (`HTTP 200 OK`):
```json
{
  "id": 4,
  "username": "sarah_mgr",
  "email": "sarah@alsewar.com",
  "role": "MANAGER",
  "phone": "+971501112233",
  "first_name": "Sarah",
  "last_name": "Khan",
  "is_active": true,
  "date_joined": "2026-10-09T10:00:00Z",
  "branch": {
    "id": 1,
    "name": "Dubai Downtown Branch",
    "code": "DXB-DT-01",
    "address": "Sheikh Zayed Road, Building 4",
    "city": "Dubai",
    "phone": "+97141234567",
    "email": "downtown@alsewar.com",
    "is_active": true
  },
  "assigned_at": "2026-10-10T11:27:00Z"
}
```

#### 6.1.2 Success Response — Manager Not Assigned to Any Branch (`HTTP 200 OK`):
```json
{
  "id": 5,
  "username": "tariq_mgr",
  "email": "tariq@alsewar.com",
  "role": "MANAGER",
  "phone": null,
  "first_name": "Tariq",
  "last_name": "Ali",
  "is_active": true,
  "date_joined": "2026-10-09T11:00:00Z",
  "branch": null,
  "assigned_at": null
}
```

#### 6.1.3 Error Responses:
* `HTTP 401 Unauthorized` — Missing, invalid, or expired Bearer token:
  ```json
  {
    "detail": "Authentication credentials were not provided."
  }
  ```
* `HTTP 403 Forbidden` — Authenticated user does not have `MANAGER` role (e.g. `CUSTOMER` or `ADMIN`):
  ```json
  {
    "detail": "Manager access required."
  }
  ```

---

## 7. Customer & Vehicle Management Module API Reference

### 7.1 Overview & Walk-In Service Flow

In the Al Sewar service centre model, walk-in workflow is the primary operational interaction:
1. **Walk-in Customer Arrival:** A customer arrives at a branch.
2. **Customer Lookup or Registration:**
   - The manager searches for existing customers by phone number or name (`GET /api/manager/customers/?phone=...`).
   - If new, the manager registers the customer (`POST /api/manager/customers/`). The customer is automatically linked to the manager's assigned branch via `CustomerProfile`.
3. **Vehicle Registration:**
   - The manager registers one or more vehicles for that customer (`POST /api/manager/vehicles/`).
   - The vehicle is linked to the customer and the manager's branch.
4. **Customer Self-Service:**
   - Customers can log into their portal and view or manage their own registered vehicles (`/api/customer/vehicles/`).
5. **No Booking / Slots:**
   - There are no online appointments, slots, or job cards in this module.

---

### 7.2 Manager Customer Listing & Detail

#### 7.2.1 List and Search Customers
Allows authenticated branch managers to list all customers and filter by phone number or general search term.

* **URL:** `GET /api/manager/customers/` (or `GET /api/manager/customers`)
* **Access:** **Manager only** (`IsManagerRole`)
* **Headers:**
  ```http
  Authorization: Bearer <manager_access_token>
  ```
* **Query Parameters:**
  * `phone` *(optional)*: Filter by customer phone number (case-insensitive substring match).
  * `search` *(optional)*: Multi-field search across `username`, `email`, `phone`, `first_name`, and `last_name`.

##### Success Response (`HTTP 200 OK`):
```json
[
  {
    "id": 15,
    "username": "salman_k",
    "email": "salman@example.com",
    "role": "CUSTOMER",
    "phone": "971501234567",
    "first_name": "Salman",
    "last_name": "Khan",
    "is_active": true,
    "date_joined": "2026-10-10T11:00:00Z",
    "registered_branch": {
      "id": 1,
      "name": "Al Sewar Muscat Main Branch",
      "code": "MCT01"
    },
    "vehicles": [
      {
        "id": 4,
        "plate_number": "DXB-A-12345",
        "make": "Toyota",
        "model": "Camry",
        "year": 2022,
        "color": "Silver",
        "vin": "1HGCR2F83HA000000"
      }
    ]
  }
]
```

#### 7.2.2 Get Customer Detail
Allows authenticated branch managers to retrieve full profile and vehicle details for a single customer.

* **URL:** `GET /api/manager/customers/{id}/` (or `GET /api/manager/customers/{id}`)
* **Access:** **Manager only** (`IsManagerRole`)
* **Headers:**
  ```http
  Authorization: Bearer <manager_access_token>
  ```

##### Success Response (`HTTP 200 OK`):
```json
{
  "id": 15,
  "username": "salman_k",
  "email": "salman@example.com",
  "role": "CUSTOMER",
  "phone": "971501234567",
  "first_name": "Salman",
  "last_name": "Khan",
  "is_active": true,
  "date_joined": "2026-10-10T11:00:00Z",
  "registered_branch": {
    "id": 1,
    "name": "Al Sewar Muscat Main Branch",
    "code": "MCT01"
  },
  "vehicles": [
    {
      "id": 4,
      "plate_number": "DXB-A-12345",
      "make": "Toyota",
      "model": "Camry",
      "year": 2022,
      "color": "Silver",
      "vin": "1HGCR2F83HA000000"
    }
  ]
}
```

##### Error Responses:
* `HTTP 401 Unauthorized`: Missing or invalid Bearer token.
* `HTTP 403 Forbidden`: Authenticated user is not a manager.
* `HTTP 404 Not Found`: Customer does not exist or user is not a customer role.

---

### 7.3 Manager Vehicle Management

#### 7.3.1 List and Search Vehicles
Allows branch managers to search and inspect registered vehicles.

* **URL:** `GET /api/manager/vehicles/` (or `GET /api/manager/vehicles`)
* **Access:** **Manager only** (`IsManagerRole`)
* **Headers:**
  ```http
  Authorization: Bearer <manager_access_token>
  ```
* **Query Parameters:**
  * `customer_id` *(optional)*: Filter vehicles belonging to a specific customer ID.
  * `plate_number` *(optional)*: Filter by plate number (case-insensitive substring match).
  * `search` *(optional)*: Search across `plate_number`, `make`, `model`, or `vin`.
  * `is_active` *(optional)*: Filter by active status (`true`, `false`, or `ALL`). Defaults to active vehicles only (`is_active=True`).

##### Success Response (`HTTP 200 OK`):
```json
[
  {
    "id": 4,
    "customer": 15,
    "customer_details": {
      "id": 15,
      "username": "salman_k",
      "first_name": "Salman",
      "last_name": "Khan",
      "phone": "971501234567"
    },
    "branch": 1,
    "branch_details": {
      "id": 1,
      "name": "Al Sewar Muscat Main Branch",
      "code": "MCT01"
    },
    "plate_number": "DXB-A-12345",
    "make": "Toyota",
    "model": "Camry",
    "year": 2022,
    "color": "Silver",
    "vin": "1HGCR2F83HA000000",
    "created_at": "2026-10-10T12:00:00Z",
    "updated_at": "2026-10-10T12:00:00Z"
  }
]
```

#### 7.3.2 Register Vehicle for Customer
Allows authenticated managers to register a vehicle for a walk-in customer. The vehicle is automatically associated with the manager's assigned branch.

* **URL:** `POST /api/manager/vehicles/` (or `POST /api/manager/vehicles`)
* **Access:** **Manager only** (`IsManagerRole`)
* **Headers:**
  ```http
  Authorization: Bearer <manager_access_token>
  Content-Type: application/json
  ```

##### Request Body:
```json
{
  "customer": 15,
  "plate_number": "DXB-A-12345",
  "make": "Toyota",
  "model": "Camry",
  "year": 2022,
  "color": "Silver",
  "vin": "1HGCR2F83HA000000"
}
```

| Field | Type | Required | Notes |
|---|---|---|---|
| `customer` | `integer` | **Yes** | ID of the customer (must have role `CUSTOMER`). |
| `plate_number` | `string` | **Yes** | Unique identifier. Automatically trimmed and converted to UPPERCASE. |
| `make` | `string` | **Yes** | Vehicle make (e.g., "Toyota", "Nissan"). |
| `model` | `string` | **Yes** | Vehicle model (e.g., "Camry", "Patrol"). |
| `year` | `integer` | No | Model year (1900 - 2100). |
| `color` | `string` | No | Body color. |
| `vin` | `string` | No | Vehicle Identification Number (max 50 chars). |

##### Success Response (`HTTP 201 Created`):
```json
{
  "id": 4,
  "customer": 15,
  "customer_details": {
    "id": 15,
    "username": "salman_k",
    "first_name": "Salman",
    "last_name": "Khan",
    "phone": "971501234567"
  },
  "branch": 1,
  "branch_details": {
    "id": 1,
    "name": "Al Sewar Muscat Main Branch",
    "code": "MCT01"
  },
  "plate_number": "DXB-A-12345",
  "make": "Toyota",
  "model": "Camry",
  "year": 2022,
  "color": "Silver",
  "vin": "1HGCR2F83HA000000",
  "created_at": "2026-10-10T12:00:00Z",
  "updated_at": "2026-10-10T12:00:00Z"
}
```

##### Error Responses:
* `HTTP 400 Bad Request` — Duplicate plate number:
  ```json
  {
    "plate_number": ["A vehicle with this plate number already exists."]
  }
  ```
* `HTTP 400 Bad Request` — Invalid customer ID or customer not of role `CUSTOMER`:
  ```json
  {
    "customer": ["Selected user is not a valid customer."]
  }
  ```

#### 7.3.3 Get Vehicle Detail
* **URL:** `GET /api/manager/vehicles/{id}/` (or `GET /api/manager/vehicles/{id}`)
* **Access:** **Manager only** (`IsManagerRole`)
* **Headers:** `Authorization: Bearer <manager_access_token>`

#### 7.3.4 Update Vehicle
* **URL:** `PATCH /api/manager/vehicles/{id}/` (or `PATCH /api/manager/vehicles/{id}`)
* **Access:** **Manager only** (`IsManagerRole`)
* **Headers:** `Authorization: Bearer <manager_access_token>`, `Content-Type: application/json`

##### Request Body (partial update):
```json
{
  "color": "Dark Blue",
  "year": 2023
}
```

##### Success Response (`HTTP 200 OK`):
Returns the updated vehicle object.

#### 7.3.5 Delete Vehicle
* **URL:** `DELETE /api/manager/vehicles/{id}/` (or `DELETE /api/manager/vehicles/{id}`)
* **Access:** **Manager only** (`IsManagerRole`)
* **Headers:** `Authorization: Bearer <manager_access_token>`

##### Success Response (`HTTP 200 OK`):
```json
{
  "detail": "Vehicle deleted successfully."
}
```

##### Behavior & Protection:
* Sets `is_active=False` in the database (safe soft deletion).
* Prevents `ProtectedError` (HTTP 500) when existing service visits reference the vehicle.
* Preserves all linked `ServiceVisit`, `VisitService`, `ServiceVisitStatusHistory`, and `Review` records.
* Inactive vehicles are excluded from default manager vehicle listings (`GET /api/manager/vehicles/`) and detail lookups.
* Lifetime cross-branch service history remains accessible via `GET /api/manager/vehicles/{id}/history/`.
* A repeated `DELETE` returns `HTTP 404 Not Found`.

#### 7.3.6 Manager Cross-Branch Vehicle Service History
* **URL:** `GET /api/manager/vehicles/{id}/history/` (or `GET /api/manager/vehicles/{id}/history`)
* **Access:** **Manager only** (`IsManagerRole`)
* **Headers:** `Authorization: Bearer <manager_access_token>`
* **Description:** Returns the lifetime service visit history for the requested vehicle across all service centre branches. Manager write permissions and existing visit detail views remain strictly branch-scoped.
* **Success Response (`HTTP 200 OK`):**
  ```json
  {
    "vehicle": {
      "id": 1,
      "customer": {
        "id": 4,
        "username": "cust_owner",
        "email": "cust1@alsewar.com",
        "phone": "+96891234567",
        "first_name": "Ahmed",
        "last_name": "Al Harthy"
      },
      "branch": {
        "id": 1,
        "name": "Muscat Main Branch",
        "code": "MCT-01"
      },
      "plate_number": "1111-AA",
      "make": "Toyota",
      "model": "Camry",
      "year": 2022,
      "color": "White",
      "vin": "VIN1111111111",
      "created_at": "2026-10-10T12:00:00Z",
      "updated_at": "2026-10-10T12:00:00Z"
    },
    "visit_count": 2,
    "last_visit_date": "2026-10-12T14:30:00Z",
    "visits": [
      {
        "id": 12,
        "visit_number": "SV-V1-002",
        "branch": {
          "id": 2,
          "name": "Salalah Branch",
          "code": "SLL-01",
          "city": "Salalah"
        },
        "branch_details": {
          "id": 2,
          "name": "Salalah Branch",
          "code": "SLL-01",
          "city": "Salalah"
        },
        "current_stage": {
          "id": 3,
          "name": "Completed",
          "code": "COMPLETED",
          "order": 3,
          "is_terminal": true
        },
        "services": [
          {
            "id": 2,
            "name": "Brake Inspection",
            "description": "Front & rear brake check",
            "notes": ""
          }
        ],
        "status_history": [
          {
            "id": 25,
            "stage_name": "Completed",
            "stage_code": "COMPLETED",
            "notes": "Work finished",
            "changed_by": "mgr_branch_b",
            "created_at": "2026-10-12T16:00:00Z"
          }
        ],
        "notes": "Brake inspection at Branch B",
        "created_at": "2026-10-12T14:30:00Z",
        "updated_at": "2026-10-12T16:00:00Z"
      }
    ]
  }
  ```
* **Error Responses:**
  * `HTTP 401 Unauthorized`: Missing or invalid Bearer token.
  * `HTTP 403 Forbidden`: Authenticated user is not a manager.
  * `HTTP 404 Not Found`: Vehicle with requested ID does not exist.

---

### 7.4 Customer Self-Service Vehicle Access

Customers can manage their own registered vehicles directly from the customer app. Data isolation guarantees that customers can only view, edit, or delete their own vehicles. Soft-deleted/archived vehicles are automatically excluded from the active fleet list.

#### 7.4.1 List Own Vehicles
* **URL:** `GET /api/customer/vehicles/` (or `GET /api/customer/vehicles`)
* **Access:** **Customer only** (`IsCustomerRole`)
* **Headers:** `Authorization: Bearer <customer_access_token>`
* **Description:** Returns all active vehicles owned by the authenticated customer. Excludes soft-deleted vehicles.

##### Success Response (`HTTP 200 OK`):
```json
[
  {
    "id": 4,
    "plate_number": "DXB-A-12345",
    "make": "Toyota",
    "model": "Camry",
    "year": 2022,
    "color": "Silver",
    "vin": "1HGCR2F83HA000000",
    "branch": 1,
    "branch_name": "Al Sewar Muscat Main Branch",
    "created_at": "2026-10-10T12:00:00Z",
    "updated_at": "2026-10-10T12:00:00Z"
  }
]
```

#### 7.4.2 Register Own Vehicle
Customers can register a new vehicle under their own account. The owner is automatically assigned to `request.user`.

* **URL:** `POST /api/customer/vehicles/` (or `POST /api/customer/vehicles`)
* **Access:** **Customer only** (`IsCustomerRole`)
* **Headers:**
  ```http
  Authorization: Bearer <customer_access_token>
  Content-Type: application/json
  ```

##### Request Body:
```json
{
  "plate_number": "DXB-B-99887",
  "make": "Honda",
  "model": "Civic",
  "year": 2021,
  "color": "White"
}
```

##### Success Response (`HTTP 201 Created`):
```json
{
  "id": 5,
  "plate_number": "DXB-B-99887",
  "make": "Honda",
  "model": "Civic",
  "year": 2021,
  "color": "White",
  "vin": null,
  "branch": null,
  "branch_name": null,
  "created_at": "2026-10-10T12:15:00Z",
  "updated_at": "2026-10-10T12:15:00Z"
}
```

#### 7.4.3 Customer Vehicle Detail, Update, and Delete
* `GET /api/customer/vehicles/{id}/` — Retrieve own vehicle. Returns active vehicle details (`HTTP 200 OK`). Archived vehicles return `HTTP 404 Not Found`.
* `PATCH /api/customer/vehicles/{id}/` — Update own vehicle details (`HTTP 200 OK`).
* `DELETE /api/customer/vehicles/{id}/` — Soft-delete own vehicle (`HTTP 200 OK`).
  * **Headers:** `Authorization: Bearer <customer_access_token>`
  * **Method:** `DELETE`
  * **Success Response (`HTTP 200 OK`):**
    ```json
    {
      "detail": "Vehicle deleted successfully."
    }
    ```
  * **Behavior & Protection:**
    * Sets `is_active=False` in the database (safe soft delete).
    * The vehicle immediately disappears from active list endpoints (`GET /api/customer/vehicles/`).
    * Preserves all linked `ServiceVisit`, `VisitService`, `ServiceVisitStatusHistory`, and `Review` records without data loss.
    * Historical service visit records remain queryable via `GET /api/customer/vehicles/{id}/history/`.
    * A repeated `DELETE` returns `HTTP 404 Not Found`.
* **Access Control Note:** Attempting to retrieve, modify, or delete a vehicle belonging to another customer returns `HTTP 404 Not Found`.

#### 7.4.4 Customer Vehicle Service History
* **URL:** `GET /api/customer/vehicles/{id}/history/` (or `GET /api/customer/vehicles/{id}/history`)
* **Access:** **Customer only** (`IsCustomerRole`)
* **Headers:** `Authorization: Bearer <customer_access_token>`
* **Description:** Returns the lifetime service visit history for a specific vehicle owned by the authenticated customer. Returns `404 Not Found` if the vehicle belongs to another customer account or does not exist.
* **Success Response (`HTTP 200 OK`):**
  ```json
  {
    "vehicle": {
      "id": 1,
      "branch": {
        "id": 1,
        "name": "Muscat Main Branch",
        "code": "MCT-01"
      },
      "plate_number": "1111-AA",
      "make": "Toyota",
      "model": "Camry",
      "year": 2022,
      "color": "White",
      "vin": "VIN1111111111",
      "created_at": "2026-10-10T12:00:00Z",
      "updated_at": "2026-10-10T12:00:00Z"
    },
    "visit_count": 2,
    "last_visit_date": "2026-10-12T14:30:00Z",
    "visits": [
      {
        "id": 12,
        "visit_number": "SV-V1-002",
        "branch": {
          "id": 2,
          "name": "Salalah Branch",
          "city": "Salalah",
          "phone": "+96823123456"
        },
        "branch_details": {
          "id": 2,
          "name": "Salalah Branch",
          "city": "Salalah",
          "phone": "+96823123456"
        },
        "current_stage": {
          "id": 3,
          "name": "Completed",
          "code": "COMPLETED",
          "description": "Service completed and ready for pickup",
          "is_terminal": true
        },
        "services": [
          {
            "id": 2,
            "name": "Brake Inspection",
            "description": "Front & rear brake check"
          }
        ],
        "status_history": [
          {
            "id": 25,
            "stage_name": "Completed",
            "stage_description": "Service completed and ready for pickup",
            "notes": "Work finished",
            "created_at": "2026-10-12T16:00:00Z"
          }
        ],
        "notes": "Brake inspection at Branch B",
        "created_at": "2026-10-12T14:30:00Z",
        "updated_at": "2026-10-12T16:00:00Z"
      }
    ]
  }
  ```
* **Error Responses:**
  * `HTTP 401 Unauthorized`: Missing or invalid Bearer token.
  * `HTTP 403 Forbidden`: Authenticated user is not in the `CUSTOMER` role.
  * `HTTP 404 Not Found`: Vehicle does not exist, or belongs to another customer account.

---

### 7.5 Customer Profile Management & Profile Picture

Comprehensive profile viewing, personal detail updating, and profile picture management for authenticated customers via the Customer Mobile App and Web Portal.

#### Overview & Security Enforcement
* **Authentication:** JWT Bearer Token (`Authorization: Bearer <customer_access_token>`).
* **Permissions:** Restricted to customers (`IsAuthenticated` + `IsCustomerRole`). Unauthenticated requests return `HTTP 401 Unauthorized`. Non-customer roles (Manager, Admin) return `HTTP 403 Forbidden`.
* **Zero Target Spoofing:** Endpoints always resolve the profile strictly via `request.user`. The backend rejects query parameters or request body fields attempting to specify another customer ID.
* **Strict Allowlist:** Only `first_name`, `last_name`, `email`, and `profile_picture` can be modified. Protected fields (`id`, `username`, `phone`, `role`, `is_active`, `is_staff`, `is_superuser`, `password`, `registered_branch`, `created_at`, `date_joined`) are strictly read-only and ignored if sent.

---

#### 7.5.1 Get Customer Profile
Fetches the authenticated customer's full profile, including user account info, registered branch details, and profile picture.

* **URL:** `GET /api/customer/profile/` (and `/api/customer/profile`)
* **Access:** **Customer only** (`IsCustomerRole`)
* **Headers:**
  ```http
  Authorization: Bearer <customer_access_token>
  ```

##### Success Response (`HTTP 200 OK`):
```json
{
  "id": 15,
  "username": "salman_k",
  "first_name": "Salman",
  "last_name": "Khan",
  "email": "salman@example.com",
  "phone": "+96891234567",
  "role": "CUSTOMER",
  "profile_picture": "http://192.168.1.2:8001/media/profile_pictures/customer_15/8e4df45e-bf33-4f18-b2ef-3eaee50df7a2.jpg",
  "registered_branch": {
    "id": 1,
    "name": "Al Sewar Muscat Main Branch",
    "code": "MCT01",
    "city": "Muscat"
  },
  "created_at": "2026-10-10T11:00:00Z"
}
```

*Note:* If no picture has been uploaded, `"profile_picture": null`. If the customer was registered without an assigned branch, `"registered_branch": null`.

##### Error Responses:
* `HTTP 401 Unauthorized`:
  ```json
  {
    "detail": "Authentication credentials were not provided."
  }
  ```
* `HTTP 403 Forbidden`:
  ```json
  {
    "detail": "Access denied for this role portal."
  }
  ```

---

#### 7.5.2 Update Customer Profile & Upload Picture
Allows customers to update their name, email address, and upload or replace their profile picture.

* **URL:** `PATCH /api/customer/profile/` (and `/api/customer/profile`)
* **Access:** **Customer only** (`IsCustomerRole`)
* **Headers:**
  * For text-only updates:
    ```http
    Authorization: Bearer <customer_access_token>
    Content-Type: application/json
    ```
  * For image upload / multipart updates:
    ```http
    Authorization: Bearer <customer_access_token>
    Content-Type: multipart/form-data
    ```

##### Field Specifications:
| Field | Type | Formats / Constraints | Allowed in Multipart? | Allowed in JSON? |
|---|---|---|---|---|
| `first_name` | `string` | Optional, max 150 chars. | Yes | Yes |
| `last_name` | `string` | Optional, max 150 chars. | Yes | Yes |
| `email` | `string` | Optional, valid email syntax, unique across accounts. | Yes | Yes |
| `profile_picture` | `file` | Optional, JPEG, PNG, or WEBP. Max size: 2 MB. | Yes (`multipart/form-data`) | No (use multipart) |

##### Read-Only / Protected Fields (Ignored if provided):
`id`, `username`, `phone`, `role`, `is_active`, `is_staff`, `is_superuser`, `password`, `registered_branch`, `created_at`, `date_joined`.

##### Profile Picture Validation & Storage Rules:
* **True Content Verification:** Validates actual binary content using Pillow (`Image.open(file).verify()`), not just the filename extension or HTTP `Content-Type`.
* **Allowed Image Formats:** JPEG, PNG, WEBP.
* **Maximum File Size:** 2 MB (`2,097,152 bytes`). Files exceeding 2 MB return `HTTP 400 Bad Request`.
* **Safe Storage Path:** `profile_pictures/customer_{user_id}/{uuid}.{ext}`.
* **Old File Cleanup:** When a customer uploads a replacement picture, the previous image file is automatically and safely purged from disk storage upon successful database update.
* **Safe Error Handling:** If validation fails, no file is saved to storage and the existing profile picture remains untouched.

##### Example 1: Updating Name and Email (JSON Request):
```http
PATCH /api/customer/profile/
Authorization: Bearer <customer_access_token>
Content-Type: application/json

{
  "first_name": "Salman",
  "last_name": "Al Balushi",
  "email": "salman.albalushi@example.com"
}
```

##### Example 2: Uploading / Replacing Profile Picture (Multipart Request):
```http
PATCH /api/customer/profile/
Authorization: Bearer <customer_access_token>
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW

------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="first_name"

Salman
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="profile_picture"; filename="avatar.jpg"
Content-Type: image/jpeg

<binary image data>
------WebKitFormBoundary7MA4YWxkTrZu0gW--
```

##### Success Response (`HTTP 200 OK`):
```json
{
  "id": 15,
  "username": "salman_k",
  "first_name": "Salman",
  "last_name": "Al Balushi",
  "email": "salman.albalushi@example.com",
  "phone": "+96891234567",
  "role": "CUSTOMER",
  "profile_picture": "http://192.168.1.2:8001/media/profile_pictures/customer_15/e4b6d34e-0012-4f3b-871d-76495b59a68c.jpg",
  "registered_branch": {
    "id": 1,
    "name": "Al Sewar Muscat Main Branch",
    "code": "MCT01",
    "city": "Muscat"
  },
  "created_at": "2026-10-10T11:00:00Z"
}
```

##### Error Responses:
* `HTTP 400 Bad Request` — Image size exceeds 2 MB:
  ```json
  {
    "profile_picture": [
      "Profile picture file size cannot exceed 2 MB. Uploaded size is 3.42 MB."
    ]
  }
  ```
* `HTTP 400 Bad Request` — Corrupt or non-image file:
  ```json
  {
    "profile_picture": [
      "Upload a valid image. The file you submitted is corrupted or not an image."
    ]
  }
  ```
* `HTTP 400 Bad Request` — Unsupported image format (e.g. GIF, BMP, TIFF):
  ```json
  {
    "profile_picture": [
      "Unsupported image format: GIF. Allowed formats are JPEG, PNG, WEBP."
    ]
  }
  ```
* `HTTP 400 Bad Request` — Email already taken by another account:
  ```json
  {
    "email": [
      "A user with this email already exists."
    ]
  }
  ```

---

#### 7.5.3 Remove Customer Profile Picture
Removes the current customer profile picture from the database and safely deletes the image file from storage.

* **URL:** `DELETE /api/customer/profile/picture/` (and `/api/customer/profile/picture`)
* **Access:** **Customer only** (`IsCustomerRole`)
* **Headers:**
  ```http
  Authorization: Bearer <customer_access_token>
  ```

##### Success Response (`HTTP 200 OK`):
```json
{
  "detail": "Profile picture removed successfully.",
  "profile": {
    "id": 15,
    "username": "salman_k",
    "first_name": "Salman",
    "last_name": "Al Balushi",
    "email": "salman.albalushi@example.com",
    "phone": "+96891234567",
    "role": "CUSTOMER",
    "profile_picture": null,
    "registered_branch": {
      "id": 1,
      "name": "Al Sewar Muscat Main Branch",
      "code": "MCT01",
      "city": "Muscat"
    },
    "created_at": "2026-10-10T11:00:00Z"
  }
}
```

*Predictable idempotency:* If the customer calls this endpoint when no picture is set, the API responds with `HTTP 200 OK` and `"detail": "No profile picture was set."` without errors.

---

#### 7.5.4 Postman Profile Picture Upload Instructions

1. **Method & URL:** Set method to `PATCH` and URL to `http://127.0.0.1:8001/api/customer/profile/`.
2. **Authorization:** In the **Auth** tab, choose **Bearer Token** and paste the customer's JWT access token.
3. **Body Configuration:**
   - Under the **Body** tab, select **form-data**.
   - In the **Key** field, type `profile_picture`.
   - Hover over the right edge of the key input and change the type dropdown from **Text** to **File**.
   - In the **Value** column, click **Select Files** and choose a `.jpg`, `.png`, or `.webp` file under 2 MB.
   - *(Optional)* Add other keys: `first_name`, `last_name`, `email` with **Text** type.
4. **Headers:** Do **not** manually set `Content-Type`. Postman will automatically generate `multipart/form-data; boundary=...`.
5. **Send:** Click **Send**. The response contains the updated profile with the full `profile_picture` URL.

---

#### 7.5.5 Mobile App Integration Notes (React Native & Flutter)

##### React Native (Axios & FormData):
```javascript
import axios from 'axios';

export async function uploadProfilePicture(token, imageUri, imageType = 'image/jpeg') {
  const formData = new FormData();
  formData.append('profile_picture', {
    uri: imageUri,
    name: 'profile.jpg',
    type: imageType,
  });

  const response = await axios.patch('http://192.168.1.2:8001/api/customer/profile/', formData, {
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'multipart/form-data',
    },
  });

  return response.data;
}
```

##### Flutter (Dio):
```dart
import 'package:dio/dio.dart';

Future<Response> uploadProfilePicture(String token, String filePath) async {
  var dio = Dio();
  dio.options.headers["Authorization"] = "Bearer $token";

  FormData formData = FormData.fromMap({
    "profile_picture": await MultipartFile.fromFile(filePath, filename: "avatar.jpg"),
  });

  return await dio.patch("http://192.168.1.2:8001/api/customer/profile/", data: formData);
}
```

##### Mobile Best Practices:
1. **Client-side Compression:** Always resize user avatar photos (e.g. to max 1024x1024) and compress (e.g. 80% JPEG quality) before uploading to save mobile bandwidth and avoid exceeding the 2 MB limit.
2. **Cache Busting:** Because filenames contain unique UUIDs on every upload, images naturally invalidate cached URLs on the mobile client.
3. **Network URL Configuration:** In mobile development using physical devices or emulators, ensure `MEDIA_URL` uses your LAN IP (e.g., `http://192.168.1.2:8001/media/...`) rather than `localhost`.

---

---

## 8. Service Catalogue & Branch Services Module API Reference

### 8.0 Overview, Architecture & Lifecycle Workflow

#### 8.0.1 Architecture & Separation of Concerns
* **Admin Role (`ADMIN`):**
  * Maintains dynamic service categories (create, view, update, soft-deactivate). Category names are dynamically managed and never hardcoded.
  * Maintains the global service catalogue (create, view, update, deactivate services). Each service belongs to a mandatory active category upon creation.
  * Assigns services to branches and manages per-branch availability flags (`is_available`).
* **Manager Role (`MANAGER`):**
  * View-only access strictly scoped to the authenticated manager's assigned branch (`get_manager_assigned_branch`).
  * Views services available at their branch with category metadata (`category_id`, `category_name`) and optional category filtering (`?category={id}`).
* **Customer Role (`CUSTOMER`):**
  * Browses active service categories (`GET /api/customer/service-categories/`) with active services count and pre-populated service list.
  * Browses active services in the global catalogue or lists available services offered at a specific active branch, with optional category filtering (`?category={id}`).
  * Inactive categories and services assigned to inactive categories are automatically hidden from customer visibility.
* **Explicit Exclusions:**
  * No online bookings, time-slot scheduling, job cards/service visits, invoices, Odoo integration, base/branch pricing, loyalty points redemption, or subcategories in this phase.

#### 8.0.2 End-to-End Service Lifecycle Workflow
1. **Admin Creates a Service Category:** Admin creates a dynamic category (e.g. "Mechanical", "Body Services", "Detailing") with a display order and description (`POST /api/admin/service-categories/`).
2. **Admin Creates a Service:** Admin creates a service and selects an existing active category (`POST /api/admin/services/`). Category selection is mandatory.
3. **Admin Allocates Service to Branch:** Admin links the service to one or more branches (`POST /api/admin/branch-services/`) and toggles branch-specific availability (`is_available`).
4. **Customer App Discovers Categories & Services:** Customer fetches active categories (`GET /api/customer/service-categories/`) and browses services globally or per branch filtered by category (`GET /api/customer/services/?category={id}`).
5. **Manager App Inspects Branch Offerings:** Manager reviews services available at their assigned branch filtered by category (`GET /api/manager/branch/services/?category={id}`).

#### 8.0.3 Backward Compatibility & Data Protection
* **Legacy Service Records Preserved:** Existing service records created prior to category introduction are fully preserved.
* **Uncategorized Services Supported:** Legacy services with `category = null` remain viewable, assignable to branches, and updateable (e.g., modifying descriptions or active flags) without forcing immediate category assignment.
* **Non-Destructive Deactivation:** Soft-deactivating a category (`DELETE /api/admin/service-categories/{id}/`) sets `is_active = false`. It **never** hard-deletes the category, and does **not** delete or detach any associated services.
* **Existing Allocations & Visits Intact:** All existing `BranchService`, `ServiceVisit`, and `VisitService` records remain completely unaffected.
* **Additive API Design:** All previous API endpoint URLs, request methods, and response fields remain 100% unchanged. Category fields (`category`, `category_details`, `category_id`, `category_name`) are purely additive.

---

### 8.0.4 `ServiceCategory` Model & Field Specification

Model: `app.services.models.ServiceCategory`  
Serializer: `app.services.admin.serializers.AdminServiceCategorySerializer`

| Field | Type | Required | Read-Only | Description |
|---|---|---|---|---|
| `id` | `integer` | System | **Yes** | Primary key. |
| `name` | `string` | **Yes** | No | Unique category name (max 100 characters). Automatically trimmed; duplicate names (case-insensitive) are rejected. |
| `description` | `string` | No | No | Optional description of services grouped under this category. Defaults to empty string `""`. |
| `display_order` | `integer` | No | No | Positive integer used to control presentation sequence (lowest first). Defaults to `0`. |
| `is_active` | `boolean` | No | No | Category status flag. Defaults to `true`. Deactivation hides category offerings from customers. |
| `services_count` | `integer` | System | **Yes** | Total count of services currently assigned to this category. |
| `created_at` | `datetime` | System | **Yes** | Timestamp of creation (ISO 8601, UTC). |
| `updated_at` | `datetime` | System | **Yes** | Timestamp of last modification (ISO 8601, UTC). |

---

### 8.1 Admin Service Category Management

Allows administrators to dynamically define, view, edit, and soft-deactivate service categories.

#### 8.1.1 List & Search Categories
* **URL:** `GET /api/admin/service-categories/`
* **Access:** **Admin only** (`IsAdminRole`)
* **Headers:** `Authorization: Bearer <admin_access_token>`
* **Query Parameters:**
  * `search` *(optional)*: Case-insensitive search across category `name` or `description`.
  * `is_active` *(optional)*: Filter by active status (`true` / `1` or `false` / `0`).
* **Ordering:** Ordered by `display_order` ascending, then `name` ascending.
* **Success Response (`HTTP 200 OK`):**
  ```json
  [
    {
      "id": 1,
      "name": "Mechanical",
      "description": "Engine, transmission, and chassis maintenance",
      "display_order": 1,
      "is_active": true,
      "services_count": 4,
      "created_at": "2026-10-23T10:00:00Z",
      "updated_at": "2026-10-23T10:00:00Z"
    },
    {
      "id": 2,
      "name": "Body Services",
      "description": "Dent repair, panel beatings, and spray painting",
      "display_order": 2,
      "is_active": true,
      "services_count": 2,
      "created_at": "2026-10-23T10:05:00Z",
      "updated_at": "2026-10-23T10:05:00Z"
    }
  ]
  ```

#### 8.1.2 Create Category
* **URL:** `POST /api/admin/service-categories/`
* **Access:** **Admin only** (`IsAdminRole`)
* **Headers:** `Authorization: Bearer <admin_access_token>`, `Content-Type: application/json`
* **Request Body:**
  ```json
  {
    "name": "Detailing & Protection",
    "description": "Ceramic coating, paint protection film, and interior valet",
    "display_order": 3,
    "is_active": true
  }
  ```
  | Field | Type | Required | Description |
  |---|---|---|---|
  | `name` | `string` | **Yes** | Category name (must be unique). |
  | `description` | `string` | No | Optional description. |
  | `display_order` | `integer` | No | Display sequence (default `0`). |
  | `is_active` | `boolean` | No | Active toggle (default `true`). |

* **Success Response (`HTTP 201 Created`):**
  ```json
  {
    "id": 3,
    "name": "Detailing & Protection",
    "description": "Ceramic coating, paint protection film, and interior valet",
    "display_order": 3,
    "is_active": true,
    "services_count": 0,
    "created_at": "2026-10-23T10:20:00Z",
    "updated_at": "2026-10-23T10:20:00Z"
  }
  ```
* **Validation & Errors:**
  * `HTTP 400 Bad Request` (Duplicate): `{"name": ["A category with this name already exists."]}`
  * `HTTP 400 Bad Request` (Empty name): `{"name": ["Category name cannot be empty."]}`
  * `HTTP 401 Unauthorized`: Missing or invalid Bearer token.
  * `HTTP 403 Forbidden`: Authenticated user is not an administrator.

#### 8.1.3 Get Category Detail
* **URL:** `GET /api/admin/service-categories/{id}/`
* **Access:** **Admin only** (`IsAdminRole`)
* **Success Response (`HTTP 200 OK`):** Returns single category object with `services_count`.
* **Errors:** `HTTP 404 Not Found` if category does not exist.

#### 8.1.4 Update Category (Full PUT / Partial PATCH)
* **URL:** `PUT /api/admin/service-categories/{id}/` or `PATCH /api/admin/service-categories/{id}/`
* **Access:** **Admin only** (`IsAdminRole`)
* **Request Body (Example PATCH):**
  ```json
  {
    "display_order": 1,
    "description": "Updated high-priority mechanical repair section"
  }
  ```
* **Success Response (`HTTP 200 OK`):** Returns updated category object.
* **Errors:** `HTTP 400 Bad Request` on validation failure, `HTTP 404 Not Found` if ID does not exist.

#### 8.1.5 Soft-Deactivate Category (DELETE)
* **URL:** `DELETE /api/admin/service-categories/{id}/`
* **Access:** **Admin only** (`IsAdminRole`)
* **Behavior:** Safely sets `is_active = false`. Does **not** hard-delete the category record and does **not** delete or detach any associated services.
* **Success Response (`HTTP 200 OK`):**
  ```json
  {
    "detail": "Category deactivated successfully.",
    "category": {
      "id": 1,
      "name": "Mechanical",
      "description": "Engine, transmission, and chassis maintenance",
      "display_order": 1,
      "is_active": false,
      "services_count": 4,
      "created_at": "2026-10-23T10:00:00Z",
      "updated_at": "2026-10-23T10:30:00Z"
    }
  }
  ```

---

### 8.2 Admin Service Catalogue Management

Allows administrators to define and maintain the global catalogue of automotive repair and maintenance services.

#### 8.2.1 List & Search Services
* **URL:** `GET /api/admin/services/` (or `GET /api/admin/services`)
* **Access:** **Admin only** (`IsAdminRole`)
* **Headers:** `Authorization: Bearer <admin_access_token>`
* **Query Parameters:**
  * `search` *(optional)*: Search term matching service `name` or `description`.
  * `is_active` *(optional)*: Filter by active status (`true` or `false`).
  * `category` / `category_id` *(optional)*: Filter services belonging to a specific category ID. Pass `none` or `0` for uncategorized.
* **Success Response (`HTTP 200 OK`):**
  ```json
  [
    {
      "id": 1,
      "name": "Oil & Filter Change",
      "description": "Full synthetic oil and OEM filter replacement",
      "category": 1,
      "category_details": {
        "id": 1,
        "name": "Mechanical"
      },
      "is_active": true,
      "created_at": "2026-10-10T14:00:00Z",
      "updated_at": "2026-10-23T10:00:00Z"
    },
    {
      "id": 2,
      "name": "Legacy Brake Check",
      "description": "Uncategorized legacy service record",
      "category": null,
      "category_details": null,
      "is_active": true,
      "created_at": "2026-10-10T14:00:00Z",
      "updated_at": "2026-10-10T14:00:00Z"
    }
  ]
  ```

#### 8.2.2 Create Service
* **URL:** `POST /api/admin/services/` (or `POST /api/admin/services`)
* **Access:** **Admin only** (`IsAdminRole`)
* **Headers:** `Authorization: Bearer <admin_access_token>`, `Content-Type: application/json`
* **Validation Rules:**
  * `category` is **mandatory** when creating a new service.
  * The referenced category must exist and have `is_active = true`.
  * Attempting to assign an inactive or nonexistent category returns `HTTP 400 Bad Request`.
* **Request Body:**
  ```json
  {
    "name": "Wheel Alignment & Balancing",
    "description": "Computerized 3D 4-wheel alignment and high-speed wheel balancing",
    "category": 1,
    "is_active": true
  }
  ```
  | Field | Type | Required | Description |
  |---|---|---|---|
  | `name` | `string` | **Yes** | Unique service title. |
  | `category` | `integer` | **Yes** | ID of an active `ServiceCategory`. |
  | `description` | `string` | No | Optional service description. |
  | `is_active` | `boolean` | No | Defaults to `true`. |

* **Success Response (`HTTP 201 Created`):**
  ```json
  {
    "id": 9,
    "name": "Wheel Alignment & Balancing",
    "description": "Computerized 3D 4-wheel alignment and high-speed wheel balancing",
    "category": 1,
    "category_details": {
      "id": 1,
      "name": "Mechanical"
    },
    "is_active": true,
    "created_at": "2026-10-23T11:00:00Z",
    "updated_at": "2026-10-23T11:00:00Z"
  }
  ```
* **Errors:**
  * `HTTP 400 Bad Request` (Missing Category): `{"category": ["Category is required when creating a service."]}`
  * `HTTP 400 Bad Request` (Inactive Category): `{"category": ["Cannot assign a service to an inactive category."]}`
  * `HTTP 400 Bad Request` (Invalid Category ID): `{"category": ["Invalid pk \"999\" - object does not exist."]}`
  * `HTTP 400 Bad Request` (Duplicate Name): `{"name": ["A service with this name already exists."]}`
  * `HTTP 401 Unauthorized`: Missing or invalid Bearer token.
  * `HTTP 403 Forbidden`: User is not an admin.

#### 8.2.3 Get Service Detail
* **URL:** `GET /api/admin/services/{id}/`
* **Access:** **Admin only** (`IsAdminRole`)
* **Success Response (`HTTP 200 OK`):**
  ```json
  {
    "id": 1,
    "name": "Oil & Filter Change",
    "description": "Full synthetic oil and OEM filter replacement",
    "category": 1,
    "category_details": {
      "id": 1,
      "name": "Mechanical"
    },
    "is_active": true,
    "created_at": "2026-10-10T14:00:00Z",
    "updated_at": "2026-10-23T10:00:00Z"
  }
  ```
* **Errors:** `HTTP 404 Not Found` if service ID does not exist.

#### 8.2.4 Update Service (Full PUT / Partial PATCH)
* **URL:** `PUT /api/admin/services/{id}/` (Full) or `PATCH /api/admin/services/{id}/` (Partial)
* **Access:** **Admin only** (`IsAdminRole`)
* **Behavior:**
  * Admin can change a service's category by supplying a new active category ID.
  * Existing uncategorized services (`category = null`) can be updated without passing `category`.
  * If a service already has a category assigned, removing it (`"category": null`) is rejected.
  * Assigning an inactive category is rejected with `HTTP 400 Bad Request`.
* **Request Body (Example: Change Category via PATCH):**
  ```json
  {
    "category": 2,
    "description": "Updated description and moved under Body Services category"
  }
  ```
* **Success Response (`HTTP 200 OK`):**
  ```json
  {
    "id": 1,
    "name": "Oil & Filter Change",
    "description": "Updated description and moved under Body Services category",
    "category": 2,
    "category_details": {
      "id": 2,
      "name": "Body Services"
    },
    "is_active": true,
    "created_at": "2026-10-10T14:00:00Z",
    "updated_at": "2026-10-23T11:15:00Z"
  }
  ```

#### 8.2.5 Deactivate Service (DELETE)
* **URL:** `DELETE /api/admin/services/{id}/`
* **Access:** **Admin only** (`IsAdminRole`)
* **Behavior:** Safely deactivates the service (`is_active = false`).
* **Success Response (`HTTP 200 OK`):**
  ```json
  {
    "detail": "Service deactivated successfully.",
    "service": {
      "id": 1,
      "name": "Oil & Filter Change",
      "description": "Full synthetic oil and OEM filter replacement",
      "category": 1,
      "category_details": {
        "id": 1,
        "name": "Mechanical"
      },
      "is_active": false,
      "created_at": "2026-10-10T14:00:00Z",
      "updated_at": "2026-10-23T11:20:00Z"
    }
  }
  ```

---

### 8.3 Admin Branch Service Assignments

Allows administrators to allocate specific services to branches and control per-branch availability.

#### 8.3.1 List Branch Service Assignments
* **URL:** `GET /api/admin/branch-services/` (or `GET /api/admin/branch-services`)
* **Access:** **Admin only** (`IsAdminRole`)
* **Headers:** `Authorization: Bearer <admin_access_token>`
* **Query Parameters:**
  * `branch` / `branch_id` *(optional)*: Filter by branch ID.
  * `service` / `service_id` *(optional)*: Filter by service ID.
  * `is_available` *(optional)*: Filter by availability status (`true` / `false`).
* **Success Response (`HTTP 200 OK`):**
  ```json
  [
    {
      "id": 5,
      "branch": 1,
      "branch_details": {
        "id": 1,
        "name": "Al Sewar Muscat Main Branch",
        "code": "MCT01",
        "city": "Muscat",
        "is_active": true
      },
      "service": 2,
      "service_details": {
        "id": 2,
        "name": "Brake Pad Inspection",
        "description": "Front and rear brake disc and pad inspection",
        "category": 1,
        "category_name": "Mechanical",
        "is_active": true
      },
      "is_available": true,
      "created_at": "2026-10-10T14:10:00Z",
      "updated_at": "2026-10-10T14:10:00Z"
    }
  ]
  ```

#### 8.3.2 Assign Service to Branch
* **URL:** `POST /api/admin/branch-services/`
* **Access:** **Admin only** (`IsAdminRole`)
* **Request Body:**
  ```json
  {
    "branch": 1,
    "service": 9,
    "is_available": true
  }
  ```
* **Success Response (`HTTP 201 Created`):** Returns the created branch-service assignment with nested `branch_details` and `service_details`.
* **Errors:**
  * `HTTP 400 Bad Request`: If the service is already assigned to the branch or if branch/service IDs are invalid (`{"service": ["This service is already assigned to this branch."]}`).

#### 8.3.3 Update Branch Service Availability
* **URL:** `PATCH /api/admin/branch-services/{id}/`
* **Access:** **Admin only** (`IsAdminRole`)
* **Request Body:**
  ```json
  {
    "is_available": false
  }
  ```
* **Success Response (`HTTP 200 OK`):** Returns updated assignment object.

#### 8.3.4 Remove Service from Branch
* **URL:** `DELETE /api/admin/branch-services/{id}/`
* **Access:** **Admin only** (`IsAdminRole`)
* **Success Response (`HTTP 200 OK`):**
  ```json
  {
    "detail": "Branch service assignment removed successfully."
  }
  ```

---

### 8.4 Manager Branch Services

Allows branch managers to view the services offered by their assigned branch only.

#### 8.4.1 List Services for Manager's Assigned Branch
* **URL:** `GET /api/manager/branch/services/` (or alias `GET /api/manager/services/`)
* **Access:** **Manager only** (`IsManagerRole`)
* **Headers:** `Authorization: Bearer <manager_access_token>`
* **Query Parameters:**
  * `search` *(optional)*: Search by service name or description.
  * `category` / `category_id` *(optional)*: Filter services by category ID. Pass `none` or `0` for uncategorized.
  * `is_available` *(optional)*: Filter by `true` or `false`.
* **Success Response (`HTTP 200 OK`):**
  ```json
  [
    {
      "id": 5,
      "service_id": 2,
      "name": "Brake Pad Inspection",
      "description": "Front and rear brake disc and pad inspection",
      "category_id": 1,
      "category_name": "Mechanical",
      "is_available": true,
      "is_active": true,
      "branch_id": 1,
      "branch_name": "Al Sewar Muscat Main Branch",
      "created_at": "2026-10-10T14:10:00Z",
      "updated_at": "2026-10-10T14:10:00Z"
    }
  ]
  ```
* **Errors:**
  * `HTTP 404 Not Found`: If the authenticated manager is not currently assigned to any branch (`{"detail": "No branch is currently assigned to this manager."}`).

#### 8.4.2 Retrieve Branch Service Detail
* **URL:** `GET /api/manager/branch/services/{id}/` (or alias `GET /api/manager/services/{id}/`)
* **Access:** **Manager only** (`IsManagerRole`)
* **Security & Isolation:** Accessing a service offered by a different branch returns `HTTP 404 Not Found`.

---

### 8.5 Customer Service Categories & Browsing

Allows customers to browse active service categories or view active services globally or for a specific branch.

#### 8.5.1 List Service Categories
* **URL:** `GET /api/customer/service-categories/`
* **Access:** **Customer only** (`IsCustomerRole`)
* **Headers:** `Authorization: Bearer <customer_access_token>`
* **Description:** Returns all active categories ordered by `display_order` ascending, then `name` ascending. Excludes inactive categories. Each category object includes an active `services_count` and the array of active `services`.
* **Success Response (`HTTP 200 OK`):**
  ```json
  [
    {
      "id": 1,
      "name": "Mechanical",
      "description": "Engine, transmission, and chassis maintenance",
      "display_order": 1,
      "services_count": 2,
      "services": [
        {
          "id": 1,
          "name": "Oil & Filter Change",
          "description": "Full synthetic oil and OEM filter replacement",
          "category_id": 1,
          "category_name": "Mechanical"
        },
        {
          "id": 2,
          "name": "Brake Pad Inspection",
          "description": "Front and rear brake disc and pad inspection",
          "category_id": 1,
          "category_name": "Mechanical"
        }
      ]
    },
    {
      "id": 2,
      "name": "Body Services",
      "description": "Dent repair and spray painting",
      "display_order": 2,
      "services_count": 1,
      "services": [
        {
          "id": 3,
          "name": "Full Body Polish & Wax",
          "description": "Exterior compound polishing and Carnauba protective wax",
          "category_id": 2,
          "category_name": "Body Services"
        }
      ]
    }
  ]
  ```

#### 8.5.2 Browse Active Services
* **URL:** `GET /api/customer/services/` (or `GET /api/customer/services`)
* **Access:** **Customer only** (`IsCustomerRole`)
* **Headers:** `Authorization: Bearer <customer_access_token>`
* **Query Parameters:**
  * `search` *(optional)*: Search keyword matching service name or description.
  * `category` / `category_id` *(optional)*: Filter by category ID. Pass `none` or `0` for uncategorized.
* **Category Visibility Rule:** Automatically excludes services that belong to an inactive category.
* **Success Response (`HTTP 200 OK`):**
  ```json
  [
    {
      "id": 1,
      "name": "Oil & Filter Change",
      "description": "Full synthetic oil and OEM filter replacement",
      "category_id": 1,
      "category_name": "Mechanical"
    },
    {
      "id": 2,
      "name": "Brake Pad Inspection",
      "description": "Front and rear brake disc and pad inspection",
      "category_id": 1,
      "category_name": "Mechanical"
    }
  ]
  ```

#### 8.5.3 List Services Available at a Specific Branch
* **URL:** `GET /api/customer/branches/{branch_id}/services/`
* **Access:** **Customer only** (`IsCustomerRole`)
* **Headers:** `Authorization: Bearer <customer_access_token>`
* **Query Parameters:**
  * `search` *(optional)*: Search keyword matching service name or description.
  * `category` / `category_id` *(optional)*: Filter by category ID. Pass `none` or `0` for uncategorized.
* **Visibility Rule:** Only returns services that have `is_available = true`, `service.is_active = true`, and whose category is active (or uncategorized).
* **Success Response (`HTTP 200 OK`):**
  ```json
  [
    {
      "id": 10,
      "service_id": 1,
      "name": "Oil & Filter Change",
      "description": "Full synthetic oil and OEM filter replacement",
      "category_id": 1,
      "category_name": "Mechanical",
      "is_available": true
    }
  ]
  ```
* **Errors:**
  * `HTTP 404 Not Found`: If the branch is inactive or does not exist.

---

## 9. Service Visits & Service Status Workflow Module API Reference

### 9.1 Overview & Walk-In Operational Workflow

The Service Visits and Status Workflow module manages the end-to-end operational journey of a vehicle inside an Al Sewar service centre:
1. **Walk-In Check-In:**
   - A customer arrives at a branch.
   - The manager confirms customer identity and selects the customer's vehicle.
   - The manager selects one or more services from the active catalogue that are available at the manager's assigned branch.
   - The manager creates the service visit (`POST /api/manager/visits/`).
2. **Automated Tracking & Audit Log:**
   - The backend generates a unique `visit_number` (e.g. `SV-A1B2C3D4`).
   - The visit is initialized in the active starting stage (e.g. "Received").
   - An initial audit history entry is recorded in `status_history`.
3. **Stage Transitions:**
   - As technicians inspect and repair the vehicle, the manager advances the visit through status stages (`POST /api/manager/visits/{id}/update-status/`).
   - Every status transition is timestamped and attributes the manager who performed it.
4. **Customer Live Visibility:**
   - The customer can log in and view the current status and full milestone history of their vehicle (`GET /api/customer/visits/`).
5. **No Booking / Invoicing:**
   - No online appointment booking, time slot selection, or invoice/payment generation is part of this module.

---

### 9.2 Admin Service Status Stage Configuration

Allows administrators to configure and order the service status stages dynamically without hardcoding statuses in backend code.

> **Provisional Default Stages (Subject to Client Approval):**
> 1. `Received` (Order 1, `is_initial=True`)
> 2. `Inspection & Diagnosis` (Order 2)
> 3. `In Progress` (Order 3)
> 4. `Quality Check` (Order 4)
> 5. `Ready for Delivery` (Order 5)
> 6. `Completed` (Order 6, `is_terminal=True`)
> 7. `Cancelled` (Order 7, `is_terminal=True`)

#### 9.2.1 List Status Stages
* **URL:** `GET /api/admin/stages/` (or `GET /api/admin/stages`)
* **Access:** **Admin only** (`IsAdminRole`)
* **Headers:** `Authorization: Bearer <admin_access_token>`
* **Query Parameters:**
  * `is_active` *(optional)*: Filter by `true` or `false`.
  * `search` *(optional)*: Filter by name or code.
* **Success Response (`HTTP 200 OK`):**
  ```json
  [
    {
      "id": 1,
      "name": "Received",
      "code": "RECEIVED",
      "order": 1,
      "description": "Vehicle received at service centre",
      "is_active": true,
      "is_initial": true,
      "is_terminal": false,
      "created_at": "2026-10-10T16:00:00Z",
      "updated_at": "2026-10-10T16:00:00Z"
    }
  ]
  ```

#### 9.2.2 Create Status Stage
* **URL:** `POST /api/admin/stages/` (or `POST /api/admin/stages`)
* **Access:** **Admin only** (`IsAdminRole`)
* **Headers:** `Authorization: Bearer <admin_access_token>`, `Content-Type: application/json`
* **Request Body:**
  ```json
  {
    "name": "Quality Inspection",
    "order": 4,
    "description": "Final quality control inspection before delivery",
    "is_active": true,
    "is_initial": false,
    "is_terminal": false
  }
  ```
* **Success Response (`HTTP 201 Created`):** Returns created stage object.
* **Errors:**
  * `400 Bad Request`: If stage name already exists or is empty.

#### 9.2.3 Update Status Stage
* **URL:** `PUT /api/admin/stages/{id}/` (Full) or `PATCH /api/admin/stages/{id}/` (Partial)
* **Access:** **Admin only** (`IsAdminRole`)

#### 9.2.4 Delete Status Stage
* **URL:** `DELETE /api/admin/stages/{id}/`
* **Access:** **Admin only** (`IsAdminRole`)
* **Protection Rule:** If the stage is referenced by existing visits or history logs, deletion is safely blocked:
  ```json
  {
    "detail": "Cannot delete status stage because it is referenced by existing service visits. Deactivate it instead."
  }
  ```

---

### 9.3 Admin Service Visits Oversight

Allows administrators to review service visits across all branches for operations monitoring and reporting.

#### 9.3.1 List All Service Visits
* **URL:** `GET /api/admin/visits/` (or `GET /api/admin/visits`)
* **Access:** **Admin only** (`IsAdminRole`)
* **Headers:** `Authorization: Bearer <admin_access_token>`
* **Query Parameters:**
  * `branch` / `branch_id` *(optional)*: Filter by branch ID.
  * `customer` / `customer_id` *(optional)*: Filter by customer ID.
  * `vehicle` / `vehicle_id` *(optional)*: Filter by vehicle ID.
  * `stage` / `stage_id` *(optional)*: Filter by current status stage.
  * `search` *(optional)*: Search visit number, customer phone, username, or plate number.

#### 9.3.2 Get Service Visit Detail
* **URL:** `GET /api/admin/visits/{id}/`
* **Access:** **Admin only** (`IsAdminRole`)

---

### 9.4 Manager Service Visits & Status Updates

Allows branch managers to create walk-in visits and advance status stages for their assigned branch.

#### 9.4.1 Create Walk-In Service Visit
* **URL:** `POST /api/manager/visits/` (or `POST /api/manager/visits`)
* **Access:** **Manager only** (`IsManagerRole`)
* **Headers:** `Authorization: Bearer <manager_access_token>`, `Content-Type: application/json`
* **Request Body:**
  ```json
  {
    "customer": 15,
    "vehicle": 4,
    "service_ids": [1, 2],
    "notes": "Customer reports abnormal brake squeal and requested oil check",
    "stage_id": 1
  }
  ```
  | Field | Type | Required | Description |
  |---|---|---|---|
  | `customer` | `integer` | **Yes** | ID of registered customer. |
  | `vehicle` | `integer` | **Yes** | ID of vehicle (must belong to selected customer). |
  | `service_ids`| `array[int]` | No | Services to perform (must be available at manager's branch). |
  | `stage_id` | `integer` | No | Optional stage ID (defaults to active initial stage). |
  | `notes` | `string` | No | Walk-in / inspection notes. |

* **Success Response (`HTTP 201 Created`):**
  ```json
  {
    "id": 12,
    "visit_number": "SV-3B9F2A10",
    "customer": 15,
    "customer_details": {
      "id": 15,
      "username": "salman_k",
      "phone": "96891234567",
      "first_name": "Salman",
      "last_name": "Khan",
      "email": "salman@example.com"
    },
    "vehicle": 4,
    "vehicle_details": {
      "id": 4,
      "plate_number": "1234-AD",
      "make": "Toyota",
      "model": "Land Cruiser",
      "year": 2023,
      "color": "White",
      "vin": "JTMDH31U900000000"
    },
    "branch": 1,
    "branch_details": {
      "id": 1,
      "name": "Al Sewar Muscat Main Branch",
      "code": "MCT01",
      "city": "Muscat"
    },
    "created_by": 5,
    "current_stage": 1,
    "current_stage_details": {
      "id": 1,
      "name": "Received",
      "code": "RECEIVED",
      "order": 1,
      "is_terminal": false
    },
    "services": [
      {
        "id": 1,
        "service": 1,
        "service_name": "Oil & Filter Change",
        "service_description": "Full synthetic oil and OEM filter replacement",
        "notes": "",
        "created_at": "2026-10-10T16:30:00Z"
      }
    ],
    "status_history": [
      {
        "id": 1,
        "stage": 1,
        "stage_name": "Received",
        "stage_code": "RECEIVED",
        "changed_by": 5,
        "changed_by_name": "tariq_mgr",
        "notes": "Initial check-in",
        "created_at": "2026-10-10T16:30:00Z"
      }
    ],
    "notes": "Customer reports abnormal brake squeal and requested oil check",
    "created_at": "2026-10-10T16:30:00Z",
    "updated_at": "2026-10-10T16:30:00Z"
  }
  ```
* **Validation & Security Errors:**
  * `400 Bad Request` — Vehicle does not belong to customer:
    `{"vehicle": ["Selected vehicle does not belong to this customer."]}`
  * `400 Bad Request` — Service not available at manager's branch:
    `{"services": ["Service 'Wheel Alignment' is not currently available at your branch."]}`
  * `404 Not Found` — Manager is unassigned:
    `{"detail": "No branch is currently assigned to this manager."}`

#### 9.4.2 List Branch Service Visits
* **URL:** `GET /api/manager/visits/` (or `GET /api/manager/visits`)
* **Access:** **Manager only** (`IsManagerRole`)
* **Scope:** Automatically scoped to manager's assigned branch only.
* **Query Parameters:** `customer_id`, `vehicle_id`, `stage_id`, `search`.

#### 9.4.3 Get Service Visit Detail
* **URL:** `GET /api/manager/visits/{id}/`
* **Access:** **Manager only** (`IsManagerRole`)
* **Security & Isolation:** Accessing a visit from another branch returns `HTTP 404 Not Found`.

#### 9.4.4 Advance Status Workflow
* **URL:** `POST /api/manager/visits/{id}/update-status/` (or `PATCH /api/manager/visits/{id}/`)
* **Access:** **Manager only** (`IsManagerRole`)
* **Request Body:**
  ```json
  {
    "stage_id": 3,
    "notes": "Vehicle moved into repair bay 2; oil drained and filter replaced"
  }
  ```
* **Success Response (`HTTP 200 OK`):** Returns updated visit object with updated `current_stage` and prepended entry in `status_history`.

---

### 9.5 Customer Service Visits & Live Tracking

Allows customers to inspect their service history and follow current visit progress in real time.

#### 9.5.1 List Own Service Visits
* **URL:** `GET /api/customer/visits/` (or `GET /api/customer/visits`)
* **Access:** **Customer only** (`IsCustomerRole`)
* **Headers:** `Authorization: Bearer <customer_access_token>`
* **Query Parameters:**
  * `vehicle_id` *(integer, optional)*: Filter visits to only those matching the specified vehicle ID. (Also accepts alias `vehicle`).
* **Scope:** Returns only visits where `customer = request.user`. If `vehicle_id` belongs to another customer, an empty array `[]` is returned. If `vehicle_id` is not a valid integer, returns `HTTP 400 Bad Request`.
* **Success Response (`HTTP 200 OK`):**
  ```json
  [
    {
      "id": 12,
      "visit_number": "SV-3B9F2A10",
      "vehicle_details": {
        "id": 4,
        "plate_number": "1234-AD",
        "make": "Toyota",
        "model": "Land Cruiser",
        "year": 2023,
        "color": "White"
      },
      "branch_details": {
        "id": 1,
        "name": "Al Sewar Muscat Main Branch",
        "city": "Muscat",
        "phone": "+96824123456"
      },
      "current_stage": {
        "name": "In Progress",
        "description": "Work is actively being performed",
        "is_terminal": false
      },
      "services": [
        {
          "id": 1,
          "name": "Oil & Filter Change",
          "description": "Full synthetic oil and OEM filter replacement"
        }
      ],
      "status_history": [
        {
          "id": 2,
          "stage_name": "In Progress",
          "stage_description": "Work is actively being performed",
          "notes": "Vehicle moved into repair bay 2; oil drained and filter replaced",
          "created_at": "2026-10-10T16:45:00Z"
        },
        {
          "id": 1,
          "stage_name": "Received",
          "stage_description": "Vehicle received at service centre",
          "notes": "Initial check-in",
          "created_at": "2026-10-10T16:30:00Z"
        }
      ],
      "created_at": "2026-10-10T16:30:00Z",
      "updated_at": "2026-10-10T16:45:00Z"
    }
  ]
  ```

#### 9.5.2 Get Own Visit Detail
* **URL:** `GET /api/customer/visits/{id}/`
* **Access:** **Customer only** (`IsCustomerRole`)
* **Security & Isolation:** Accessing another customer's visit returns `HTTP 404 Not Found`.

---

## 10. Customer Reviews & Admin Moderation Module API Reference

### 10.1 Overview & Operational Architecture

The **Customer Reviews & Admin Moderation** module allows verified customers to submit a rating (1 to 5) and optional written feedback for their completed service visits. Branch managers have read-only access to reviews for their assigned branch, and administrators have full visibility, search/filtering, and moderation capabilities.

#### Key Eligibility & Security Rules:
1. **Completed Service Visit Only:**
   - A review can only be submitted for a service visit that has reached a configured terminal/completion stage (`current_stage.is_terminal == true`).
   - If a customer attempts to review an in-progress or non-terminal visit, the request is rejected with `HTTP 400 Bad Request`.
2. **Strict Ownership Isolation:**
   - Customers can only review visits belonging to their own authenticated customer account.
   - Passing an ID of another customer's visit returns `HTTP 404 Not Found`, preventing visit enumeration and data leakage.
3. **Duplicate Prevention Policy:**
   - Each service visit can have at most **one** review (`OneToOne` database constraint).
   - Subsequent review attempts for the same visit return `HTTP 400 Bad Request` with `"A review for this service visit has already been submitted."`
4. **Manager Branch Scoping:**
   - Branch managers have strictly **read-only** access scoped only to reviews matching their assigned branch (`branch = manager.assigned_branch`).
   - Attempting to access a review from another branch returns `HTTP 404 Not Found`.
5. **Admin Moderation & Lifecycle:**
   - Administrators can view all reviews across branches, filter by approval status, rating, branch, or customer, update moderation status (`is_approved`) and internal notes (`moderation_notes`), or delete spam/inappropriate reviews.

---

### 10.2 Customer Review Endpoints

All customer endpoints require authentication with role `CUSTOMER`:  
`Authorization: Bearer <customer_access_token>`

#### 10.2.1 Submit Review for Completed Visit
* **URL:** `POST /api/customer/reviews/` (or `POST /api/customer/reviews`)
* **Access:** **Customer only** (`IsCustomerRole`)
* **Headers:** `Authorization: Bearer <customer_access_token>`, `Content-Type: application/json`
* **Request Body:**
  ```json
  {
    "visit_id": 1,
    "rating": 5,
    "comment": "Outstanding service! Vehicle returned spotless and on time."
  }
  ```
  | Field | Type | Required | Description |
  |---|---|---|---|
  | `visit_id` | `integer` | **Yes** | ID of the customer's completed service visit. |
  | `rating` | `integer` | **Yes** | Rating score from `1` to `5`. |
  | `comment` | `string` | No | Optional written feedback (also accepts alias `feedback`). |

* **Success Response (`HTTP 201 Created`):**
  ```json
  {
    "id": 1,
    "visit_id": 1,
    "visit_details": {
      "id": 1,
      "visit_number": "SV-A1B2C3D4",
      "stage_name": "Delivered & Completed",
      "vehicle": {
        "id": 3,
        "plate_number": "1234-AA",
        "make": "Toyota",
        "model": "Land Cruiser"
      }
    },
    "branch_details": {
      "id": 1,
      "name": "Muscat Main Branch",
      "city": "Muscat",
      "phone": "+968 2400 0001"
    },
    "rating": 5,
    "comment": "Outstanding service! Vehicle returned spotless and on time.",
    "is_approved": true,
    "created_at": "2026-10-11T16:00:00Z",
    "updated_at": "2026-10-11T16:00:00Z"
  }
  ```

* **Error Responses:**
  * `400 Bad Request` (Rating out of range):
    ```json
    {
      "rating": ["Rating must be an integer between 1 and 5."]
    }
    ```
  * `400 Bad Request` (Visit not completed):
    ```json
    {
      "detail": "Service visit SV-A1B2C3D4 is currently at 'In Progress' stage and has not reached completed status. Reviews can only be submitted for completed visits."
    }
    ```
  * `400 Bad Request` (Duplicate submission):
    ```json
    {
      "detail": "A review for this service visit has already been submitted."
    }
    ```
  * `404 Not Found` (Visit does not belong to customer or invalid ID):
    ```json
    {
      "detail": "Service visit not found or does not belong to your account."
    }
    ```

#### 10.2.2 List My Reviews
* **URL:** `GET /api/customer/reviews/` (or `GET /api/customer/reviews`)
* **Access:** **Customer only** (`IsCustomerRole`)
* **Success Response (`HTTP 200 OK`):** Returns an array of review objects submitted by the authenticated customer.

#### 10.2.3 Get Own Review Detail
* **URL:** `GET /api/customer/reviews/{id}/`
* **Access:** **Customer only** (`IsCustomerRole`)
* **Success Response (`HTTP 200 OK`):** Returns review object if owned by the authenticated customer.
* **Error (`HTTP 404 Not Found`):** If ID does not exist or belongs to another customer.

---

### 10.3 Manager Branch Reviews Endpoints

All manager endpoints require authentication with role `MANAGER`:  
`Authorization: Bearer <manager_access_token>`

#### 10.3.1 List Branch Reviews
* **URL:** `GET /api/manager/reviews/` (or `GET /api/manager/reviews`)
* **Access:** **Manager only** (`IsManagerRole`)
* **Query Parameters:**
  * `rating` *(optional)*: Filter by rating (`1` to `5`).
  * `search` *(optional)*: Search customer username, phone, full name, visit number, plate number, or review comment text.
* **Success Response (`HTTP 200 OK`):**
  ```json
  [
    {
      "id": 1,
      "visit": {
        "id": 1,
        "visit_number": "SV-A1B2C3D4",
        "stage_name": "Delivered & Completed"
      },
      "customer": {
        "id": 5,
        "username": "customer_one",
        "phone": "96891111111",
        "name": "Ahmed Al-Balushi"
      },
      "vehicle": {
        "id": 3,
        "plate_number": "1234-AA",
        "make": "Toyota",
        "model": "Land Cruiser",
        "year": 2023
      },
      "rating": 5,
      "comment": "Outstanding service! Vehicle returned spotless and on time.",
      "is_approved": true,
      "created_at": "2026-10-11T16:00:00Z"
    }
  ]
  ```

#### 10.3.2 Get Branch Review Detail
* **URL:** `GET /api/manager/reviews/{id}/`
* **Access:** **Manager only** (`IsManagerRole`)
* **Branch Isolation:** Accessing a review belonging to a different branch returns `HTTP 404 Not Found`.

---

### 10.4 Admin Review Oversight & Moderation Endpoints

All Admin endpoints require authentication with role `ADMIN`:  
`Authorization: Bearer <admin_access_token>`

#### 10.4.1 List All Customer Reviews
* **URL:** `GET /api/admin/reviews/` (or `GET /api/admin/reviews`)
* **Access:** **Admin only** (`IsAdminRole`)
* **Query Parameters:**
  * `branch` / `branch_id` *(optional)*: Filter by branch ID.
  * `customer` / `customer_id` *(optional)*: Filter by customer ID.
  * `rating` *(optional)*: Filter by rating score (`1` to `5`).
  * `is_approved` *(optional)*: Filter by approval status (`true`/`false` or `1`/`0`).
  * `search` *(optional)*: Search by customer username, phone, name, visit number, branch name, or comment text.
* **Success Response (`HTTP 200 OK`):**
  ```json
  [
    {
      "id": 1,
      "visit": {
        "id": 1,
        "visit_number": "SV-A1B2C3D4",
        "stage_name": "Delivered & Completed",
        "created_at": "2026-10-10T16:00:00Z"
      },
      "customer": {
        "id": 5,
        "username": "customer_one",
        "phone": "96891111111",
        "first_name": "Ahmed",
        "last_name": "Al-Balushi",
        "full_name": "Ahmed Al-Balushi"
      },
      "branch": {
        "id": 1,
        "name": "Muscat Main Branch",
        "code": "MCT-01",
        "city": "Muscat"
      },
      "vehicle": {
        "id": 3,
        "plate_number": "1234-AA",
        "make": "Toyota",
        "model": "Land Cruiser",
        "year": 2023
      },
      "rating": 5,
      "comment": "Outstanding service! Vehicle returned spotless and on time.",
      "is_approved": true,
      "moderation_notes": "",
      "created_at": "2026-10-11T16:00:00Z",
      "updated_at": "2026-10-11T16:00:00Z"
    }
  ]
  ```

#### 10.4.2 Get Review Detail
* **URL:** `GET /api/admin/reviews/{id}/`
* **Access:** **Admin only** (`IsAdminRole`)

#### 10.4.3 Moderate Review (Update Approval Status / Notes)
* **URL:** `PATCH /api/admin/reviews/{id}/` (or `PUT /api/admin/reviews/{id}/`)
* **Access:** **Admin only** (`IsAdminRole`)
* **Headers:** `Content-Type: application/json`
* **Request Body:**
  ```json
  {
    "is_approved": false,
    "moderation_notes": "Hidden pending internal investigation of customer complaint."
  }
  ```
  | Field | Type | Required | Description |
  |---|---|---|---|
  | `is_approved` | `boolean` | No | Set to `false` to hide/unapprove, `true` to approve/publish. |
  | `moderation_notes` | `string` | No | Internal audit/moderation notes by administrator. |
* **Success Response (`HTTP 200 OK`):** Returns updated review object.

#### 10.4.4 Delete Inappropriate Review
* **URL:** `DELETE /api/admin/reviews/{id}/`
* **Access:** **Admin only** (`IsAdminRole`)
* **Success Response (`HTTP 200 OK`):**
  ```json
  {
    "detail": "Review deleted successfully."
  }
  ```

---

## 11. Admin Dashboard & Basic Reports Module API Reference

### 11.1 Overview & Security Architecture

The **Admin Dashboard & Basic Reports** module provides real-time, consolidated business intelligence and operational reporting for administrators. All metrics are computed dynamically using efficient database aggregation across existing tables (`branches`, `accounts`, `customers`, `visits`, and `reviews`).

#### Key Architectural Guarantees:
1. **Strict Admin-Only Authorization:**
   - All endpoints require role `ADMIN` (`IsAdminRole`). Unauthenticated requests receive `401 Unauthorized`.
   - Managers and Customers attempting to access dashboard or report endpoints are strictly rejected with `403 Forbidden` (`{"detail": "Admin access required."}`).
   - Branch managers cannot gain cross-branch access through these endpoints.
2. **Dynamic Configurable Stage Grouping:**
   - Visits are grouped and reported by actual database stages (`ServiceStatusStage`) rather than hardcoded stage names.
   - Stages with `count: 0` are explicitly reported to give full visibility of workflow velocity.
3. **Optional Filtering:**
   - Optional `branch` / `branch_id`: Filters metrics to a specific branch location.
   - Optional `start_date` / `end_date` (format: `YYYY-MM-DD`): Filters visits and reviews within a date range.
4. **Deferred Integrations Safeguard:**
   - No invoice, revenue, payment, loyalty points, or redemption metrics are included or mocked, adhering strictly to the client policy of postponing financial/Odoo modules.
5. **Zero Additional Migrations:**
   - The reporting module introduces no database models; all figures are live aggregations.

---

### 11.2 Admin Dashboard Summary

* **URL:** `GET /api/admin/dashboard/` (or `GET /api/admin/dashboard`)
* **Access:** **Admin only** (`IsAdminRole`)
* **Headers:** `Authorization: Bearer <admin_access_token>`
* **Query Parameters:**
  * `branch` / `branch_id` *(optional, integer)*: Filter to a specific branch.
  * `start_date` / `from_date` *(optional, YYYY-MM-DD)*: Start date for visit and review metrics.
  * `end_date` / `to_date` *(optional, YYYY-MM-DD)*: End date for visit and review metrics.

* **Success Response (`HTTP 200 OK`):**
  ```json
  {
    "branches": {
      "total": 3,
      "active": 2,
      "inactive": 1
    },
    "users": {
      "total_managers": 2,
      "total_customers": 10,
      "active_customers": 10,
      "branch_assigned_managers": null,
      "branch_registered_customers": null
    },
    "vehicles": {
      "total_registered": 8
    },
    "service_visits": {
      "total": 12,
      "completed": 5,
      "in_progress": 7,
      "by_stage": [
        {
          "stage_id": 1,
          "stage_name": "Received",
          "stage_code": "RECEIVED",
          "order": 1,
          "is_terminal": false,
          "count": 3
        },
        {
          "stage_id": 2,
          "stage_name": "In Progress",
          "stage_code": "IN_PROGRESS",
          "order": 2,
          "is_terminal": false,
          "count": 4
        },
        {
          "stage_id": 3,
          "stage_name": "Delivered & Completed",
          "stage_code": "DELIVERED_COMPLETED",
          "order": 3,
          "is_terminal": true,
          "count": 5
        }
      ]
    },
    "recent_visits": [
      {
        "id": 12,
        "visit_number": "SV-A1B2C3D4",
        "customer": {
          "id": 5,
          "username": "customer_one",
          "phone": "96891111111",
          "name": "Ahmed Al-Balushi"
        },
        "vehicle": {
          "id": 2,
          "plate_number": "1234-AA",
          "make": "Toyota",
          "model": "Land Cruiser"
        },
        "branch": {
          "id": 1,
          "name": "Muscat Main Branch",
          "code": "MCT-01"
        },
        "stage": {
          "id": 3,
          "name": "Delivered & Completed",
          "code": "DELIVERED_COMPLETED",
          "is_terminal": true
        },
        "created_at": "2026-10-11T16:00:00Z"
      }
    ],
    "reviews": {
      "total_reviews": 6,
      "average_rating": 4.67,
      "approved_count": 5,
      "unapproved_count": 1,
      "rating_breakdown": {
        "5": 4,
        "4": 1,
        "3": 0,
        "2": 1,
        "1": 0
      }
    },
    "filters_applied": {
      "branch_id": null,
      "branch_name": null,
      "start_date": null,
      "end_date": null
    }
  }
  ```

* **Error Responses:**
  * `400 Bad Request` (Invalid date format):
    ```json
    {
      "detail": "Invalid format for 'start_date'. Expected format is YYYY-MM-DD."
    }
    ```
  * `400 Bad Request` (Date order reversed):
    ```json
    {
      "detail": "start_date cannot be later than end_date."
    }
    ```
  * `404 Not Found` (Invalid branch ID):
    ```json
    {
      "detail": "No Branch matches the given query."
    }
    ```
  * `401 Unauthorized` / `403 Forbidden`: Token invalid, missing, or caller is not an Admin.

---

### 11.3 Admin Reports Overview

* **URL:** `GET /api/admin/reports/` (or `GET /api/admin/reports`)
* **Access:** **Admin only** (`IsAdminRole`)
* **Success Response (`HTTP 200 OK`):**
  ```json
  {
    "report_modules": {
      "dashboard_summary": "/api/admin/dashboard/",
      "visits_report": "/api/admin/reports/visits/",
      "reviews_report": "/api/admin/reports/reviews/"
    },
    "kpis": {
      "total_branches": 3,
      "total_registered_vehicles": 8,
      "total_service_visits": 12,
      "completed_service_visits": 5,
      "total_customer_reviews": 6,
      "customer_satisfaction_rating": 4.67
    },
    "filters_applied": {
      "branch_id": null,
      "branch_name": null,
      "start_date": null,
      "end_date": null
    }
  }
  ```

---

### 11.4 Admin Service Visits Report

* **URL:** `GET /api/admin/reports/visits/` (or `GET /api/admin/reports/visits`)
* **Access:** **Admin only** (`IsAdminRole`)
* **Query Parameters:**
  * `branch` / `branch_id` *(optional, integer)*: Filter by branch.
  * `start_date` / `end_date` *(optional, YYYY-MM-DD)*: Filter by date range.
* **Success Response (`HTTP 200 OK`):**
  ```json
  {
    "summary": {
      "total_visits": 12,
      "completed_visits": 5,
      "active_visits": 7,
      "completion_rate_percentage": 41.67
    },
    "by_stage": [
      {
        "stage_id": 1,
        "stage_name": "Received",
        "stage_code": "RECEIVED",
        "order": 1,
        "is_terminal": false,
        "count": 3,
        "percentage": 25.0
      },
      {
        "stage_id": 2,
        "stage_name": "In Progress",
        "stage_code": "IN_PROGRESS",
        "order": 2,
        "is_terminal": false,
        "count": 4,
        "percentage": 33.33
      },
      {
        "stage_id": 3,
        "stage_name": "Delivered & Completed",
        "stage_code": "DELIVERED_COMPLETED",
        "order": 3,
        "is_terminal": true,
        "count": 5,
        "percentage": 41.67
      }
    ],
    "by_branch": [
      {
        "branch_id": 1,
        "branch_name": "Muscat Main Branch",
        "branch_code": "MCT-01",
        "total_visits": 8,
        "completed_visits": 4,
        "active_visits": 4
      },
      {
        "branch_id": 2,
        "branch_name": "Salalah Branch",
        "branch_code": "SLL-01",
        "total_visits": 4,
        "completed_visits": 1,
        "active_visits": 3
      }
    ],
    "filters_applied": {
      "branch_id": null,
      "branch_name": null,
      "start_date": null,
      "end_date": null
    }
  }
  ```

---

### 11.5 Admin Customer Reviews Report

* **URL:** `GET /api/admin/reports/reviews/` (or `GET /api/admin/reports/reviews`)
* **Access:** **Admin only** (`IsAdminRole`)
* **Query Parameters:**
  * `branch` / `branch_id` *(optional, integer)*: Filter by branch.
  * `start_date` / `end_date` *(optional, YYYY-MM-DD)*: Filter by date range.
* **Success Response (`HTTP 200 OK`):**
  ```json
  {
    "summary": {
      "total_reviews": 6,
      "average_rating": 4.67,
      "approved_count": 5,
      "unapproved_count": 1
    },
    "rating_breakdown": {
      "5": { "count": 4, "percentage": 66.67 },
      "4": { "count": 1, "percentage": 16.67 },
      "3": { "count": 0, "percentage": 0.0 },
      "2": { "count": 1, "percentage": 16.67 },
      "1": { "count": 0, "percentage": 0.0 }
    },
    "by_branch": [
      {
        "branch_id": 1,
        "branch_name": "Muscat Main Branch",
        "branch_code": "MCT-01",
        "total_reviews": 4,
        "average_rating": 4.75,
        "approved_count": 4,
        "unapproved_count": 0
      },
      {
        "branch_id": 2,
        "branch_name": "Salalah Branch",
        "branch_code": "SLL-01",
        "total_reviews": 2,
        "average_rating": 4.5,
        "approved_count": 1,
        "unapproved_count": 1
      }
    ],
    "filters_applied": {
      "branch_id": null,
      "branch_name": null,
      "start_date": null,
      "end_date": null
    }
  }
  ```

---

## 12. Notifications & Device Tokens Module API Reference

### 12.1 Overview & Push Architecture
The **Notifications & Device Tokens** module provides push device registration, token lifecycle management, in-app notification feeds, and background dispatch adapters for operational events.

* **Token Ownership Tied to `request.user`:** Authenticated users register, list, deactivate, or delete only their own tokens. Cross-user access returns `404 Not Found`.
* **Multi-Device & Deduplication:** Supports multiple active devices per user. Re-registering the same token updates metadata and reactivates it without creating duplicate records. Handing over a device to a new user cleanly reassigns ownership.
* **Provider Simulation Fallback:** Safe simulation adapter runs when FCM credentials (`FCM_SERVER_KEY` or `FIREBASE_CREDENTIALS_PATH`) are unconfigured. No crashes or synthetic delivery claims.
* **Safe Visit Update Integration:** Status updates commit first in an atomic transaction; push dispatch executes outside the transaction in a guarded try/except block.

### 12.2 Customer Device Endpoints (`/api/customer/devices/`)
* `POST /api/customer/devices/`: Register/upsert device token (`token`, `platform: ANDROID|IOS|WEB`, `device_name`). Returns `201 Created` or `200 OK`.
* `GET /api/customer/devices/`: List customer's registered devices. Returns `200 OK`.
* `GET /api/customer/devices/{id}/`: Get device token detail. Returns `200 OK`.
* `PATCH /api/customer/devices/{id}/`: Update token (`is_active: false`, `device_name`). Returns `200 OK`.
* `DELETE /api/customer/devices/{id}/`: Remove token record. Returns `200 OK` (`{"detail": "..."}`).
* `POST /api/customer/devices/deactivate/`: Deactivate token by token string on logout (`{"token": "..."}`). Returns `200 OK`.

### 12.3 Customer In-App Notifications (`/api/customer/notifications/`)
* `GET /api/customer/notifications/`: Fetch customer's in-app notification feed. Optional query params: `is_read=true|false`, `type=SERVICE_STATUS_UPDATE|LOYALTY_CREDIT|GENERAL`.
* `PATCH /api/customer/notifications/{id}/read/`: Mark in-app notification as read. Returns `200 OK`.

### 12.4 Manager Device & Notification Endpoints (`/api/manager/`)
* `POST /api/manager/devices/`, `GET /api/manager/devices/`, `PATCH /api/manager/devices/{id}/`, `DELETE /api/manager/devices/{id}/`, `POST /api/manager/devices/deactivate/`: Manager device token management.
* `GET /api/manager/notifications/`: View manager notification inbox.
* `PATCH /api/manager/notifications/{id}/read/`: Mark manager notification as read.

### 12.5 Unified Authenticated Endpoints (`/api/notifications/`)
Generic routes available to any authenticated user:
* `GET /api/notifications/devices/` & `POST /api/notifications/devices/`: List and register device tokens.
* `POST /api/notifications/devices/deactivate/`: Deactivate token string.
* `GET /api/notifications/` & `PATCH /api/notifications/{id}/read/`: In-app notification inbox and mark-as-read.

### 12.6 Admin Device & Dispatch Oversight (`/api/admin/`)
* `GET /api/admin/devices/`: List all device tokens across the platform. Query filters: `platform`, `is_active`, `user_id`, `search`.
* `GET /api/admin/devices/{id}/`: View device token details.
* `GET /api/admin/notifications/`: List notification dispatch logs across the platform. Query filters: `status=SENT|FAILED|PENDING`, `type`, `user_id`, `search`.

---

## 13. Banner Management Module API Reference

### 13.1 Overview & Multi-App Distribution
The Banner Management module enables the Administrator to manage promotional and operational banners displayed in the Customer and Manager Mobile Apps.

#### Target App Matrix:
* `CUSTOMER`: Visible only to authenticated customers via `/api/customer/banners/`.
* `MANAGER`: Visible only to authenticated branch managers via `/api/manager/banners/`.
* `BOTH`: Broadcast to both customer and manager feeds.

#### Ordering & Soft Deactivation:
* Banners sort by `display_order ASC`, then by `created_at DESC` (lower numbers appear first).
* Inactive banners (`is_active = false`) are automatically hidden from mobile feeds.
* `DELETE /api/admin/banners/{id}/` performs safe soft deactivation by setting `is_active = false`. Records and image files are retained.
* Banners can be reactivated anytime via `PATCH /api/admin/banners/{id}/` with `{"is_active": true}`.

---

### 13.2 Admin Banner Management (`/api/admin/banners/`)
* **Access:** `IsAuthenticated` + `IsAdminRole`

#### Endpoints:
* `GET /api/admin/banners/`: List all banners. Query filters: `search`, `target_app`, `is_active`.
* `POST /api/admin/banners/`: Create banner (`multipart/form-data`). Fields: `title` (required), `image` (required file, max 2 MB), `target_app` (`CUSTOMER`|`MANAGER`|`BOTH`, default `BOTH`), `display_order` (default 0), `is_active` (default true).
* `GET /api/admin/banners/{id}/`: Retrieve single banner detail.
* `PATCH /api/admin/banners/{id}/`: Partial update metadata (JSON) or replace image file (`multipart/form-data`). Automatically deletes old image from storage upon successful replacement.
* `DELETE /api/admin/banners/{id}/`: Soft-deactivate banner (`is_active=False`).

---

### 13.3 Customer Promotional Banners (`/api/customer/banners/`)
* **URL:** `GET /api/customer/banners/` (and `/api/customer/banners`)
* **Access:** `IsAuthenticated` + `IsCustomerRole`
* **Filter:** `is_active=True` AND `target_app__in=['CUSTOMER', 'BOTH']`
* **Ordering:** `display_order ASC`, `-created_at DESC`
* **Success Response (`HTTP 200 OK`):**
  ```json
  [
    {
      "id": 1,
      "title": "Summer AC Inspection Special",
      "image": "http://192.168.1.2:8001/media/banners/7c2a1e8418454291a1d2088a29a00b12.jpg",
      "target_app": "CUSTOMER",
      "display_order": 1
    }
  ]
  ```

---

### 13.4 Manager Announcements & Banners (`/api/manager/banners/`)
* **URL:** `GET /api/manager/banners/` (and `/api/manager/banners`)
* **Access:** `IsAuthenticated` + `IsManagerRole`
* **Filter:** `is_active=True` AND `target_app__in=['MANAGER', 'BOTH']`
* **Ordering:** `display_order ASC`, `-created_at DESC`
* **Success Response (`HTTP 200 OK`):**
  ```json
  [
    {
      "id": 3,
      "title": "Manager Safety Protocol 2026",
      "image": "http://192.168.1.2:8001/media/banners/3a1c9e886124411085f2192a01d00e99.png",
      "target_app": "MANAGER",
      "display_order": 1
    }
  ]
  ```

---

## 14. Database Migrations & Test Verification

### 14.1 Database Migration Status

* **`branches.0001_initial`**: Applied (`[X]`).
* **`branches.0002_managerprofile`**: Applied (`[X]`).
* **`customers.0001_initial`**: Applied (`[X]`).
* **`customers.0002_vehicle_is_active`**: Applied (`[X]`).
* **`customers.0003_customerprofile_profile_picture`**: Applied (`[X]`).
* **`banners.0001_initial`**: Applied (`[X]`).
* **`services.0001_initial`**: Applied (`[X]`).
* **`visits.0001_initial`**: Applied (`[X]`).
* **`reviews.0001_initial`**: Generated (`[ ]` unapplied on development database).
* **`notifications.0001_initial`**: Generated (`[ ]` unapplied on development database).

### 14.2 Verified Test Suite Execution

All test suites were executed directly against the test runner with zero failures:

| Test Scope | Command | Tests Run | Result | Notes |
|---|---|---|---|---|
| **Banners App** | `python manage.py test app.banners` | **17** | **OK (Passed)** | Banner upload, listing, filtering, search, JSON update, image replacement, old file cleanup, soft deactivation, reactivation, customer filtering, manager filtering, display ordering, format/size validation, and RBAC isolation. |
| **Notifications App** | `python manage.py test app.notifications` | **25** | **OK (Passed)** | Token registration, multi-device support, re-registration/deduplication, cross-user transfer, platform validation, deactivation via PATCH and string, deletion, cross-user isolation, in-app notification inbox, mark-as-read, admin oversight, provider simulation, and visit status update safe failure isolation. |
| **Reports App** | `python manage.py test app.reports` | **17** | **OK (Passed)** | Admin dashboard summary, configurable status stages grouping, safe zero-state handling, branch filtering, date range filtering, invalid date handling, visits report, reviews report, reports overview, and RBAC rejection of Manager & Customer roles. |
| **Reviews App** | `python manage.py test app.reviews` | **28** | **OK (Passed)** | 1-5 rating validation, optional feedback, completed terminal stage eligibility, cross-customer isolation, duplicate review rejection, manager branch isolation & read-only access, admin listing/filters/search, admin moderation PATCH, admin DELETE, and RBAC security. |
| **Visits App** | `python manage.py test app.visits` | **24** | **OK (Passed)** | Stage CRUD, duplicate prevention, visit creation, vehicle mismatch rejection, branch service check, unassigned manager check, cross-branch isolation, status updates, audit logs, and customer isolation. |
| **Services App** | `python manage.py test app.services` | **34** | **OK (Passed)** | Admin catalogue CRUD, duplicate prevention, branch assignments, manager scoping & isolation, customer browsing, and RBAC permissions. |
| **Customers App** | `python manage.py test app.customers` | **62** | **OK (Passed)** | Walk-in customer registration, vehicle registration, duplicate plate prevention, customer self-service isolation, customer profile editing, JPEG/PNG/WEBP upload, 2MB limit, old picture deletion, customer/manager safe soft deletion, and 401/403/404 handling. |
| **Managers App** | `python manage.py test app.managers` | **8** | **OK (Passed)** | Assigned manager, unassigned manager, trailing slash variants, RBAC permissions, and isolation tests. |
| **Branches App** | `python manage.py test app.branches` | **41** | **OK (Passed)** | Branch CRUD, business hours, and manager assignment tests. |
| **Accounts App** | `python manage.py test app.accounts` | **33** | **OK (Passed)** | Login, signup, token refresh, CustomerMe profile picture, and manager CRUD tests. |

---

## 15. Frontend Integration Guide (Axios Example)

Here is a ready-to-use Axios configuration for your frontend application:

```javascript
// src/api/axiosClient.js
import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000';

const axiosClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Auto-attach JWT Access Token
axiosClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Auto-refresh token on 401
axiosClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      const refreshToken = localStorage.getItem('refresh_token');
      if (refreshToken) {
        try {
          const res = await axios.post(`${API_BASE_URL}/api/auth/token/refresh/`, {
            refresh: refreshToken,
          });
          localStorage.setItem('access_token', res.data.access);
          if (res.data.refresh) {
            localStorage.setItem('refresh_token', res.data.refresh);
          }
          originalRequest.headers.Authorization = `Bearer ${res.data.access}`;
          return axiosClient(originalRequest);
        } catch (refreshErr) {
          localStorage.removeItem('access_token');
          localStorage.removeItem('refresh_token');
          window.location.href = '/login';
        }
      }
    }
    return Promise.reject(error);
  }
);

export default axiosClient;
```

### Example Usage Functions:

```javascript
// src/api/authService.js
import axiosClient from './axiosClient';

export const authService = {
  // Customer Self Signup
  customerSignup: async (data) => {
    const res = await axiosClient.post('/api/customer/signup/', data);
    return res.data;
  },

  // Manager creates customer
  managerCreateCustomer: async (data) => {
    const res = await axiosClient.post('/api/manager/customers/', data);
    return res.data;
  },

  // Admin Manager Management
  getManagers: async () => {
    const res = await axiosClient.get('/api/admin/managers/');
    return res.data;
  },

  createManager: async (data) => {
    const res = await axiosClient.post('/api/admin/managers/', data);
    return res.data;
  },

  updateManager: async (id, data) => {
    const res = await axiosClient.patch(`/api/admin/managers/${id}/`, data);
    return res.data;
  },

  deactivateManager: async (id) => {
    const res = await axiosClient.delete(`/api/admin/managers/${id}/`);
    return res.data;
  },

  // General / Role Login
  login: async (credentials) => {
    const res = await axiosClient.post('/api/auth/login/', credentials);
    return res.data;
  },

  // Fetch Current User
  getMe: async () => {
    const res = await axiosClient.get('/api/auth/me/');
    return res.data;
  },

  // Customer & Vehicle Management (Manager Portal)
  managerSearchCustomers: async (params) => {
    const res = await axiosClient.get('/api/manager/customers/', { params });
    return res.data;
  },

  managerGetCustomerDetail: async (id) => {
    const res = await axiosClient.get(`/api/manager/customers/${id}/`);
    return res.data;
  },

  managerGetVehicles: async (params) => {
    const res = await axiosClient.get('/api/manager/vehicles/', { params });
    return res.data;
  },

  managerCreateVehicle: async (data) => {
    const res = await axiosClient.post('/api/manager/vehicles/', data);
    return res.data;
  },

  managerUpdateVehicle: async (id, data) => {
    const res = await axiosClient.patch(`/api/manager/vehicles/${id}/`, data);
    return res.data;
  },

  managerDeleteVehicle: async (id) => {
    const res = await axiosClient.delete(`/api/manager/vehicles/${id}/`);
    return res.data;
  },

  // Customer Self-Service Vehicles (Customer Portal)
  customerGetMyVehicles: async () => {
    const res = await axiosClient.get('/api/customer/vehicles/');
    return res.data;
  },

  customerCreateVehicle: async (data) => {
    const res = await axiosClient.post('/api/customer/vehicles/', data);
    return res.data;
  },

  customerUpdateVehicle: async (id, data) => {
    const res = await axiosClient.patch(`/api/customer/vehicles/${id}/`, data);
    return res.data;
  },

  customerDeleteVehicle: async (id) => {
    const res = await axiosClient.delete(`/api/customer/vehicles/${id}/`);
    return res.data;
  },

  // Service Catalogue & Branch Services (Admin Portal)
  adminGetServices: async (params) => {
    const res = await axiosClient.get('/api/admin/services/', { params });
    return res.data;
  },

  adminCreateService: async (data) => {
    const res = await axiosClient.post('/api/admin/services/', data);
    return res.data;
  },

  adminUpdateService: async (id, data) => {
    const res = await axiosClient.patch(`/api/admin/services/${id}/`, data);
    return res.data;
  },

  adminDeactivateService: async (id) => {
    const res = await axiosClient.delete(`/api/admin/services/${id}/`);
    return res.data;
  },

  adminGetBranchServices: async (params) => {
    const res = await axiosClient.get('/api/admin/branch-services/', { params });
    return res.data;
  },

  adminAssignBranchService: async (data) => {
    const res = await axiosClient.post('/api/admin/branch-services/', data);
    return res.data;
  },

  adminUpdateBranchService: async (id, data) => {
    const res = await axiosClient.patch(`/api/admin/branch-services/${id}/`, data);
    return res.data;
  },

  adminRemoveBranchService: async (id) => {
    const res = await axiosClient.delete(`/api/admin/branch-services/${id}/`);
    return res.data;
  },

  // Branch Services (Manager Portal)
  managerGetBranchServices: async (params) => {
    const res = await axiosClient.get('/api/manager/branch/services/', { params });
    return res.data;
  },

  // Services (Customer Portal)
  customerGetServices: async (params) => {
    const res = await axiosClient.get('/api/customer/services/', { params });
    return res.data;
  },

  customerGetBranchServices: async (branchId) => {
    const res = await axiosClient.get(`/api/customer/branches/${branchId}/services/`);
    return res.data;
  },

  // Service Visits & Workflow (Admin Portal)
  adminGetStages: async (params) => {
    const res = await axiosClient.get('/api/admin/stages/', { params });
    return res.data;
  },

  adminCreateStage: async (data) => {
    const res = await axiosClient.post('/api/admin/stages/', data);
    return res.data;
  },

  adminUpdateStage: async (id, data) => {
    const res = await axiosClient.patch(`/api/admin/stages/${id}/`, data);
    return res.data;
  },

  adminDeleteStage: async (id) => {
    const res = await axiosClient.delete(`/api/admin/stages/${id}/`);
    return res.data;
  },

  adminGetVisits: async (params) => {
    const res = await axiosClient.get('/api/admin/visits/', { params });
    return res.data;
  },

  adminGetVisitDetail: async (id) => {
    const res = await axiosClient.get(`/api/admin/visits/${id}/`);
    return res.data;
  },

  // Service Visits & Workflow (Manager Portal)
  managerGetVisits: async (params) => {
    const res = await axiosClient.get('/api/manager/visits/', { params });
    return res.data;
  },

  managerCreateVisit: async (data) => {
    const res = await axiosClient.post('/api/manager/visits/', data);
    return res.data;
  },

  managerGetVisitDetail: async (id) => {
    const res = await axiosClient.get(`/api/manager/visits/${id}/`);
    return res.data;
  },

  managerUpdateVisitStatus: async (id, data) => {
    const res = await axiosClient.post(`/api/manager/visits/${id}/update-status/`, data);
    return res.data;
  },

  // Service Visits & Live Tracking (Customer Portal)
  customerGetVisits: async () => {
    const res = await axiosClient.get('/api/customer/visits/');
    return res.data;
  },

  customerGetVisitDetail: async (id) => {
    const res = await axiosClient.get(`/api/customer/visits/${id}/`);
    return res.data;
  },

  // Customer Reviews & Moderation (Customer Portal)
  customerSubmitReview: async (data) => {
    const res = await axiosClient.post('/api/customer/reviews/', data);
    return res.data;
  },

  customerGetReviews: async () => {
    const res = await axiosClient.get('/api/customer/reviews/');
    return res.data;
  },

  customerGetReviewDetail: async (id) => {
    const res = await axiosClient.get(`/api/customer/reviews/${id}/`);
    return res.data;
  },

  // Customer Reviews (Manager Portal - Scoped to Assigned Branch)
  managerGetReviews: async (params) => {
    const res = await axiosClient.get('/api/manager/reviews/', { params });
    return res.data;
  },

  managerGetReviewDetail: async (id) => {
    const res = await axiosClient.get(`/api/manager/reviews/${id}/`);
    return res.data;
  },

  // Customer Reviews & Moderation (Admin Portal)
  adminGetReviews: async (params) => {
    const res = await axiosClient.get('/api/admin/reviews/', { params });
    return res.data;
  },

  adminGetReviewDetail: async (id) => {
    const res = await axiosClient.get(`/api/admin/reviews/${id}/`);
    return res.data;
  },

  adminModerateReview: async (id, data) => {
    const res = await axiosClient.patch(`/api/admin/reviews/${id}/`, data);
    return res.data;
  },

  adminDeleteReview: async (id) => {
    const res = await axiosClient.delete(`/api/admin/reviews/${id}/`);
    return res.data;
  },

  // Admin Dashboard & Reports (Admin Portal)
  adminGetDashboardSummary: async (params) => {
    const res = await axiosClient.get('/api/admin/dashboard/', { params });
    return res.data;
  },

  adminGetReportsOverview: async (params) => {
    const res = await axiosClient.get('/api/admin/reports/', { params });
    return res.data;
  },

  adminGetVisitsReport: async (params) => {
    const res = await axiosClient.get('/api/admin/reports/visits/', { params });
    return res.data;
  },

  adminGetReviewsReport: async (params) => {
    const res = await axiosClient.get('/api/admin/reports/reviews/', { params });
    return res.data;
  },

  // Notifications & Device Tokens (Customer App)
  customerRegisterDevice: async (data) => {
    const res = await axiosClient.post('/api/customer/devices/', data);
    return res.data;
  },

  customerGetDevices: async () => {
    const res = await axiosClient.get('/api/customer/devices/');
    return res.data;
  },

  customerDeactivateDevice: async (token) => {
    const res = await axiosClient.post('/api/customer/devices/deactivate/', { token });
    return res.data;
  },

  customerGetNotifications: async (params) => {
    const res = await axiosClient.get('/api/customer/notifications/', { params });
    return res.data;
  },

  customerMarkNotificationRead: async (id) => {
    const res = await axiosClient.patch(`/api/customer/notifications/${id}/read/`);
    return res.data;
  },

  // Notifications & Device Tokens (Manager App)
  managerRegisterDevice: async (data) => {
    const res = await axiosClient.post('/api/manager/devices/', data);
    return res.data;
  },

  managerGetNotifications: async (params) => {
    const res = await axiosClient.get('/api/manager/notifications/', { params });
    return res.data;
  },

  // Notifications & Device Tokens (Admin Portal)
  adminGetDevices: async (params) => {
    const res = await axiosClient.get('/api/admin/devices/', { params });
    return res.data;
  },

  adminGetNotifications: async (params) => {
    const res = await axiosClient.get('/api/admin/notifications/', { params });
    return res.data;
  },

  // Logout
  logout: async () => {
    const refreshToken = localStorage.getItem('refresh_token');
    if (refreshToken) {
      await axiosClient.post('/api/auth/logout/', { refresh: refreshToken });
    }
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
  },
};
```
