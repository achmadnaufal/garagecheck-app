# Garage AR App — Research Report
**Date:** 2026-03-01  
**Purpose:** Research for an iOS AR app that measures garages and checks if a specific car fits.

---

## 1. Existing Apps & Competitive Landscape

### Direct Competitors

| App | Description | Gap |
|-----|-------------|-----|
| **GaARi: AR Car Visualizer** (App Store, 2022) | Place AR car models in your space; compare car size in AR; dealers/buyers compare proportions | Car database likely small; no actual garage scanning/measurement |
| **Edmunds "Can It Fit?"** (2017) | ARKit feature in Edmunds car-shopping app. Measures garage, overlays car footprint. Boosted app adoption 700% on launch. Built with Apple SceneKit | Buried in car-shopping app; US-only cars; appears dormant in recent versions |
| **Find Your Car with AR** | AR to locate your parked car — not garage measurement | Different use case entirely |
| **Easy Distance Measure AR** | Generic AR distance tool | Not car-specific |

### Adjacent Reference Apps

| App | What Made It Work |
|-----|------------------|
| **MagicPlan** | Room scan → floor plan; subscription ~$10/mo; integrates with home improvement workflow |
| **RoomScan Pro** | Simple UX (touch wall), LiDAR-first, users report <1 inch accuracy |
| **IKEA Place** | Real product catalog + AR = purchase intent; known 3D models |
| **Apple RoomPlan (demo app)** | Official demo of RoomPlan API; 5★ reviews, "less than an inch difference" |

### Gap Analysis — The Opportunity
- **No dedicated standalone app** combines: (1) scan a garage with LiDAR, (2) pick car make/model/year, (3) AR overlay showing if it fits with margin feedback.
- Edmunds had this in 2017 but it was a feature, not a product, and US-only.
- **Indonesian market completely unserved** — no app targets local popular cars (Avanza, Brio, Xenia, etc.).
- Real pain point in Depok/Indonesian housing: narrow garages in developer housing (type 36/45) that barely fit one MPV.

---

## 2. AR Frameworks Comparison

### 2.1 ARKit (Native Swift/SwiftUI) ✅ RECOMMENDED

- **Capabilities:** World tracking, plane detection, scene reconstruction, LiDAR depth scanning (iPhone 12 Pro+), RealityKit rendering, RoomPlan API (iOS 16+, 2022)
- **RoomPlan API:** Generates structured 3D room model (walls, doors, windows) using LiDAR + camera + ML in minutes. Returns room dimensions as structured data (ideal for garage).
- **Accuracy:** LiDAR devices → 1–3 cm error. Non-LiDAR → 3–8 cm error (visual inertial odometry).
- **LiDAR devices:** iPhone 12 Pro, 13 Pro, 14 Pro, 15 Pro, 16 Pro; all iPad Pro since 2020.
- **Maturity:** Apple first-party, continually updated, best documentation, no dependencies.
- **Best for:** Production-quality garage scanning with highest accuracy.
- **Verdict:** ✅ Best choice for this app.

### 2.2 React Native + ViroReact / ReactVision

- **Status:** Community fork (ReactVision) active, but npm package last published ~2 years ago (v2.41.1). GitHub shows issues with Expo 52 (Dec 2024 issues open).
- **Problems:** Wraps ARKit anyway but loses access to RoomPlan API; JS bridge adds overhead; Expo 52 incompatibility is a real blocker.
- **Verdict:** ❌ Not recommended. Adds complexity, loses key APIs, stale community.

### 2.3 Expo AR / expo-three

- **Status:** Effectively deprecated for serious AR use. Minimal updates, no LiDAR support, no room scanning.
- **Verdict:** ❌ Not suitable.

### 2.4 WebAR (8thWall, MindAR)

- **8thWall:** Commercial ($99+/mo). Good for marketing campaigns. No app install needed.
- **MindAR:** Open-source, good for image/face tracking.
- **Limitations for this use case:**
  - Browser cannot access LiDAR depth data (iOS Safari restriction)
  - Measurement accuracy ~5–15 cm typical error
  - No RoomPlan API access
  - Higher battery drain, worse performance
- **Verdict:** ❌ Not suitable for precision garage measurement.

### Framework Recommendation Summary

```
Use: Native ARKit + RoomPlan API (Swift/SwiftUI)
Primary path: RoomPlan API (requires LiDAR, iOS 16+)
Fallback: ARKit plane detection (all iPhones A12+, iOS 14+)
Rendering: RealityKit
```

---

## 3. Car Dimensions Data Sources

### API Options

| API | Coverage | Dimensions | Cost | Notes |
|-----|----------|-----------|------|-------|
| **CarAPI (carapi.app)** | US-focused, 1990–present, trim-level | ✅ length, width, height, wheelbase, ground clearance | Free 100 req/day; paid from ~$20/mo | Best structured dimensions data |
| **API Ninjas (api-ninjas.com/api/cars)** | Global makes | ✅ Some dimension fields | Free limited; $5/mo basic | Less complete for Asian market |
| **CarQuery API (carqueryapi.com)** | Global, 1941–present | ✅ Body dimensions | Free (rate-limited JSON) | Good global coverage incl. Asian cars |
| **NHTSA vPIC API** | US-registered vehicles | ✅ Width (OW), Height (OH), Wheelbase (WB) via CVS subset | 100% Free, no API key | US-only; good for US cars; Asian models sparse |
| **VehicleDatabases.com** | Global | ✅ Full dimensions | Paid only | More complete but costly |
| **automobiledimension.com** | Global | ✅ Manual lookup | Web only, no official API | Useful as reference/scraping source |

### NHTSA vPIC Note
- Includes Canadian Vehicle Specifications with Overall Width (OW), Overall Height (OH), Wheelbase (WB)
- Completely free, no API key required
- Best for US market vehicles; limited for Indonesian-market-only models

### Best Strategy for Indonesian Market
1. **CarQuery API** (free, global) — primary lookup
2. **Hardcoded curated database** of top 20 Indonesian popular cars (most reliable for local models)
3. **Manual entry fallback** — let user enter L×W×H (great for custom/modified cars)

### Key Data Fields Needed Per Car

```json
{
  "make": "Toyota",
  "model": "Avanza",
  "year": 2024,
  "length_mm": 4395,
  "width_mm": 1730,
  "height_mm": 1695,
  "wheelbase_mm": 2750
}
```

---

## 4. AR Measurement Accuracy

### Without LiDAR (Visual Inertial Odometry — all iPhones)
- Typical error: **3–8 cm** for distances under 5 m
- Depends heavily on lighting, surface texture
- Acceptable for rough fit-check (garage is 3–6 m long; 5 cm error = ~1% error rate)

### With LiDAR (iPhone 12 Pro and newer Pro models)
- Typical error: **1–3 cm** indoor room-scale
- ISPRS 2024 academic study: LiDAR-based Apple apps reliable for indoor surveys with small errors
- RoomPlan user reviews: consistently <1 inch (~2.5 cm) accuracy
- For garage (5 m long), 2 cm error = **0.4% error rate** — excellent for car fit decisions

### Practical Implications
- Standard Depok garage clearance margin: 10–40 cm per side
- LiDAR accuracy (±2 cm) → reliably useful predictions
- Non-LiDAR (±5–8 cm) → still useful; show uncertainty warning
- **Recommendation:** Show confidence badge based on LiDAR availability ("High accuracy" vs "Estimated")

---

## 5. Successful Apps — Lessons Learned

### Edmunds "Can It Fit?" (2017)
- Built by Brock Stearn using Apple SceneKit + ARKit (day-one ARKit release)
- Boosted Edmunds app adoption by 700% in first week
- Featured in CNET top AR apps lists
- **Lesson:** Practical AR utility goes viral. But as a buried feature in a shopping app, it's now effectively abandoned.
- **Lesson for us:** A standalone app has more longevity and discoverability.

### RoomScan Pro
- Simple UX: touch phone to wall → marks corner → builds floor plan
- LiDAR-first, fallback for older devices
- Users say "super accurate - less than an inch difference"
- **Lesson:** Focus on one thing, do it extremely well, let accuracy be the marketing.

### IKEA Place
- Real furniture catalog (actual dimensions from IKEA) + AR placement
- Trust comes from knowing the dimensions are exact
- **Lesson:** The real car database IS the product, not just the AR.

### MagicPlan
- Subscription model, pro export (DXF/CAD), integrates into contractor workflow
- **Lesson:** Pro features (export, share) justify subscription.

### Open Source References on GitHub
- `shawnxdsun/arkit-measure` — ARKit + RealityKit measurement, iOS 16
- `fatclarence/ARFurnitureApp` — IKEA Place clone, ARKit plane detection
- `RaimundoGallino/PlaceApp-Clone-ARFoundation` — Unity AR Foundation furniture placement
- Apple WWDC 2022 RoomPlan sample code (official)

---

## 6. Indonesian Market — Popular Cars & Dimensions

### Best-Selling Cars in Indonesia 2023
1. Toyota Kijang Innova (Reborn + Zenix)
2. Honda Brio (RS + Satya) ← consistent top seller
3. Toyota Avanza ← most iconic Indonesian family car
4. Daihatsu Sigra
5. Toyota Calya
6. Suzuki Carry
7. Mitsubishi Xpander
8. Daihatsu Xenia
9. Toyota Rush
10. Honda Jazz / City Hatchback

### Curated Dimensions — Top Indonesian Cars

| Car | Length (mm) | Width (mm) | Height (mm) | Wheelbase (mm) | Segment |
|-----|-------------|------------|-------------|----------------|---------|
| Honda Brio Satya/RS | 3,795–3,815 | 1,680 | 1,485 | 2,405 | City car |
| Toyota Avanza | 4,395 | 1,730 | 1,695 | 2,750 | LMPV |
| Daihatsu Xenia | 4,395 | 1,730 | 1,690 | 2,750 | LMPV |
| Toyota Calya | 4,070 | 1,655 | 1,600 | 2,525 | LCGC MPV |
| Daihatsu Sigra | 4,070 | 1,655 | 1,600 | 2,525 | LCGC MPV |
| Mitsubishi Xpander | 4,595 | 1,750 | 1,730 | 2,775 | MPV |
| Toyota Rush | 4,435 | 1,695 | 1,705 | 2,685 | SUV |
| Toyota Kijang Innova | 4,735 | 1,830 | 1,795 | 2,750 | Large MPV |
| Toyota Kijang Innova Zenix | 4,755 | 1,850 | 1,795 | 2,850 | Large MPV |
| Suzuki Ertiga | 4,395 | 1,735 | 1,690 | 2,740 | MPV |
| Honda Jazz | 4,035 | 1,694 | 1,524 | 2,530 | Hatchback |
| Honda City Hatchback RS | 4,345 | 1,748 | 1,488 | 2,600 | Hatchback |

### Typical Depok/Jakarta Residential Garage Sizes
- **Type 36/45 developer houses (most common in Depok):** ~2.3–2.6 m wide × 4.0–5.0 m long
- **Type 60+ houses:** ~2.8–3.2 m wide × 5.0–6.0 m long
- **Key tension:** Many families upgrading from Honda Brio to Toyota Avanza/Xpander are unsure if it will fit
- **Width is the critical constraint** — most issues are width (garage 2.4 m, car 1.73 m = only 35 cm per side)

### Why This App Has Real Value in Indonesia
- Garage space in developer housing is minimal and standardized to cost-cutting specs
- Cars are getting wider (Xpander 1.75 m, Zenix 1.85 m) while older garages stay the same
- Renting a car before buying to test garage fit = real behavior that happens
- No reliable app for this currently = genuine whitespace

---

## 7. Recommended Tech Stack & MVP Plan

```
Platform:         iOS (native Swift/SwiftUI)
AR Framework:     ARKit + RoomPlan API
Rendering:        RealityKit
Car Data:         CarQuery API (free) + hardcoded Indonesian top 20 cars
Local Storage:    CoreData (saved garages)
Min iOS:          16.0 (RoomPlan); ARKit fallback iOS 14+
LiDAR devices:    iPhone 12 Pro, 13 Pro, 14 Pro, 15 Pro, 16 Pro + iPad Pro 2020+
```

### MVP Features (v1.0)
1. **Scan garage** — RoomPlan walkthrough (LiDAR) or manual tap-to-measure (non-LiDAR fallback)
2. **Select car** — Indonesian car database (top 20 hardcoded) + search
3. **Fit check** — AR car footprint overlay + numeric margin ("Left: 22 cm | Right: 18 cm | Front: 35 cm")
4. **Result** — Clear ✅ Fits / ⚠️ Tight / ❌ Won't fit badge
5. **Save garage** — store multiple garage profiles

### Future Features (v1.1+)
- Full global car database via API
- Share result (screenshot/video)
- Manual dimension entry
- Side mirror width (folded vs extended)
- Multiple parking spots per garage

---

## 8. References

- Edmunds "Can It Fit?" launch: https://www.engadget.com/2017-09-19-edmunds-augmented-reality-car-fit-feature.html
- GaARi App Store: https://apps.apple.com/us/app/gaari-ar-car-visualizer-drive/id1629459924
- Apple RoomPlan App Store reviews: https://apps.apple.com/us/app/roomplan-interior-3d-scanner/id1658425563
- RoomPlan API overview (Volpis): https://volpis.com/blog/apple-roomplan-overview/
- LiDAR accuracy study ISPRS 2024: https://isprs-archives.copernicus.org/articles/XLVIII-2-W8-2024/431/2024/
- ARKit measurement accuracy (Medium/Slalom): https://medium.com/slalom-build/ios-16-how-arkit-and-realitykit-help-measure-objects-accurately
- CarAPI specs: https://carapi.app/features/json-api-specs
- CarQuery API: https://www.carqueryapi.com/
- API Ninjas Cars: https://api-ninjas.com/api/cars
- NHTSA vPIC API: https://vpic.nhtsa.dot.gov/api/
- ViroReact/ReactVision: https://github.com/ReactVision/viro
- OTO.com Indonesian car comparisons: https://www.oto.com/en/
- Best-selling cars Indonesia 2023: https://www.mpm-rent.com/en/news-detail/best-selling-cars-in-indonesia-2023-check-the-list-here
- Grab Indonesia garage guide (car dimensions): https://www.grab.com/id/blog/driver/grab-indonesia-daftar-ukuran-mobil-yang-pas-di-garasi-rumah-mana-pilihanmu/
- arkit-measure GitHub: https://github.com/shawnxdsun/arkit-measure

---
*Research compiled by AI assistant — March 2026*
