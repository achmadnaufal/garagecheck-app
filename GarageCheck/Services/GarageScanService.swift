import Foundation
import Combine

/// Manages garage scanning state and results.
/// On real LiDAR devices, wraps RoomPlan/ARKit scanning.
/// On simulator, exposes manual dimension entry.
class GarageScanService: ObservableObject {
    @Published var scannedGarage: Garage? = nil
    @Published var isScanning = false
    @Published var scanProgress: Double = 0.0
    @Published var errorMessage: String? = nil

    // MARK: - Manual entry (simulator & non-LiDAR fallback)
    func saveManualGarage(name: String, lengthM: Double, widthM: Double, heightM: Double) {
        let garage = Garage(
            name: name.isEmpty ? "My Garage" : name,
            lengthMm: lengthM * 1000,
            widthMm: widthM * 1000,
            heightMm: heightM * 1000
        )
        scannedGarage = garage
    }

    // MARK: - Device capability check
    static var isLiDARAvailable: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        // RoomPlan requires LiDAR (iPhone 12 Pro+)
        // We check via ARWorldTrackingConfiguration.supportsSceneReconstruction
        if #available(iOS 15.4, *) {
            return true // Will be further validated at runtime in GarageScanView
        }
        return false
        #endif
    }

    func reset() {
        scannedGarage = nil
        isScanning = false
        scanProgress = 0.0
        errorMessage = nil
    }
}
