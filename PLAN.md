# 🚗 GarageCheck AR — MVP Plan
**Version:** 1.0 Draft  
**Date:** 2026-03-01  
**Author:** Planning Agent (for Naufal)  
**Context:** Naufal, Lead DA, Depok — evaluating car purchase, needs to verify garage fit

---

## 1. Problem Statement

Naufal wants to buy a car but lives in a small house in Depok with limited garage space (currently occupied by a Honda Beat ESP). Before committing to a purchase — which in Indonesia often means a DP (down payment) of IDR 20–50M+ — he needs to **physically verify** whether a specific car model will fit in his garage.

The current "solution" is: measure with a tape measure, look up car dimensions online, do math, hope for the best. This is error-prone, tedious, and doesn't account for door-opening clearance or shared space with the motorcycle.

**GarageCheck AR** solves this by letting users:
- Scan their garage with their iPhone camera to capture real-world dimensions
- Select a car model (with dimensions auto-loaded from a database)
- See a true-to-scale AR overlay of the car inside the garage
- Get an instant ✅ / ⚠️ / ❌ fit verdict with margin measurements

**Who else has this problem?** Millions of Indonesian homeowners in Type 36–72 houses (most common in Depok, Tangerang, Bekasi) where garages are 2.5–3m wide and 4–5m deep.

---

## 2. MVP Scope

### ✅ IN — v1.0
- iPhone AR garage scanning (floor + wall plane detection)
- Capture garage bounding box: length × width × height
- Car database search: make → model → year → auto-load dimensions
- AR overlay: ghost car bounding box placed in scanned garage
- Fit result: ✅ Fits / ⚠️ Tight fit / ❌ Too tight
- Margin display: e.g. "12cm clearance on driver side"
- Save garage profile (name it "Rumah Depok")
- Save car comparison results locally
- Basic onboarding (how to scan correctly)
- iOS only (iPhone with LiDAR preferred; ARKit fallback for non-LiDAR)
- Manual dimension entry fallback

### ❌ OUT — v1.0 (explicitly deferred)
- Android support
- Real-time AR car placement (static snapshot only for MVP)
- Multiple garage profiles (only 1 in MVP)
- User accounts / cloud sync
- Door swing clearance simulation
- 3D photorealistic car model rendering (bounding box only — avoids licensing)
- Car dealership / pricing integration
- iPad support
- Motorcycle / other vehicle types

---

## 3. User Flow

```
ONBOARDING (first launch)
│
├── Splash screen → 3-step tutorial (tap through)
│   "Point at floor → mark corners → mark height"
│
GARAGE SCAN
│
├── Step 1: Tap "Scan My Garage"
├── Step 2: Point camera at garage floor → app detects horizontal plane
├── Step 3: Tap to anchor corner point 1 (front-left)
├── Step 4: Walk to opposite corner → tap corner point 2
├── Step 5: App calculates floor length × width
├── Step 6: Point at wall → tap to mark ceiling height
├── Step 7: Confirm: "Garage: 5.2m × 2.8m × 2.4m — Correct?"
└── Saved ✓ (name it optionally)

CAR SELECTION
│
├── Tap "Check a Car"
├── Search: type make (e.g. "Toyota")
├── Select model (e.g. "Avanza") → year (e.g. 2024)
├── App shows: L: 4,265mm | W: 1,660mm | H: 1,695mm
└── Tap "Check Fit"

FIT CHECK (AR View)
│
├── AR view: scanned garage floor plane shown
├── Ghost blue bounding box of car placed in center
├── Margins displayed on each side (color-coded)
│   Green = >30cm | Orange = 10–30cm | Red = <10cm
│
└── RESULT CARD:
    ✅ "Toyota Avanza fits with comfortable clearance"
    ⚠️ "Honda HR-V fits but side clearance is tight (8cm). Door opening may be difficult."
    ❌ "Toyota Fortuner is too wide by 14cm. Does not fit."

SAVE / COMPARE
│
├── "Save Result" → stored locally
├── "Compare Another Car" → back to car selection
└── "Share" → screenshot to gallery / WhatsApp
```

---

## 4. Tech Stack Recommendation

### Options Compared

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| ARKit native Swift | Best AR accuracy, LiDAR, Apple-native | New ecosystem, can't reuse Amanah code | ❌ Overkill solo |
| RN + ViroReact | JS-based, AR capable | Abandoned since 2020, no Expo support | ❌ Dead project |
| Expo managed + WebGL | Reuses Amanah exactly | No native ARKit, limited AR accuracy | ⚠️ Weak AR |
| RN + VisionCamera bridge | RN base, native AR bridge | Complex setup, needs native knowledge | ⚠️ Possible |
| **RN + Expo bare + ARKit module** | Best balance: RN infra + real ARKit | Must eject from managed workflow | ✅ RECOMMENDED |
| WebAR (8th Wall) | No install needed | Terrible measurement accuracy, subscription cost | ❌ Not suitable |

### 🏆 Recommendation: Expo Bare Workflow + Custom ARKit Swift Bridge

**Why:**
- Amanah is Expo → use **expo eject** to bare workflow — keep Expo tooling (EAS Build, OTA updates, TS/JS ecosystem)
- Write a thin **Swift ARKit bridge** (~400 lines) for plane detection + measurement — hard AR math done natively
- All UI, car database, results logic stays in React Native / TypeScript
- Same dev environment as Amanah

**Bridge API exposed to RN:**
```typescript
GarageARModule.startScanning()
GarageARModule.capturePoint(x, y) → Promise<{x, y, z}>
GarageARModule.getGarageDimensions() → Promise<{length, width, height}>
```

---

## 5. Key Features — Technical Detail

### Garage Measurement
- ARKit World Tracking + plane detection
- User taps 2 floor points → ray cast to plane → real-world distance
- Accuracy: ±2–5cm with LiDAR (iPhone 12 Pro+), ±5–15cm without
- Store: `{ length_mm, width_mm, height_mm, name, created_at }`

### Car Database
- Bundled SQLite (~500KB) with top 150 Indonesian market cars
- Brands: Toyota, Honda, Suzuki, Daihatsu, Mitsubishi, Hyundai, Wuling, BYD (2018–2025)
- Fields: make, model, year, length_mm, width_mm, height_mm, wheelbase_mm
- Fuzzy search on make + model
- Fallback: manual dimension entry

### Fit Logic
```typescript
const COMFORTABLE = 300; // mm — 30cm per side
const TIGHT = 100;       // mm — 10cm per side

function getFitResult(garage, car) {
  const lengthMargin = garage.length_mm - car.length_mm;
  const widthMargin = garage.width_mm - car.width_mm;
  if (lengthMargin < 0 || widthMargin < 0) return "DOES_NOT_FIT";
  const min = Math.min(lengthMargin, widthMargin);
  if (min >= COMFORTABLE) return "FITS";
  if (min >= TIGHT) return "TIGHT";
  return "TOO_TIGHT"; // fits technically but impractical
}
```

### AR Overlay
- Semi-transparent bounding box anchored to garage floor plane
- Scale = car dimensions from DB
- Tap-drag to reposition (e.g., offset left for motorcycle space)
- Color changes live based on margin

---

## 6. Car Dimensions Data Sources

| Source | Coverage | Quality | Verdict |
|--------|----------|---------|---------|
| NHTSA API (api.nhtsa.gov) | US market | No dimensions (safety only) | ❌ |
| CarQuery API (carqueryapi.com) | Global, some specs | Dimensions inconsistent | ⚠️ |
| Edmunds API | US market | Has dimensions, paid | ⚠️ |
| Wikipedia scraping | Global | Fragile, no API | ❌ |
| **Curated manual dataset** | Indonesia-specific | High quality, offline | ✅ RECOMMENDED |

### 🏆 Recommended: Bundled SQLite (Manual Curation)

- No Indonesian public API exists for car dimensions
- Official brand sites (Toyota.astra.co.id, Honda.co.id, etc.) publish all specs
- One-time effort: ~6–8 hours to compile 150 models
- Ships offline — no API calls, no rate limits, no failures
- Update with each app version or as JSON patch via OTA
- Start with the 20 cars Naufal is personally considering — expand later

---

## 7. Monetization

**Constraint: Halal only, no subscription**

### Recommendation: Free + One-Time IAP Unlock

| Model | Price | Notes |
|-------|-------|-------|
| Free download | - | Maximizes installs, good for App Store discovery |
| First 3 comparisons | Free | Enough to validate the app works |
| Unlock unlimited | $2.99 USD (~IDR 47K) | One-time purchase, transparent, halal |

**Why not subscription:** Users use this app once or twice (when buying a car). Subscription is extractive for this use case and off-brand.

**Why not ads:** Breaks focus during an AR measurement task. Not worth it.

**Revenue reality check:** This is primarily a portfolio/personal-use app. If 500 users pay $2.99 = ~$1,500 USD. Bonus if it finds a niche audience.

---

## 8. Risks

### Technical
| Risk | Level | Mitigation |
|------|-------|------------|
| AR measurement accuracy on non-LiDAR phones | High | Show confidence indicator; always allow manual override |
| Plane detection fails (dark garage, shiny floor) | Medium | Tutorial on lighting; manual fallback |
| Irregular garage shape (pillars, angles) | Medium | MVP assumes rectangle; add disclaimer |
| Expo bare workflow complexity | Medium | Use EAS Build cloud; document setup |

### Product
| Risk | Level | Mitigation |
|------|-------|------------|
| User trusts AR blindly → wrong car decision | High | Prominent disclaimer: "Verify with tape measure before purchasing" |
| Car not in database | Medium | Manual dimension entry always available |
| Garage has items blocking scan (motorcycle) | Medium | Remind user: measure empty space first |

### Business
| Risk | Level | Mitigation |
|------|-------|------------|
| App Store rejection (camera permissions) | Low | Follow Apple privacy guidelines, add usage descriptions |
| Very niche market | Low | It's a side project — niche is fine |

---

## 9. Timeline Estimate (AI-Assisted Coding)

Working evenings/weekends (~2–3h/day) with Claude Code:

| Phase | Tasks | Duration |
|-------|-------|----------|
| Phase 0: Setup | Expo eject, EAS setup, Xcode config | 1–2 days |
| Phase 1: ARKit Module | Swift plane detection + 2-point measurement | 4–6 days |
| Phase 2: RN Bridge | Expose to RN, test accuracy on device | 2–3 days |
| Phase 3: Car Database | Compile SQLite dataset (100 cars), search UI | 2–3 days |
| Phase 4: Fit Logic + AR Overlay | Bounding box, margins, result card | 3–4 days |
| Phase 5: UX Polish | Onboarding, errors, local storage, disclaimer | 2–3 days |
| Phase 6: Testing | Multi-device, edge cases | 2–3 days |
| Phase 7: App Store | Screenshots, metadata, submission | 1–2 days |

**Total: ~3–4 weeks**

**Critical path:** Phase 1 (ARKit Swift module) is the hardest part. If it stalls, fallback plan: skip live AR scan → manual measurement input only → still useful as a "Car Fit Calculator" app.

**Milestone check:** After Phase 2, you should have a working garage scan → if that works, the rest is React Native (familiar territory from Amanah).

---

## 10. App Name + Repo Suggestions

### App Names
| Name | Notes |
|------|-------|
| **GarageCheck** | Clear, functional, searchable on App Store |
| GarFit | Short, catchy |
| MasukGarage | Indonesian — "enters the garage" |
| CukupGak? | Indonesian slang — "Does it fit?" — relatable |
| MobilarAR | From "mobil" (car in Indonesian) + AR |

**→ Recommend: GarageCheck** (App Store friendly, universal)  
**→ Subtitle: "Does Your Car Fit?"**

### Repo Names
| Name | Notes |
|------|-------|
| **garagecheck-app** | Matches app name, professional |
| garage-ar | Simple, already the project dir |
| garage-fit-ar | Descriptive |

**→ Recommend: `garagecheck-app`**

---

## Quick Reference Card

| | |
|---|---|
| **App name** | GarageCheck |
| **Tagline** | Does Your Car Fit? |
| **Repo** | `garagecheck-app` |
| **Stack** | Expo bare + RN + ARKit Swift bridge |
| **Data** | Bundled SQLite, 150 Indonesian cars |
| **Monetization** | Free + $2.99 one-time IAP |
| **Timeline** | 3–4 weeks (AI-assisted) |
| **Top risk** | AR accuracy on non-LiDAR devices |
| **Kill switch** | Manual dimension entry always available |

---

## Immediate Next Steps

1. Create repo: `garagecheck-app` on GitHub
2. `npx create-expo-app garagecheck-app --template bare-minimum`
3. Configure EAS Build for iOS
4. Prototype ARKit plane detection (2 taps → distance) in Swift
5. Compile car dataset: start with 20 cars Naufal is considering (e.g. Avanza, Rush, HR-V, Xpander, Ertiga, BYD Atto 3)
6. Reuse Amanah's navigation + UI component patterns

---

*Plan created: 2026-03-01 | Status: Ready for dev kickoff*
