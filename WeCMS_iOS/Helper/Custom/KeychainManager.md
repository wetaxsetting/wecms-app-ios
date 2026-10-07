# KeychainManager

A lightweight, native Keychain wrapper (`enum KeychainManager`) that replaces the third-party KeychainSwift dependency. All methods are static — no instantiation needed.

Located at: `Helper/Custom/KeychainManager.swift`

---

## API Reference

### Generic (key-only) operations

| Method | Description |
|---|---|
| `set(_ value: String, forKey key: String) -> Bool` | Saves or updates a string value under `key` in the Keychain. Returns `true` on success. |
| `get(_ key: String) -> String?` | Retrieves the string stored under `key`. Returns `nil` if not found. |
| `delete(_ key: String) -> Bool` | Deletes the item stored under `key`. Returns `true` on success. |

### Credential helpers (service-scoped)

These helpers automatically append a version suffix (`_Cambodia`, `_Vietnam`, `_WeCMS`) to the key, preventing credential mixing between WABOOKS KH, WABOOKS VN, and WeCMS VN accounts on the same device.

| Method | Description |
|---|---|
| `setCredential(_ value: String, forKey key: String) -> Bool` | Saves a credential under `key + version suffix`. |
| `getCredential(_ key: String) -> String?` | Retrieves the credential stored under `key + version suffix`. |
| `deleteCredential(_ key: String) -> Bool` | Deletes the credential stored under `key + version suffix`. |

---

## Usage

```swift
// Save login credentials on successful login
KeychainManager.setCredential(userID, forKey: "username")
KeychainManager.setCredential(password, forKey: "password")

// Read credentials for auto-login
let userID = KeychainManager.getCredential("username") ?? ""
let password = KeychainManager.getCredential("password") ?? ""

// Clear credentials on logout
KeychainManager.deleteCredential("username")
KeychainManager.deleteCredential("password")
```

---

## Where it is used

| File | Purpose |
|---|---|
| `AppDelegate.swift` | One-time migration of old shared keys to service-specific credential keys on first launch |
| `SceneDelegate.swift` | Re-authenticates in background when app becomes active |
| `LaunchScreenVC.swift` | Reads credentials for auto-login flow |
| `LoginVC.swift` | Saves credentials after successful login (R001) |
| `CompanyVM.swift` | Reads credentials to call the login API (R002) |
| `ProfileVM.swift` | Deletes credentials on logout (R003) |
| `ProfileVC.swift` | Clears credentials from the UI logout flow |

---

## Version suffix logic

The suffix is derived from `Shared.wabooksVersion.rawValue` at call time:

| WABOOKS Version | Key example |
|---|---|
| Cambodia | `username_Cambodia` |
| Vietnam | `username_Vietnam` |
| WeCMS | `username_WeCMS` |

This ensures users on the same device with different regional accounts never share stored credentials.
