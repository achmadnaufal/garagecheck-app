import SwiftUI
import ARKit

struct GarageScanView: View {
    @EnvironmentObject var scanService: GarageScanService

    @State private var showManualEntry = false
    @State private var garageName = ""
    @State private var lengthText = ""
    @State private var widthText = ""
    @State private var heightText = ""
    @State private var showSavedConfirmation = false

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Current garage display
                if let garage = scanService.scannedGarage {
                    savedGarageCard(garage: garage)
                } else {
                    emptyGaragePrompt
                }

                // Action buttons
                scanActionButtons

                Divider()

                // Disclaimer
                disclaimerView
            }
            .padding(Constants.UI.padding)
        }
        .sheet(isPresented: $showManualEntry) {
            manualEntrySheet
        }
        .overlay(
            savedConfirmationBanner
                .animation(.easeInOut, value: showSavedConfirmation)
        )
    }

    // MARK: - Subviews

    private var emptyGaragePrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            Text("No Garage Scanned Yet")
                .font(.title3.bold())
            Text("Scan your garage or enter dimensions manually to get started.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
    }

    private func savedGarageCard(garage: Garage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "building.2.fill")
                    .foregroundColor(Constants.Colors.primary)
                Text(garage.name)
                    .font(.headline)
                Spacer()
                Button("Edit") { showManualEntry = true }
                    .font(.caption)
            }
            Divider()
            HStack(spacing: 0) {
                dimensionItem(label: "Length", value: garage.lengthM, unit: "m")
                Divider().frame(height: 40)
                dimensionItem(label: "Width", value: garage.widthM, unit: "m")
                Divider().frame(height: 40)
                dimensionItem(label: "Height", value: garage.heightM, unit: "m")
            }
        }
        .padding(Constants.UI.padding)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
    }

    private func dimensionItem(label: String, value: Double, unit: String) -> some View {
        VStack(spacing: 4) {
            Text(String(format: "%.1f%@", value, unit))
                .font(.title3.bold())
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var scanActionButtons: some View {
        VStack(spacing: 12) {
            #if targetEnvironment(simulator)
            simulatorNotice
            #else
            if GarageScanService.isLiDARAvailable {
                lidarScanButton
            }
            #endif

            Button(action: {
                if let garage = scanService.scannedGarage {
                    garageName = garage.name
                    lengthText = String(format: "%.2f", garage.lengthM)
                    widthText = String(format: "%.2f", garage.widthM)
                    heightText = String(format: "%.2f", garage.heightM)
                }
                showManualEntry = true
            }) {
                Label("Enter Dimensions Manually", systemImage: "keyboard")
                    .font(.headline)
                    .foregroundColor(Constants.Colors.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Constants.Colors.primary.opacity(0.1))
                    .cornerRadius(Constants.UI.cornerRadius)
            }
        }
    }

    private var simulatorNotice: some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundColor(.blue)
            Text("Running on Simulator — AR scanning unavailable. Use manual entry.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
    }

    private var lidarScanButton: some View {
        Button(action: {
            // TODO: Launch RoomPlan scanning in a full-screen cover
        }) {
            Label("Scan with LiDAR", systemImage: "camera.viewfinder")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Constants.Colors.primary)
                .cornerRadius(Constants.UI.cornerRadius)
        }
    }

    // MARK: - Manual Entry Sheet

    private var manualEntrySheet: some View {
        NavigationStack {
            Form {
                Section("Garage Name") {
                    TextField("e.g. Rumah Depok", text: $garageName)
                }
                Section("Dimensions (in meters)") {
                    HStack {
                        Text("Length (front-to-back)")
                        Spacer()
                        TextField("e.g. 5.0", text: $lengthText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("m").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Width (side-to-side)")
                        Spacer()
                        TextField("e.g. 2.6", text: $widthText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("m").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Height (floor-to-ceiling)")
                        Spacer()
                        TextField("e.g. 2.4", text: $heightText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("m").foregroundColor(.secondary)
                    }
                }
                Section {
                    Text("Typical Depok developer garage: 2.4–2.6 m wide × 4.5–5.0 m long × 2.2–2.4 m tall")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Garage Dimensions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showManualEntry = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveManualDimensions()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }

    private var isFormValid: Bool {
        guard let l = Double(lengthText), let w = Double(widthText), let h = Double(heightText) else { return false }
        return l > 0 && w > 0 && h > 0
    }

    private func saveManualDimensions() {
        guard let l = Double(lengthText),
              let w = Double(widthText),
              let h = Double(heightText) else { return }
        scanService.saveManualGarage(name: garageName, lengthM: l, widthM: w, heightM: h)
        showManualEntry = false
        showSavedConfirmation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showSavedConfirmation = false
        }
    }

    private var disclaimerView: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.orange)
                .font(.caption)
            Text(Constants.Disclaimer.measurementWarning)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
    }

    @ViewBuilder
    private var savedConfirmationBanner: some View {
        if showSavedConfirmation {
            VStack {
                Spacer()
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Garage saved!")
                        .font(.subheadline.bold())
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(Constants.UI.cornerRadius)
                .padding(.bottom, 100)
            }
        }
    }
}

struct GarageScanView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GarageScanView()
                .navigationTitle("My Garage")
        }
        .environmentObject(GarageScanService())
    }
}
