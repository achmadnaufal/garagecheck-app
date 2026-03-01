# 🚗 GarageCheck

**Does Your Car Fit?**

GarageCheck is an iOS app that uses Augmented Reality and LiDAR to measure your garage and instantly tell you whether a specific car will fit — with exact clearance margins on every side.

Built for Indonesian homeowners with compact developer-built garages (Type 36/45), where the difference between a Honda Avanza and a Mitsubishi Xpander fitting might be just 10cm.

---

## ✨ Features

- **AR Garage Scanning** — Use your iPhone's LiDAR (12 Pro+) for 1–3 cm accuracy, or manual dimension entry on any device
- **Indonesian Car Database** — 24+ popular cars pre-loaded: Toyota Avanza, Honda Brio, Mitsubishi Xpander, Wuling Air ev, and more
- **Instant Fit Check** — ✅ Comfortable / ⚠️ Tight / ❌ Doesn't Fit verdict with mm-precise margins
- **Side Clearance Detail** — See exactly how many cm you have on each side, front/back, and overhead
- **Save & Compare** — Store multiple fit check results; compare cars for the same garage
- **Manual Fallback** — No LiDAR? Enter dimensions with a tape measure — still super useful
- **Offline First** — No internet required; car database is bundled in the app

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Swift 5.9 |
| UI Framework | SwiftUI |
| AR Engine | ARKit 6 |
| Room Scanning | RoomPlan API (iOS 16+, LiDAR) |
| Rendering | RealityKit |
| Min iOS | 16.0 |
| Data Storage | UserDefaults (results), bundled JSON (cars) |

---

## 📱 Supported Devices

| Feature | Minimum Device |
|---------|---------------|
| Manual dimension entry | Any iPhone (iOS 16+) |
| ARKit plane detection | iPhone A12+ (iOS 16+) |
| RoomPlan LiDAR scanning | iPhone 12 Pro, 13 Pro, 14 Pro, 15 Pro, 16 Pro |

---

## 🗂 Project Structure

```
GarageCheck/
├── App/
│   └── GarageCheckApp.swift          # App entry point
├── Views/
│   ├── OnboardingView.swift           # 3-page onboarding
│   ├── DashboardView.swift            # Main tab view (Garage / Cars / Results)
│   ├── GarageScanView.swift           # AR scan + manual entry
│   ├── CarSelectionView.swift         # Browse/search car database
│   ├── FitCheckView.swift             # Fit result with margins
│   └── SavedResultsView.swift         # History of saved checks
├── Models/
│   ├── Garage.swift                   # Garage struct (name, L/W/H in mm)
│   ├── Car.swift                      # Car struct + CodingKeys for JSON
│   └── FitResult.swift                # FitStatus enum + FitResult struct
├── Services/
│   ├── FitCalculationService.swift    # Pure math: garage + car → FitResult
│   ├── CarDataService.swift           # Load cars from JSON + search
│   └── GarageScanService.swift        # Manage scan state + manual entry
├── Data/
│   └── indonesian_cars.json           # 24 Indonesian market cars with dimensions
└── Utils/
    └── Constants.swift                # Thresholds, keys, copy
```

---

## 🚀 How to Run

### Prerequisites
- Xcode 15+
- iOS 16+ target device or simulator (AR scanning requires real device)
- macOS 14+

### Steps

1. **Clone the repo**
   ```bash
   git clone https://github.com/achmadnaufal/garagecheck-app.git
   cd garagecheck-app
   ```

2. **Open in Xcode**
   ```bash
   open GarageCheck.xcodeproj
   # OR create new project and add files from GarageCheck/
   ```

3. **Set your Team**
   - In Xcode → Project Settings → Signing & Capabilities
   - Set your Apple Developer team

4. **Run on device** (recommended) or simulator
   - On simulator: AR scanning unavailable; use manual dimension entry
   - On LiDAR device (iPhone 12 Pro+): full RoomPlan scanning available

### Required Info.plist keys
```xml
<key>NSCameraUsageDescription</key>
<string>GarageCheck uses your camera to scan your garage with AR.</string>
<key>NSMotionUsageDescription</key>
<string>GarageCheck uses motion sensors for accurate AR measurement.</string>
```

---

## 📊 Car Database Sample

| Car | Length | Width | Height | Segment |
|-----|--------|-------|--------|---------|
| Honda Brio RS | 3,815mm | 1,680mm | 1,485mm | City Car |
| Toyota Avanza | 4,395mm | 1,730mm | 1,695mm | LMPV |
| Mitsubishi Xpander | 4,595mm | 1,750mm | 1,730mm | MPV |
| Toyota Innova Zenix | 4,755mm | 1,850mm | 1,795mm | Large MPV |
| Wuling Air ev | 2,974mm | 1,505mm | 1,631mm | City EV |

---

## 💡 Fit Decision Logic

```swift
// Thresholds (per side)
let COMFORTABLE = 300mm  // 30cm per side → Green ✅
let TIGHT       = 100mm  // 10cm per side → Orange ⚠️
// Below TIGHT but positive → Too Tight ⚠️
// Negative margin → Does Not Fit ❌
```

---

## 💰 Monetization

**Free + One-Time Purchase** (halal-friendly, no subscription)

- Free: First 3 fit checks
- Unlock unlimited: IDR 45,000 (~$2.99 USD) one-time

---

## ⚠️ Disclaimer

AR measurements have an accuracy of ±2–8 cm depending on device and lighting conditions. **Always verify with a tape measure before making a vehicle purchase.**

---

## 📝 Roadmap

- [ ] v1.0 — MVP (current)
- [ ] v1.1 — RoomPlan full scanning integration
- [ ] v1.2 — Side mirror width toggle (folded vs extended)
- [ ] v1.3 — Multiple garage profiles
- [ ] v1.4 — Share result as image/video
- [ ] v2.0 — Global car database via API

---

## 🧑‍💻 Author

**Achmad Naufal** — [@achmadnaufal](https://github.com/achmadnaufal)

Made with ❤️ in Depok, Indonesia.
