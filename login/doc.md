# Login API Specification & Data Models

> **iXPOS Windows Desktop Application** by myResto Today  
> **Endpoint Specification**: `POST /api/v1/auth/login` | **Version**: `v1.0` | **Format**: `JSON`

---

## Table of Contents
- [Overview & Quick Reference](#overview--quick-reference)
- [Core Development Specifications](#core-development-specifications)
- [Key Architectural Refinements](#key-architectural-refinements)
- [Response Payloads](#response-payloads)
  - [1. Successful Login Response (200 OK)](#1-successful-login-response-200-ok)
  - [2. Failed Login Response (401 / 400)](#2-failed-login-response-401--400)
- [Data Models & Field Specifications](#data-models--field-specifications)
  - [Top-Level Response Envelope](#top-level-response-envelope)
  - [Account Model (`account`)](#account-model-account)
  - [Store Model (`stores[]`)](#store-model-stores)
  - [Subscription Active Status Enums (`active_status`)](#subscription-active-status-enums-active_status)
  - [Location Model (`location`)](#location-model-location)
  - [Error Model (`error`)](#error-model-error)

---

## Overview & Quick Reference

| Property | Details |
| :--- | :--- |
| **HTTP Method** | `POST` |
| **Endpoint URL** | `/api/v1/auth/login` |
| **Headers** | `Content-Type: application/json`, `Accept: application/json` |
| **Authentication** | Public (Pre-auth endpoint) |
| **Success Status Code** | `200 OK` |
| **Failure Status Code** | `401 Unauthorized` / `400 Bad Request` |

---

## Core Development Specifications

> [!IMPORTANT]
> ### 1. Strict Envelope Uniformity
> Do **NOT** change the response body structure between successful and failed authentication attempts. The top-level JSON keys (`success`, `message`, `ui_message`, `login_context_and_data`, `redirect_url`, `error`) must remain identical across all status codes.

> [!WARNING]
> ### 2. Handling Failed Logins
> On authentication failure (`success: false`), set `login_context_and_data` strictly to `null`. Detailed diagnostic details must be provided inside the `error` object.

> [!NOTE]
> ### 3. Deterministic Active Status Enum
> `active_status.method` uses a fixed enum: `DATE` or `PURCHASE`. Frontend client applications inspect this field to determine subscription validity and display logic.

---

## Key Architectural Refinements

1. **Disambiguated User vs. Brand Name**:
   - `name`: Designated strictly for the **User's Full Display Name** (e.g., `"Ahinas"`).
   - `brand_name`: Designated for the **Brand Organization Name** (e.g., `"Brand Name"`).

2. **Multi-Store Array (`stores[]`)**:
   - Replaced single `store` object with an array `stores[]` under `login_context_and_data` to support multi-outlet brand accounts.

3. **Structured Store Sub-Objects**:
   - Every store item in `stores[]` embeds 2 dedicated sub-objects: `active_status` (subscription status) and `location` (address details & coordinates).

4. **API-Friendly English `snake_case`**:
   - Removed all non-English / Malayalam key names. Replaced with standardized `snake_case` field names (e.g., `wallet_coin_balance`).

5. **Brand Store Counter (`store_count_under_this_brand`)**:
   - Added integer counter in `account` reporting total registered store outlets managed under the brand entity.

6. **Non-Brand Account Nullability**:
   - When `is_brand` is `false`, brand-specific fields (`brand_name`, `brand_logo_url`) automatically evaluate to `null`.

7. **Conditional Method Payload Fields**:
   - If `active_status.method == "DATE"`, `date` is populated and `purchase` is `null`.
   - If `active_status.method == "PURCHASE"`, `purchase` is populated and `date` is `null`.

8. **Strictly-Typed Numeric Values**:
   - Stored `commission_rate` as a float (`0.11` instead of string `"0.11"`), and `wallet_coin_balance` / `purchase` as native numbers for precision arithmetic in client apps.

---

## Response Payloads

### 1. Successful Login Response (200 OK)

```json
{
  "success": true,
  "message": "Login successful",
  "ui_message": "HI {User Name}, Welcome to iXPOS by myResto Today",
  "login_context_and_data": {
    "account": {
      "id": "user-uuid",
      "user_type": "admin",
      "name": "Ahinas",
      "email": "myrestotoday@gmail.com",
      "mobile": "917867867860",
      "avatar_url": null,
      "role": "ADMIN",
      "is_brand": true,
      "brand_name": "Brand Name",
      "brand_logo_url": "https://example.com/brand-logo.png",
      "store_count_under_this_brand": 3,
      "is_brand_verified": true,
      "is_user_verified": true
    },
    "stores": [
      {
        "id": "store-uuid-001",
        "serial_number": 1,
        "track_id": "MKI0596",
        "store_model": "restaurant",
        "name": "Store Name 1",
        "slug": "store-name-1",
        "logo_url": "https://example.com/store-logo-1.png",
        "avatar_url": "https://example.com/store-avatar-1.png",
        "is_store_verified": true,
        "active_status": {
          "method": "DATE",
          "date": "2028-08-12",
          "purchase": null,
          "wallet_coin_balance": 126,
          "commission_rate": 0.11,
          "exchange_currency": "INR"
        },
        "location": {
          "address_line_1": "Erattupetta",
          "address_line_2": "Erattupetta",
          "city": "Erattupetta",
          "state": "Kerala",
          "country": "India",
          "latitude": 9.687921,
          "longitude": 76.762441,
          "map_url": "https://maps.app.goo.gl/J8G1qG7o2anbeD3n8"
        }
      },
      {
        "id": "store-uuid-002",
        "serial_number": 2,
        "track_id": "MKI0597",
        "store_model": "cafe",
        "name": "Store Name 2",
        "slug": "store-name-2",
        "logo_url": "https://example.com/store-logo-2.png",
        "avatar_url": "https://example.com/store-avatar-2.png",
        "is_store_verified": true,
        "active_status": {
          "method": "PURCHASE",
          "date": null,
          "purchase": 120458,
          "wallet_coin_balance": 126,
          "commission_rate": 0.11,
          "exchange_currency": "INR"
        },
        "location": {
          "address_line_1": "Erattupetta",
          "address_line_2": "Erattupetta",
          "city": "Erattupetta",
          "state": "Kerala",
          "country": "India",
          "latitude": 9.687921,
          "longitude": 76.762441,
          "map_url": "https://maps.app.goo.gl/J8G1qG7o2anbeD3n8"
        }
      },
      {
        "id": "store-uuid-003",
        "serial_number": 3,
        "track_id": "MKI0100",
        "store_model": "restaurant",
        "name": "Store Name 3",
        "slug": "store-name-3",
        "logo_url": "https://example.com/store-logo-3.png",
        "avatar_url": "https://example.com/store-avatar-3.png",
        "is_store_verified": true,
        "active_status": {
          "method": "DATE",
          "date": "2028-08-12",
          "purchase": null,
          "wallet_coin_balance": 126,
          "commission_rate": 0.11,
          "exchange_currency": "INR"
        },
        "location": {
          "address_line_1": "Erattupetta",
          "address_line_2": "Erattupetta",
          "city": "Erattupetta",
          "state": "Kerala",
          "country": "India",
          "latitude": 9.687921,
          "longitude": 76.762441,
          "map_url": "https://maps.app.goo.gl/J8G1qG7o2anbeD3n8"
        }
      }
    ]
  },
  "redirect_url": "/dashboard",
  "error": {
    "code": null,
    "message": null
  }
}
```

### 2. Failed Login Response (401 / 400)

```json
{
  "success": false,
  "message": "Login failed",
  "ui_message": "Invalid mobile number or password",
  "login_context_and_data": null,
  "redirect_url": "/error-page",
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Invalid mobile number or password"
  }
}
```

---

## Data Models & Field Specifications

### Top-Level Response Envelope

| Field Name | Type | Nullable | Description & Frontend Behavior |
| :--- | :--- | :---: | :--- |
| `success` | `boolean` | **No** | Authentication outcome. `true` if authorized; `false` on failure. |
| `message` | `string` | **No** | Internal system/debug message (e.g. `"Login successful"`). |
| `ui_message` | `string` | **No** | User-facing banner notification string to render in client UI. |
| `login_context_and_data` | `object` | **Yes** | Container for user account and stores array. `null` on failure. |
| `redirect_url` | `string` | **No** | Route path for client navigation (`/dashboard` or `/error-page`). |
| `error` | `object` | **No** | Error detail container. Fields evaluate to `null` on success. |

---

### Account Model (`account`)

*Path: `login_context_and_data.account`*

| Field Name | Type | Nullable | Description & Frontend Behavior |
| :--- | :--- | :---: | :--- |
| `id` | `string` | **No** | Unique user UUID. |
| `user_type` | `string` | **No** | User category classification (e.g. `"admin"`, `"cashier"`). |
| `name` | `string` | **No** | User Display Name (e.g. `"Ahinas"`). |
| `email` | `string` | **No** | User email address. |
| `mobile` | `string` | **No** | User mobile phone number with country code. |
| `avatar_url` | `string` | **Yes** | User avatar picture URL (or `null` if unassigned). |
| `role` | `string` | **No** | System permission role (e.g. `"ADMIN"`, `"MANAGER"`). |
| `is_brand` | `boolean` | **No** | Flag indicating if account manages a multi-store brand entity. |
| `brand_name` | `string` | **Yes** | Brand organization name. `null` if `is_brand == false`. |
| `brand_logo_url` | `string` | **Yes** | Brand logo image URL. `null` if `is_brand == false`. |
| `store_count_under_this_brand` | `integer` | **No** | Total registered stores linked under this brand organization. |
| `is_brand_verified` | `boolean` | **No** | Brand verification verification status flag. |
| `is_user_verified` | `boolean` | **No** | User identity verification status flag. |

---

### Store Model (`stores[]`)

*Path: `login_context_and_data.stores[]`*

| Field Name | Type | Nullable | Description & Frontend Behavior |
| :--- | :--- | :---: | :--- |
| `id` | `string` | **No** | Unique store UUID identifier. |
| `serial_number` | `integer` | **No** | Display order index for store selection lists. |
| `track_id` | `string` | **No** | Unique store tracking reference code (e.g. `"MKI0596"`). |
| `store_model` | `string` | **No** | Type of establishment (e.g. `"restaurant"`, `"cafe"`). |
| `name` | `string` | **No** | Display name of the store outlet. |
| `slug` | `string` | **No** | URL-friendly store slug string. |
| `logo_url` | `string` | **No** | Primary logo image URL. |
| `avatar_url` | `string` | **No** | Store avatar image URL. |
| `is_store_verified` | `boolean` | **No** | Store verification status flag. |
| `active_status` | `object` | **No** | Subscription status object defining store operational status. |
| `location` | `object` | **No** | Store address details & geolocational coordinates. |

---

### Subscription Active Status Enums (`active_status`)

*Path: `stores[].active_status`*

> [!TIP]
> Frontend applications check `active_status.method` enum (`DATE` or `PURCHASE`) to decide whether to render expiration date or purchase volume progress.

#### Option A: Date-Based Subscription (`method == "DATE"`)
```json
{
  "method": "DATE",
  "date": "2028-08-12",
  "purchase": null,
  "wallet_coin_balance": 126,
  "commission_rate": 0.11,
  "exchange_currency": "INR"
}
```

#### Option B: Purchase-Based Subscription (`method == "PURCHASE"`)
```json
{
  "method": "PURCHASE",
  "date": null,
  "purchase": 120458,
  "wallet_coin_balance": 126,
  "commission_rate": 0.11,
  "exchange_currency": "INR"
}
```

| Field Name | Type | Nullable | Description |
| :--- | :--- | :---: | :--- |
| `method` | `string (enum)` | **No** | Active status calculation mode: `"DATE"` or `"PURCHASE"`. |
| `date` | `string` | **Yes** | Expiration date (`YYYY-MM-DD`) when `method == "DATE"`; `null` otherwise. |
| `purchase` | `number` | **Yes** | Minimum purchase quota number when `method == "PURCHASE"`; `null` otherwise. |
| `wallet_coin_balance` | `number` | **No** | Wallet coins balance for rewards/credits. |
| `commission_rate` | `float` | **No** | Store commission rate (e.g. `0.11` = 11%). |
| `exchange_currency` | `string` | **No** | Standard currency code (e.g. `"INR"`). |

---

### Location Model (`location`)

*Path: `stores[].location`*

| Field Name | Type | Nullable | Description |
| :--- | :--- | :---: | :--- |
| `address_line_1` | `string` | **No** | Primary street address line. |
| `address_line_2` | `string` | **No** | Secondary address line or landmark. |
| `city` | `string` | **No** | City name. |
| `state` | `string` | **No** | State or province name. |
| `country` | `string` | **No** | Country name. |
| `latitude` | `float` | **No** | GPS Latitude decimal coordinate. |
| `longitude` | `float` | **No** | GPS Longitude decimal coordinate. |
| `map_url` | `string` | **No** | Google Maps URL link for store navigation. |

---

### Error Model (`error`)

*Path: `response.error`*

| Field Name | Type | Nullable | Description |
| :--- | :--- | :---: | :--- |
| `code` | `string` | **Yes** | Standard error classification code (e.g. `"INVALID_CREDENTIALS"`). `null` on success. |
| `message` | `string` | **Yes** | Human-readable error description message. `null` on success. |
