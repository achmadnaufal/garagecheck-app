import Foundation
import SwiftUI

/// Thresholds in millimeters
private let COMFORTABLE_THRESHOLD: Double = 300  // 30cm per side
private let TIGHT_THRESHOLD: Double = 100         // 10cm per side

enum FitStatus: String, Codable, CaseIterable {
    case fits       = "Fits"
    case tight      = "Tight Fit"
    case tooTight   = "Too Tight"
    case doesNotFit = "Does Not Fit"

    var emoji: String {
        switch self {
        case .fits:       return "✅"
        case .tight:      return "⚠️"
        case .tooTight:   return "⚠️"
        case .doesNotFit: return "❌"
        }
    }

    var color: Color {
        switch self {
        case .fits:       return .green
        case .tight:      return .orange
        case .tooTight:   return .red
        case .doesNotFit: return .red
        }
    }

    var description: String {
        switch self {
        case .fits:       return "Comfortable fit with good clearance"
        case .tight:      return "Fits but clearance is tight"
        case .tooTight:   return "Technically fits but impractical"
        case .doesNotFit: return "Car is too large for this garage"
        }
    }
}

struct FitMargins {
    let lengthTotal: Double   // garage.length - car.length (mm)
    let widthTotal: Double    // garage.width - car.width (mm)
    let heightMargin: Double  // garage.height - car.height (mm)

    // Assuming car is centered
    var lengthFront: Double { lengthTotal / 2 }
    var lengthRear: Double  { lengthTotal / 2 }
    var widthLeft: Double   { widthTotal / 2 }
    var widthRight: Double  { widthTotal / 2 }

    var minimumMargin: Double { min(lengthTotal, widthTotal) }

    func displayString(for dimension: Double) -> String {
        if dimension < 0 {
            return String(format: "-%.0f cm", abs(dimension) / 10)
        }
        return String(format: "%.0f cm", dimension / 10)
    }
}

struct FitResult: Identifiable, Codable {
    var id: UUID
    var garage: Garage
    var car: Car
    var status: FitStatus
    var lengthMarginMm: Double
    var widthMarginMm: Double
    var heightMarginMm: Double
    var checkedAt: Date

    init(
        id: UUID = UUID(),
        garage: Garage,
        car: Car,
        status: FitStatus,
        lengthMarginMm: Double,
        widthMarginMm: Double,
        heightMarginMm: Double,
        checkedAt: Date = Date()
    ) {
        self.id = id
        self.garage = garage
        self.car = car
        self.status = status
        self.lengthMarginMm = lengthMarginMm
        self.widthMarginMm = widthMarginMm
        self.heightMarginMm = heightMarginMm
        self.checkedAt = checkedAt
    }

    var margins: FitMargins {
        FitMargins(
            lengthTotal: lengthMarginMm,
            widthTotal: widthMarginMm,
            heightMargin: heightMarginMm
        )
    }

    var summaryText: String {
        let widthCm = Int(widthMarginMm / 10)
        let lengthCm = Int(lengthMarginMm / 10)
        switch status {
        case .fits:
            return "\(car.displayName) fits with \(widthCm)cm width and \(lengthCm)cm length clearance."
        case .tight:
            return "\(car.displayName) fits but side clearance is tight (\(widthCm/2)cm per side). Door opening may be difficult."
        case .tooTight:
            return "\(car.displayName) technically fits but is impractical (\(widthCm)cm total width clearance)."
        case .doesNotFit:
            if widthMarginMm < 0 {
                return "\(car.displayName) is too wide by \(Int(abs(widthMarginMm)))mm. Does not fit."
            } else {
                return "\(car.displayName) is too long by \(Int(abs(lengthMarginMm)))mm. Does not fit."
            }
        }
    }
}
