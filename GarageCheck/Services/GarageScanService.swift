import Foundation
import ARKit
import Combine

/// Manages multiple named garage profiles and the currently active one.
class GarageScanService: ObservableObject {
    @Published var garages: [Garage] = [] {
        didSet { persistGarages() }
    }
    @Published var activeGarageID: UUID? {
        didSet { persistActiveID() }
    }
    @Published var isScanning = false
    @Published var scanProgress: Double = 0.0
    @Published var errorMessage: String? = nil

    private let garagesKey = Constants.Storage.savedGaragesKey
    private let activeIDKey = Constants.Storage.activeGarageIDKey

    /// The currently selected garage (nil if none saved yet).
    var activeGarage: Garage? {
        guard let id = activeGarageID else { return garages.first }
        return garages.first { $0.id == id }
    }

    /// Backward-compatible alias used throughout existing views.
    var scannedGarage: Garage? { activeGarage }

    init() {
        loadPersisted()
    }

    // MARK: - Persistence

    private func loadPersisted() {
        if let data = UserDefaults.standard.data(forKey: garagesKey) {
            if let list = try? JSONDecoder().decode([Garage].self, from: data) {
                garages = list
            } else if let single = try? JSONDecoder().decode(Garage.self, from: data) {
                // Migrate from single-garage storage format
                garages = [single]
            }
        }
        if let idString = UserDefaults.standard.string(forKey: activeIDKey),
           let id = UUID(uuidString: idString),
           garages.contains(where: { $0.id == id }) {
            activeGarageID = id
        } else {
            activeGarageID = garages.first?.id
        }
    }

    private func persistGarages() {
        if let data = try? JSONEncoder().encode(garages) {
            UserDefaults.standard.set(data, forKey: garagesKey)
        }
    }

    private func persistActiveID() {
        if let id = activeGarageID {
            UserDefaults.standard.set(id.uuidString, forKey: activeIDKey)
        } else {
            UserDefaults.standard.removeObject(forKey: activeIDKey)
        }
    }

    // MARK: - Garage CRUD

    func addGarage(_ garage: Garage) {
        garages = garages + [garage]
    }

    func setActiveGarage(id: UUID) {
        activeGarageID = id
    }

    func deleteGarage(id: UUID) {
        garages = garages.filter { $0.id != id }
        if activeGarageID == id {
            activeGarageID = garages.first?.id
        }
    }

    func updateGarage(_ updated: Garage) {
        garages = garages.map { $0.id == updated.id ? updated : $0 }
    }

    // MARK: - Manual Entry (simulator & non-LiDAR fallback)

    /// Saves a garage from manual dimension input.
    /// When `existingID` is provided the garage is updated in place; otherwise a new one is added and made active.
    func saveManualGarage(
        name: String,
        lengthM: Double,
        widthM: Double,
        heightM: Double,
        existingID: UUID? = nil
    ) {
        let garage = Garage(
            id: existingID ?? UUID(),
            name: name.isEmpty ? "My Garage" : name,
            lengthMm: lengthM * 1000,
            widthMm: widthM * 1000,
            heightMm: heightM * 1000
        )
        if existingID != nil {
            updateGarage(garage)
        } else {
            addGarage(garage)
            activeGarageID = garage.id
        }
    }

    // MARK: - RoomPlan Result Ingestion

    /// Called when a real RoomPlan scan completes on a LiDAR device.
    func saveScannedGarage(name: String, lengthMm: Double, widthMm: Double, heightMm: Double) {
        let garage = Garage(
            name: name.isEmpty ? "Scanned Garage" : name,
            lengthMm: lengthMm,
            widthMm: widthMm,
            heightMm: heightMm
        )
        addGarage(garage)
        activeGarageID = garage.id
    }

    // MARK: - Device Capability Check

    static var isLiDARAvailable: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        if #available(iOS 16.0, *) {
            return ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
        }
        return false
        #endif
    }

    func reset() {
        isScanning = false
        scanProgress = 0.0
        errorMessage = nil
    }
}
