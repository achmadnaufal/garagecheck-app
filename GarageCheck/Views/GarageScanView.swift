import SwiftUI
import ARKit

/// Presented as a sheet when the user wants to add a new garage.
/// Supports both manual dimension entry and (on LiDAR devices) AR scanning.
struct GarageScanView: View {
    @EnvironmentObject var scanService: GarageScanService
    @Environment(\.dismiss) private var dismiss

    @State private var garageName = ""
    @State private var lengthText = ""
    @State private var widthText = ""
    @State private var heightText = ""

    @State private var showRoomCapture = false
    @State private var showScanNamingAlert = false
    @State private var pendingScanName = ""
    @State private var pendingLengthMm: Double = 0
    @State private var pendingWidthMm: Double = 0
    @State private var pendingHeightMm: Double = 0
    @State private var showScanError = false
    @State private var scanErrorMessage = ""

    // MARK: - Body

    var body: some View {
        Form {
            Section("Garage Name") {
                TextField("e.g. Rumah Depok", text: $garageName)
            }

            Section("Dimensions (in meters)") {
                dimensionField(label: "Length (front-to-back)", placeholder: "e.g. 5.0", text: $lengthText)
                dimensionField(label: "Width (side-to-side)", placeholder: "e.g. 2.6", text: $widthText)
                dimensionField(label: "Height (floor-to-ceiling)", placeholder: "e.g. 2.4", text: $heightText)
            }

            #if !targetEnvironment(simulator)
            if GarageScanService.isLiDARAvailable {
                Section {
                    Button {
                        showRoomCapture = true
                    } label: {
                        Label("Scan with LiDAR instead", systemImage: "camera.viewfinder")
                    }
                }
            }
            #else
            Section {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("Simulator: AR scanning unavailable.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            #endif

            Section {
                Text("Typical Depok developer garage: 2.4–2.6 m wide × 4.5–5.0 m long × 2.2–2.4 m tall")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Add Garage")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { saveAndDismiss() }
                    .disabled(!isFormValid)
            }
        }
        #if !targetEnvironment(simulator)
        .fullScreenCover(isPresented: $showRoomCapture) {
            roomCaptureFullScreen
        }
        #endif
        .alert("Name Your Garage", isPresented: $showScanNamingAlert) {
            TextField("e.g. Rumah Depok", text: $pendingScanName)
            Button("Save") {
                scanService.saveScannedGarage(
                    name: pendingScanName,
                    lengthMm: pendingLengthMm,
                    widthMm: pendingWidthMm,
                    heightMm: pendingHeightMm
                )
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(String(format: "Scanned: %.1fm × %.1fm × %.1fm",
                        pendingLengthMm / 1000, pendingWidthMm / 1000, pendingHeightMm / 1000))
        }
        .alert("Scan Error", isPresented: $showScanError) {
            Button("Try Again") { showRoomCapture = true }
            Button("Enter Manually", role: .cancel) {}
        } message: {
            Text(scanErrorMessage)
        }
    }

    // MARK: - Subviews

    private func dimensionField(label: String, placeholder: String, text: Binding<String>) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField(placeholder, text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            Text("m").foregroundColor(.secondary)
        }
    }

    // MARK: - RoomCapture Full Screen (real device only)
    #if !targetEnvironment(simulator)
    private var roomCaptureFullScreen: some View {
        RoomCaptureRepresentable(
            onScanComplete: { lengthMm, widthMm, heightMm in
                pendingLengthMm = lengthMm
                pendingWidthMm = widthMm
                pendingHeightMm = heightMm
                pendingScanName = ""
                showRoomCapture = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    showScanNamingAlert = true
                }
            },
            onCancel: {
                showRoomCapture = false
            },
            onError: { message in
                showRoomCapture = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    scanErrorMessage = message
                    showScanError = true
                }
            }
        )
        .ignoresSafeArea()
    }
    #endif

    // MARK: - Helpers

    private var isFormValid: Bool {
        guard let l = Double(lengthText), let w = Double(widthText), let h = Double(heightText) else { return false }
        return l > 0 && w > 0 && h > 0
    }

    private func saveAndDismiss() {
        guard let l = Double(lengthText),
              let w = Double(widthText),
              let h = Double(heightText) else { return }
        scanService.saveManualGarage(name: garageName, lengthM: l, widthM: w, heightM: h)
        dismiss()
    }
}

struct GarageScanView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GarageScanView()
        }
        .environmentObject(GarageScanService())
    }
}
