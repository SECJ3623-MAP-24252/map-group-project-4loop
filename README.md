# AppTracker

A mobile stock tracking system for pharmacies, built with Flutter (MVVM) and mock data for Sprints 1 & 2.

## Features
- User registration (Pharmacist, Staff, Stock Manager)
- Login with Remember Me
- Password reset
- Pharmacy profile management (Pharmacist)
- Staff invitation (Pharmacist)
- Inventory management (Stock Manager)
- Real-time stock dashboard (simulated)
- In-app chat (mock)

## Project Structure
```
lib/
  models/
  services/
    mock/
  viewmodels/
  views/
    auth/
    dashboard/
    inventory/
    pharmacy/
    chat/
  main.dart
```

## How to Run
1. Ensure Flutter is installed.
2. Run `flutter pub get` in the project root.
3. Run `flutter run` to launch on an emulator or device.

## Notes
- All data is mock/in-memory for Sprints 1 & 2.
- Backend (Firebase) integration will be added in Sprint 3.
- UI matches provided Figma screenshots. 