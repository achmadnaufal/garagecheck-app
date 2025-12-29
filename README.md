# GarageCheck

**Does Your Car Fit?**

GarageCheck is an iOS app that uses Augmented Reality and LiDAR to measure your garage and instantly tell you whether a specific car will fit — with exact clearance margins on every side.

Built for Indonesian homeowners with compact developer-built garages (Type 36/45), where the difference between a Honda Avanza and a Mitsubishi Xpander fitting might be just 10cm.

---

## Features

- **AR Garage Scanning** — Use your iPhone's LiDAR (12 Pro+) for 1-3 cm accuracy, or manual dimension entry on any device
- **29 Indonesian Cars** — Pre-loaded database: Toyota Avanza, Honda Brio, Mitsubishi Xpander, Wuling Air ev, BYD Atto 3, and more
- **Instant Fit Check** — Comfortable / Tight / Doesn't Fit verdict with mm-precise margins
- **Height Check** — Car too tall for your garage? Status now reflects negative height margin
- **Side Clearance Detail** — See exactly how many cm you have on each side, front/back, and overhead
- **Save & Compare** — Store multiple fit check results; compare cars for the same garage
- **Manual Fallback** — No LiDAR? Enter dimensions with a tape measure
- **Offline First** — No internet required; car database is bundled in the app
- **Onboarding** — First-launch guide explains scanning, car selection, and results
- **Error Recovery** — RoomPlan scan failures show a clear error with retry/manual options

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Swift 5.9 |
| UI Framework | SwiftUI |
| AR Engine | ARKit 6 |
| Room Scanning | RoomPlan API (iOS 17+, LiDAR) |
| Rendering | RealityKit |
| Min iOS | 17.0 |
| Data Storage | UserDefaults (results + garage), bundled JSON (cars) |

---

## Supported Devices

| Feature | Minimum Device |
|---------|---------------|
| Manual dimension entry | Any iPhone (iOS 17+) |
| ARKit plane detection | iPhone A12+ (iOS 17+) |
| RoomPlan LiDAR scanning | iPhone 12 Pro, 13 Pro, 14 Pro, 15 Pro, 16 Pro |

---

## Project Structure

```
GarageCheck/
├── App/
│   └── GarageCheckApp.swift          # App entry point + onboarding gate
├── Views/
│   ├── OnboardingView.swift           # 3-page onboarding carousel
│   ├── DashboardView.swift            # Main tab view (Garage / Cars / Results)
│   ├── GarageScanView.swift           # AR scan + manual entry + error handling
│   ├── RoomCaptureRepresentable.swift # RoomPlan UIKit bridge (LiDAR only)
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
│   ├── GarageScanService.swift        # Manage scan state + persistence
│   └── SavedResultsService.swift      # Persist + share fit results
├── Data/
│   └── indonesian_cars.json           # 29 Indonesian market cars
├── Assets.xcassets/                   # App icon (car.fill placeholder)
└── Utils/
    └── Constants.swift                # Thresholds, keys, copy
```

---

## How to Run

### Prerequisites
- macOS 14+ with Xcode 15+
- iOS 17+ target device or simulator
- [xcodegen](https://github.com/yonaskolb/XcodeGen) (only if regenerating .xcodeproj)

### Steps

1. **Clone the repo**
   ```bash
   git clone https://github.com/achmadnaufal/garagecheck-app.git
   cd garagecheck-app
   ```

2. **Open in Xcode**
   ```bash
   open GarageCheck.xcodeproj
   ```

3. **Set your Team**
   - In Xcode: Project Settings > Signing & Capabilities
   - Select your Apple Developer team (or personal team for simulator)

4. **Build & Run**
   - **Simulator:** Select iPhone 17 Pro (or any iOS 17+ simulator). AR scanning unavailable; use manual dimension entry.
   - **Real device (recommended):** Connect an iPhone 12 Pro or newer for full RoomPlan LiDAR scanning.

5. **Build from command line** (optional)
   ```bash
   # Regenerate .xcodeproj from project.yml (requires xcodegen)
   xcodegen generate

   # Build for simulator
   xcodebuild -project GarageCheck.xcodeproj \
     -scheme GarageCheck \
     -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
     build
   ```

### Required Info.plist Keys (already configured)
```xml
<key>NSCameraUsageDescription</key>
<string>GarageCheck uses the camera to scan your garage with AR.</string>
<key>NSMotionUsageDescription</key>
<string>GarageCheck uses motion sensors for accurate AR measurement.</string>
```

---

## Car Database (29 cars)

| # | Car | Length | Width | Height | Segment |
|---|-----|--------|-------|--------|---------|
| 1 | Honda Brio RS | 3,815mm | 1,680mm | 1,485mm | City Car |
| 2 | Honda Brio Satya | 3,795mm | 1,680mm | 1,485mm | City Car |
| 3 | Toyota Avanza | 4,395mm | 1,730mm | 1,695mm | LMPV |
| 4 | Daihatsu Xenia | 4,395mm | 1,730mm | 1,690mm | LMPV |
| 5 | Mitsubishi Xpander | 4,595mm | 1,750mm | 1,730mm | MPV |
| 6 | Mitsubishi Xpander Cross | 4,595mm | 1,750mm | 1,760mm | MPV |
| 7 | Toyota Rush | 4,435mm | 1,695mm | 1,705mm | SUV |
| 8 | Toyota Kijang Innova Zenix | 4,755mm | 1,850mm | 1,795mm | Large MPV |
| 9 | Honda HR-V | 4,330mm | 1,790mm | 1,590mm | Compact SUV |
| 10 | Suzuki Ertiga | 4,395mm | 1,735mm | 1,690mm | MPV |
| 11 | Daihatsu Sigra | 4,070mm | 1,655mm | 1,600mm | LCGC MPV |
| 12 | Wuling Air ev | 2,974mm | 1,505mm | 1,631mm | City EV |
| 13 | Toyota Calya | 4,070mm | 1,655mm | 1,600mm | LCGC MPV |
| 14 | Honda Jazz | 4,035mm | 1,694mm | 1,524mm | Hatchback |
| 15 | Honda City Hatchback RS | 4,345mm | 1,748mm | 1,488mm | Hatchback |
| 16 | Hyundai Creta | 4,300mm | 1,790mm | 1,635mm | Compact SUV |
| 17 | BYD Atto 3 | 4,455mm | 1,875mm | 1,615mm | Electric SUV |
| 18 | Suzuki Baleno | 3,990mm | 1,745mm | 1,500mm | Hatchback |
| 19 | Honda BR-V | 4,455mm | 1,748mm | 1,684mm | Compact SUV |
| 20 | Wuling Almaz | 4,655mm | 1,846mm | 1,760mm | MPV |
| 21 | Toyota Fortuner | 4,795mm | 1,855mm | 1,835mm | Large SUV |
| 22 | Mitsubishi Pajero Sport | 4,785mm | 1,815mm | 1,785mm | Large SUV |
| 23 | Toyota Kijang Innova Reborn | 4,735mm | 1,830mm | 1,795mm | Large MPV |
| 24 | Daihatsu Terios | 4,435mm | 1,695mm | 1,705mm | SUV |
| 25 | Toyota Raize | 3,995mm | 1,695mm | 1,620mm | Compact SUV |
| 26 | Honda WR-V | 4,348mm | 1,748mm | 1,607mm | Compact SUV |
| 27 | Suzuki Ignis | 3,700mm | 1,690mm | 1,595mm | City Car |
| 28 | Kia Sonet | 3,995mm | 1,790mm | 1,642mm | Compact SUV |
| 29 | Toyota Veloz | 4,475mm | 1,775mm | 1,700mm | MPV |

---

## Fit Decision Logic

```
Thresholds (total margin, mm):
  >= 300mm → COMFORTABLE (Green)    — "Fits with good clearance"
  100-299mm → TIGHT (Orange)        — "Fits but clearance is tight"
  0-99mm   → TOO TIGHT (Red)        — "Technically fits but impractical"
  < 0mm    → DOES NOT FIT (Red)     — "Car is too large for this garage"

Height is now included: negative height margin = Does Not Fit.
```

---

## Unit Tests (9 tests)

Run tests:
```bash
xcodebuild test -project GarageCheck.xcodeproj \
  -scheme GarageCheck \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Coverage: FitCalculationService (all status paths), height overflow, edge cases.

---

## Disclaimer

AR measurements have an accuracy of +/-2-8 cm depending on device and lighting conditions. **Always verify with a tape measure before making a vehicle purchase.**

---

## Author

**Achmad Naufal** — [@achmadnaufal](https://github.com/achmadnaufal)

Made in Depok, Indonesia.
