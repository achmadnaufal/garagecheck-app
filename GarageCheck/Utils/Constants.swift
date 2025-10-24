import Foundation
import SwiftUI

enum Constants {
    enum App {
        static let name = "GarageCheck"
        static let tagline = "Does Your Car Fit?"
        static let bundleID = "com.naufal.garagecheck"
        static let version = "1.0.0"
    }

    enum Fit {
        /// Minimum margin (mm) to consider a comfortable fit
        static let comfortableThreshold: Double = 300
        /// Minimum margin (mm) to consider a tight but usable fit
        static let tightThreshold: Double = 100
    }

    enum UI {
        static let cornerRadius: CGFloat = 16
        static let padding: CGFloat = 16
        static let largePadding: CGFloat = 24
    }

    enum Colors {
        static let fitGreen = Color.green
        static let fitOrange = Color.orange
        static let fitRed = Color.red
        static let primary = Color.blue
    }

    enum Storage {
        static let savedGaragesKey = "saved_garages"
        static let savedResultsKey = "saved_results"
        static let hasSeenOnboardingKey = "has_seen_onboarding"
    }

    enum Disclaimer {
        static let measurementWarning = "AR measurements are approximate (±2–8 cm). Always verify with a tape measure before making a vehicle purchase."
    }
}
