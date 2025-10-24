import Foundation

/// Pure, testable fit calculation — no dependencies on UI or AR
struct FitCalculationService {

    // MARK: - Thresholds (mm)
    static let comfortableThreshold: Double = 300  // 30cm per side min
    static let tightThreshold: Double = 100         // 10cm per side min

    /// Primary calculation: given a garage and car, return a FitResult
    static func calculate(garage: Garage, car: Car) -> FitResult {
        let lengthMargin = garage.lengthMm - car.lengthMm
        let widthMargin = garage.widthMm - car.widthMm
        let heightMargin = garage.heightMm - car.heightMm

        let status = fitStatus(lengthMargin: lengthMargin, widthMargin: widthMargin)

        return FitResult(
            garage: garage,
            car: car,
            status: status,
            lengthMarginMm: lengthMargin,
            widthMarginMm: widthMargin,
            heightMarginMm: heightMargin
        )
    }

    /// Determine fit status from margins (pure function, easily unit-testable)
    static func fitStatus(lengthMargin: Double, widthMargin: Double) -> FitStatus {
        // If either dimension is negative, the car physically cannot fit
        guard lengthMargin >= 0, widthMargin >= 0 else {
            return .doesNotFit
        }

        let minMargin = min(lengthMargin, widthMargin)

        switch minMargin {
        case comfortableThreshold...:
            return .fits
        case tightThreshold..<comfortableThreshold:
            return .tight
        case 0..<tightThreshold:
            return .tooTight
        default:
            return .doesNotFit
        }
    }

    /// Quick boolean: can the car physically enter the garage?
    static func canPhysicallyFit(garage: Garage, car: Car) -> Bool {
        return garage.lengthMm >= car.lengthMm
            && garage.widthMm >= car.widthMm
            && garage.heightMm >= car.heightMm
    }

    /// Margin for a specific axis (positive = fits, negative = exceeds)
    static func widthMargin(garage: Garage, car: Car) -> Double {
        return garage.widthMm - car.widthMm
    }

    static func lengthMargin(garage: Garage, car: Car) -> Double {
        return garage.lengthMm - car.lengthMm
    }

    static func heightMargin(garage: Garage, car: Car) -> Double {
        return garage.heightMm - car.heightMm
    }

    /// Per-side margins (assuming car is centered)
    static func perSideWidthMargin(garage: Garage, car: Car) -> Double {
        return widthMargin(garage: garage, car: car) / 2
    }

    static func perSideLengthMargin(garage: Garage, car: Car) -> Double {
        return lengthMargin(garage: garage, car: car) / 2
    }
}
