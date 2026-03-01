# GarageCheck AR — Cycle 2 Dev Notes

**Date:** 2026-03-02  
**Agent:** DEV Subagent (Cycle 2)  
**Commit:** 6e2ede3 → pushed to achmadnaufal/garagecheck-app main

---

## What Was Built

### 1. Garage Persistence ✅
- `GarageScanService.swift` — `scannedGarage` now has a `didSet` that encodes to UserDefaults
- `init()` loads from UserDefaults on first launch
- Key: `Constants.Storage.savedGaragesKey` = `"saved_garages"`
- Garage survives app restart — users don't need to re-enter dimensions every session

### 2. RoomPlan AR Scanning ✅
- New file: `GarageCheck/Views/RoomCaptureRepresentable.swift`
  - `RoomCaptureRepresentable: UIViewControllerRepresentable` wraps `RoomCaptureHostViewController`
  - `RoomCaptureHostViewController` runs `RoomCaptureSession`, shows live scan UI
  - On scan complete: extracts wall dimensions (meters → mm), calls `onScanComplete` callback
  - Whole file guarded with `#if !targetEnvironment(simulator)`
- `GarageScanView.swift` updated:
  - LiDAR button now triggers `.fullScreenCover` presenting `RoomCaptureRepresentable`
  - After scan completes, shows a naming alert before persisting
  - `#if targetEnvironment(simulator)` guards prevent any RoomPlan code on sim
  - Manual entry still works as fallback everywhere
- `GarageScanService.swift`: added `saveScannedGarage(name:lengthMm:widthMm:heightMm:)` for RoomPlan results
- `project.yml`: added `RoomPlan.framework` dependency

### 3. Unit Tests — 9 tests, all passing ✅
File: `GarageCheckTests/FitCalculationServiceTests.swift`
- `testBrioFitsInLargeGarage` — comfortable fit (≥300mm margins)
- `testFortunerDoesNotFitInTinyGarage` — negative length margin
- `testTightFitEdgeCase` — 150mm width margin → .tight
- `testHeightDoesNotFit` — height margin negative, canPhysicallyFit = false
- `testExactMatch_ZeroMargin` — 0mm all axes → .tooTight, canPhysicallyFit = true
- `testFitStatusComfortable/NegativeMargin/BothNegative/TooTight` — pure function tests

### 4. SavedResultsView Live Refresh ✅
- New `SavedResultsService.swift`: `ObservableObject` with `@Published var results: [FitResult]`
- Injected at app root as `@StateObject` in `GarageCheckApp`
- `FitCheckView` calls `savedResultsService.save(result:)` — triggers `@Published` update
- `SavedResultsView` reads `savedResultsService.results` directly — refreshes instantly, no onAppear polling needed
- `delete(at:in:)` method handles sorted-list delete correctly

### 5. Car Database Expanded ✅
Added 5 new cars to `indonesian_cars.json` (IDs 25–29):
| Make | Model | Length | Width | Height |
|------|-------|--------|-------|--------|
| Toyota | Raize | 3995mm | 1695mm | 1620mm |
| Honda | WR-V | 4348mm | 1748mm | 1607mm |
| Suzuki | Ignis | 3700mm | 1690mm | 1595mm |
| Kia | Sonet | 3995mm | 1790mm | 1642mm |
| Toyota | Veloz | 4475mm | 1775mm | 1700mm |
Total: 29 cars (was 24)

---

## Build Status
- `** BUILD SUCCEEDED **` on iPhone 17 Simulator (iOS 26.2)
- All 9 unit tests PASS

## Notes for Cycle 3
- `fitStatus()` only checks length/width — height failure shows in UI but not in status enum. Consider adding height to status logic.
- RoomPlan dimension extraction uses wall widths heuristic (largest = length, 2nd = width). Could be improved with `CapturedRoom.walls` transform analysis for true orientation.
- No multi-garage support yet (save multiple named garages and switch between them)
