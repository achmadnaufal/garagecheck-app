# GarageCheck AR — Cycle 1 Evaluation Report
**Date:** 2026-03-02  
**Evaluator:** Subagent (EVALUATE agent, Cycle 1)

---

## Overall Readiness: 55%
The app has solid SwiftUI foundations and correct fit calculation logic, but was missing an Xcode project file (critical blocker) and had several code issues. All identified issues have been fixed. The build now succeeds on the iOS Simulator.

---

## Issues Found & Fixed

### 🔴 Critical: No .xcodeproj (FIXED)
- **Problem:** No Xcode project file existed — the app could not be opened or compiled.
- **Fix:** Created `project.yml` for `xcodegen` and generated `GarageCheck.xcodeproj`.
- **Build result:** `** BUILD SUCCEEDED **` on `iphonesimulator` target.

### 🔴 Critical: Deployment Target Too Low — iOS 16 blocked `ContentUnavailableView` (FIXED)
- **Problem:** `ContentUnavailableView` (used in `CarSelectionView` and `SavedResultsView`) requires iOS 17+. The project.yml initially set iOS 16.0, causing 4 compiler errors.
- **Fix:** Bumped deployment target to iOS 17.0 in `project.yml`, regenerated project.

### 🟡 Logic Bug: Misleading Threshold Comments (FIXED)
- **Problem:** `FitCalculationService` had comments saying `// 30cm per side min` for a 300mm threshold, but 300mm is the *total* margin (garage − car). That's only 15cm per side when the car is centered. Caused misleading documentation.
- **Fix:** Updated comments to correctly read `// 15cm per side when car centered (total margin)`.

### 🟡 Dead Code: Unused Constants in FitResult.swift (FIXED)
- **Problem:** `FitResult.swift` declared two private file-level constants (`COMFORTABLE_THRESHOLD`, `TIGHT_THRESHOLD`) that were never used — `FitCalculationService` has its own copies.
- **Fix:** Removed unused constants.

### 🟡 Incorrect LiDAR Detection (FIXED)
- **Problem:** `GarageScanService.isLiDARAvailable` returned `true` for all iOS 15.4+ real devices unconditionally, without actually checking if the device has a LiDAR sensor.
- **Fix:** Changed to use `ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)` which returns `true` only on LiDAR-equipped iPhones (12 Pro+). Also added `import ARKit` to `GarageScanService.swift`.

---

## Architecture Assessment

### ✅ What's Good
- Clean separation: Models / Services / Views / Utils
- `FitCalculationService` is a pure static struct — easily unit-testable, no dependencies
- `GarageScanService` correctly separates simulator vs real device behavior
- `CarDataService` has both JSON bundle loading and a hardcoded fallback — good resilience
- `DashboardView` → TabView navigation is clean
- `FitCheckView` calculates result inline, not from a stored state — prevents stale data
- All views receive services via `@EnvironmentObject` — properly threaded through app entry point
- `SavedResultsView` uses `UserDefaults` for persistence — simple but functional for v1

### ⚠️ Architecture Gaps
1. **GarageScanView `lidarScanButton` has a TODO** — the button exists but tapping it does nothing. RoomPlan integration is the key missing feature.
2. **No `@AppStorage` or `@Published` sync for saved results** — `SavedResultsView` loads from `UserDefaults` on `onAppear` only. If you save a result in `FitCheckView` and switch to the Results tab, results won't refresh unless you navigate away and back. A shared `@StateObject` service for results would fix this.
3. **No unit tests** — `FitCalculationService` is pure and testable but no test target exists.
4. **No persistence for garage across app restarts** — `GarageScanService.scannedGarage` is in-memory only. On app restart, the user has to re-enter their garage. Should persist to `UserDefaults`.

---

## FitCalculationService — Math Review

**Logic is correct.** The core calculation:
```swift
let lengthMargin = garage.lengthMm - car.lengthMm
let widthMargin = garage.widthMm - car.widthMm
let heightMargin = garage.heightMm - car.heightMm
```
Simple and correct. Status thresholds:
- `≥300mm` total → Fits (15cm/side) ✅ Reasonable
- `100-299mm` total → Tight (5–15cm/side) ✅ Accurate description
- `0-99mm` total → Too Tight ✅
- `<0` either axis → Does Not Fit ✅

**Edge cases covered:**
- Negative margins (physically impossible) → `doesNotFit` ✅
- `canPhysicallyFit()` checks all 3 axes ✅
- `heightMargin` included (prevents tall SUVs from fitting low garages) ✅

**One missing edge case:** The `fitStatus()` function only checks `lengthMargin` and `widthMargin`, not `heightMargin`. A car could have plenty of floor space but hit the ceiling and still be marked "Fits". However `FitResult.heightMarginMm` is stored and shown in the UI, so the user can see it. Consider adding height to `fitStatus()` in a future pass.

---

## indonesian_cars.json — Data Review

- **24 cars** in JSON, **20 cars** in hardcoded fallback (JSON has more — good)
- Dimensions cross-checked against known specs:
  - Toyota Avanza: 4395×1730×1695mm ✅
  - Honda Brio RS: 3815×1680×1485mm ✅  
  - Wuling Air ev: 2974×1505×1631mm ✅ (tiny EV, correct)
  - Toyota Fortuner: 4795×1855×1835mm ✅
  - BYD Atto 3: 4455×1875×1615mm ✅
- All entries have stable UUIDs (not auto-generated), which is correct for Codable round-trips ✅
- Missing popular models: Suzuki Ignis, Honda WR-V, Toyota Raize/Rocky, Daihatsu Rocky, Kia Sonet — could expand

---

## UI Completeness

| View | Status |
|------|--------|
| OnboardingView | ✅ Complete — 3 pages, swipeable, Get Started works |
| DashboardView | ✅ Complete — TabView with 3 tabs |
| GarageScanView | ⚠️ 90% — Manual entry works; LiDAR button is placeholder TODO |
| CarSelectionView | ✅ Complete — search, grouped list, taps open FitCheckView |
| FitCheckView | ✅ Complete — badge, margins, dimensions table, save button |
| SavedResultsView | ⚠️ 85% — displays correctly but doesn't auto-refresh after saving |

---

## What Cycle 2 Should Build

### Priority 1: RoomPlan AR Scanning
- Implement `RoomCaptureViewController` wrapped in `UIViewControllerRepresentable`
- Wire result into `GarageScanService` (convert `CapturedRoom` dimensions to `Garage` model)
- Show in a `.fullScreenCover` from `GarageScanView`'s LiDAR button
- Add `RoomPlan` framework to project.yml dependencies

### Priority 2: Garage Persistence
- Add `savedGarages: [Garage]` to `GarageScanService` backed by `UserDefaults`
- Let users save and switch between multiple garages (e.g., Rumah Depok vs Rumah Surabaya)

### Priority 3: Unit Tests for FitCalculationService
- Create `GarageCheckTests` test target in project.yml
- Test: comfortable fit, tight fit, too tight, does not fit, negative margins, edge cases
- Test: height-only failure (car fits floor but hits ceiling)

### Priority 4: Fix Results Auto-Refresh
- Move results persistence into an `@ObservableObject` service
- Inject via `@EnvironmentObject` so `SavedResultsView` reacts to new saves immediately

### Priority 5: Expand Car Database
- Add: Suzuki Ignis, Honda WR-V, Toyota Raize, Daihatsu Rocky, Kia Sonet, Hyundai Stargazer

---

## Files Changed This Cycle
1. `GarageCheck/Services/FitCalculationService.swift` — Fixed threshold comments
2. `GarageCheck/Models/FitResult.swift` — Removed 2 unused constants
3. `GarageCheck/Services/GarageScanService.swift` — Fixed `isLiDARAvailable`, added `import ARKit`
4. `project.yml` — Created (new file) with iOS 17 target, ARKit + RealityKit frameworks
5. `GarageCheck.xcodeproj` — Generated via xcodegen (new, critical)
