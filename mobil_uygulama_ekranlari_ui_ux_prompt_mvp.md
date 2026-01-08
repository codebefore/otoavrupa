# Mobil Uygulama Ekranları – UI/UX Prompt (MVP)

Aşağıdaki prompt, araç servis mobil uygulamasının **MVP ekranlarını** üretmek için UI/UX tasarımcıya veya tasarım üreten bir AI aracına **aynen verilecek** şekilde hazırlanmıştır.

---

## 🎯 UI/UX Tasarım Promptu

```
You are a senior mobile UX/UI designer.

Design the MVP screens of a vehicle service tracking mobile application
based on the following system and product constraints.

CONTEXT:
- The app is read-only for customers.
- All service operations are done in an external system (Delta Pro).
- The mobile app only displays vehicle and service information.
- Data is synced via a cloud backend.
- The target users are car owners (non-technical users).

PLATFORM:
- iOS and Android (cross-platform, mobile-first)
- Clean, simple, professional automotive service style

AUTHENTICATION:
- Login with phone number and OTP (no password).

MVP SCREENS TO DESIGN:

1. Login Screen
- Phone number input
- OTP verification flow
- Minimal, fast, no registration form

2. Vehicles List (Home Screen)
- List of user's vehicles
- Each vehicle card must show:
  - License plate
  - Brand / model
  - VIN (chassis number)
  - Current service status:
    - In Service
    - In Progress
    - Ready
    - Delivered

3. Vehicle Detail Screen
- Selected vehicle information:
  - License plate
  - Brand / model
  - VIN (clearly visible)
  - Current status
  - Last update timestamp
- Navigation to:
  - Service History
  - Documents (PDF)

4. Service History Screen
- List of completed service records
- Each record shows:
  - Date
  - Mileage (KM)
  - Short service summary
- Tap to view service details

5. Service Detail Screen
- Detailed service information:
  - Performed operations
  - Replaced parts
  - Total amount
- Related VIN reference
- Access to service documents

6. Documents Screen
- List of available PDF documents:
  - Service receipt
  - Invoice
- In-app PDF viewer

7. Notifications Flow (UX reference)
- Push notification examples:
  - "Your vehicle has been received by the service."
  - "Your vehicle is ready."
  - "Your vehicle has been delivered."
- Tapping a notification opens the related vehicle detail screen.

UX RULES:
- No editing or data input by the user
- No payment, booking, or chat features in MVP
- Clear status visibility is the top priority
- Show "Last updated" timestamp to set expectations
- VIN must be visible on vehicle card and detail screen
- Simple navigation (max 3 taps to any information)

DELIVERABLE:
- Wireframes or high-fidelity mobile UI screens
- Clear screen-to-screen navigation flow
- Focus on clarity, trust, and ease of use
```

---

## ℹ️ Kullanım Notu
- Bu prompt **wireframe**, **high‑fidelity tasarım** veya **AI destekli UI üretimi** için uygundur.
- MVP kapsamı dışına çıkılmaması için özellikle *UX RULES* bölümünün korunması önerilir.

