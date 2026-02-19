# 🗓️ Nolio

**Nolio** is a minimal, calendar-based todo app built with **Flutter**, focused on simplicity, clarity, and a clean desktop experience on Linux.

> Designed to stay out of your way while helping you plan your day.

[![AUR](https://img.shields.io/aur/version/nolio?label=AUR%20(nolio)&logo=archlinux&style=for-the-badge)](https://aur.archlinux.org/packages/nolio)
[![AUR-bin](https://img.shields.io/aur/version/nolio-bin?label=AUR%20(nolio-bin)&logo=archlinux&style=for-the-badge)](https://aur.archlinux.org/packages/nolio-bin)
[![GitHub release](https://img.shields.io/github/v/release/Grey-007/nolio?include_prereleases&label=release&style=for-the-badge)](https://github.com/Grey-007/nolio/releases)
[![License](https://img.shields.io/github/license/Grey-007/nolio?style=for-the-badge)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter&style=for-the-badge)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/platform-Linux--only-blue?logo=linux&style=for-the-badge)](https://www.kernel.org/)
[![Display](https://img.shields.io/badge/display-Wayland%20%7C%20X11-success?style=for-the-badge)](https://wayland.freedesktop.org/)


## ✨ Features

* 📅 Calendar-centric task management
* 🎨 Clean, minimal UI with consistent spacing
* 🌗 Works well with light and dark themes
* ⌨️ Keyboard & mouse friendly
* 🐧 Native Linux desktop app (Wayland & X11)

---
## v0.4.0 

### ✨ Improvements

* Timer accuracy and responsiveness significantly improved
* Added **timer stats card** for quick session insights
* Refined layout, spacing, and visual hierarchy
* Smoother animations and interactions
* Weekly view *(introduced in v0.3.0)* now stabilized

### 🪟 Behavior & Stability

* Better window handling
* General performance and reliability improvements

> UI may look different on first launch — this is intentional.

---

## 📦 Installation (Arch Linux)

### Option 1: Binary (Recommended)

Fastest install, no build required.

```bash
yay -S nolio-bin
```

### Option 2: Build from Source

Builds the app locally using Flutter.

```bash
yay -S nolio
```

---

## 🚀 Usage

Launch from terminal:

```bash
nolio
```

Or start it from your application launcher.

---

## 🛠️ Built With

* **Flutter** (Linux desktop)
* **Dart**
* GTK-based Linux runtime

---

## 📸 Screenshots

* uploading soon *

---

## 🧩 Development

Clone the repo:

```bash
git clone https://github.com/Grey-007/nolio.git
cd nolio
```

Run in development mode:

```bash
flutter pub get
flutter run -d linux
```

Build release:

```bash
flutter build linux --release
```

---

## 🤝 Contributing

Contributions, bug reports, and UI feedback are welcome.

* Open an issue for bugs or suggestions
* Keep changes focused and clean
* UI/UX feedback is especially appreciated

---

## 📄 License

MIT License
See [`LICENSE`](LICENSE) for details.

---

## ❤️ Credits

Built and maintained by **Grey-007**.

---
