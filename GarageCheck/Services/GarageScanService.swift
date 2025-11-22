import Foundation
import ARKit
import Combine

/// Manages garage scanning state and results.
/// On real LiDAR devices, wraps RoomPlan/ARKit scanning.
/// On simulator, exposes manual dimension entry.
class GarageScanService: ObservableObject {
    @Published var scannedGarage: Garage? = nil {
        didSet { persistGarage() }
    }
    @Published var isScanning = false
    @Published var scanProgress: Double = 0.0
    @Published var errorMessage: String? = nil

    private let garageKey = Constants.Storage.savedGaragesKey

    init() {
        loadPersistedGarage()
    }

    // MARK: - Persistence

    private func loadPersistedGarage() {
        guard let data = UserDefaults.standard.data(forKey: garageKey),
              let garage = try? JSONDecoder().decode(Garage.self, from: data) else { return }
        scannedGarage = garage
    }

    private func persistGarage() {
        if let garage = scannedGarage,
           let data = try? JSONEncoder().encode(garage) {
            UserDefaults.standard.set(data, forKey: garageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: garageKey)
        }
    }

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

    // MARK: - RoomPlan result ingestion
    /// Called when a real RoomPlan scan completes on a LiDAR device.
    func saveScannedGarage(name: String, lengthMm: Double, widthMm: Double, heightMm: Double) {
        let garage = Garage(
            name: name.isEmpty ? "Scanned Garage" : name,
            lengthMm: lengthMm,
            widthMm: widthMm,
            heightMm: heightMm
        )
        scannedGarage = garage
    }

    // MARK: - Device capability check
    static var isLiDARAvailable: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        // RoomPlan requires LiDAR. Confirmed via ARWorldTrackingConfiguration.
        if #available(iOS 16.0, *) {
            return ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
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
