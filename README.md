# SV_Compat

A lightweight compatibility bridge for FiveM resources.

SV_Compat is designed to standardize shared behavior across SV ecosystem scripts. It provides centralized notification routing, fallback handling, and shared utility logic to reduce duplicate code and keep resources consistent.

This resource does **not** handle permissions or admin systems. Its purpose is communication and compatibility.

---

## ✨ Features

- Centralized notification routing  
- Automatic fallback to chat if no custom system is available  
- Shared utility exports for cross-resource communication  
- Lightweight and framework agnostic  
- Designed for SV ecosystem resources  

---

## 🎯 Purpose

Many FiveM servers end up duplicating small helper systems across multiple scripts (notifications, formatting, routing, etc).

SV_Compat solves that by:

- Acting as a shared bridge  
- Reducing repeated logic  
- Standardizing how SV scripts communicate  
- Making future updates easier across all dependent resources  

---

## 🔌 Dependencies

None required by default.

SV_Compat is standalone and framework-agnostic.

Other SV resources may require this resource.

---

## 📦 Installation

1. Place the folder in your `resources` directory  
2. Add to your `server.cfg`:

```cfg
ensure sv_compat
```

3. Start the server  

That’s it.

---

## 🧠 How It Works

SV_Compat provides shared exports that other SV resources call for:

- Notifications  
- Cross-resource communication  
- Standardized behavior handling  
- Fallback messaging  

If a more advanced notification system is installed later, SV_Compat can route through it without requiring changes in dependent scripts.

---

## 🔁 Example Usage

Example export call from another resource:

```lua
exports['sv_compat']:notify(source, "Action completed successfully.", "success")
```

If no advanced notification system is available, it automatically falls back to chat.

---

## 🛠️ Designed For

- SV ecosystem scripts  
- Developers who want cleaner resource separation  
- Servers that value modular architecture  
- Future scalability  
