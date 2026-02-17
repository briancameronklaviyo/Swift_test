# SimpleAuthApp

A simple SwiftUI iOS app with **local authentication**—no Firebase or third-party auth. Users are stored on device with hashed passwords and Keychain for session.

## Features

- **Login** – Sign in with email and password
- **Create account** – Sign up with name, email, and password (min 6 characters)
- **User info** – After login: view/edit name, view login email
- **Change password** – Update password (current password required)
- **Log out** – Clear session and return to login

## How it works

- **User store**: Accounts are saved in a JSON file in Application Support (email, name, password hash, salt). Passwords are hashed with SHA-256 and a per-user salt.
- **Session**: The current user ID is stored in the **Keychain** so the app stays logged in across launches until the user logs out.
- **No server**: Everything runs on the device. No backend or Firebase.

## Requirements

- Xcode 15+
- iOS 15.0+

## Run the app

1. Open `SimpleAuthApp.xcodeproj` in Xcode.
2. Choose an iOS Simulator or a connected device.
3. Press **Run** (⌘R).

## Project structure

```
SimpleAuthApp/
├── SimpleAuthAppApp.swift    # App entry, injects AuthService
├── ContentView.swift         # Shows Login or UserInfo by auth state
├── Models/
│   └── User.swift            # User model (id, name, email, passwordHash, salt)
├── Services/
│   ├── AuthService.swift     # Sign up, login, logout, update profile, change password
│   ├── KeychainService.swift # Save/load/clear session in Keychain
│   └── UserStore.swift       # Load/save users JSON, hash passwords, CRUD
├── Views/
│   ├── LoginView.swift       # Email/password + link to sign up
│   ├── SignUpView.swift      # Name, email, password, confirm
│   └── UserInfoView.swift    # Name, email, change password, log out
└── Assets.xcassets
```
