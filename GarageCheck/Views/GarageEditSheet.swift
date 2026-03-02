import SwiftUI

/// Sheet for editing the name and dimensions of an existing garage.
struct GarageEditSheet: View {
    @EnvironmentObject var scanService: GarageScanService
    @Environment(\.dismiss) private var dismiss

    let garage: Garage

    @State private var name: String
    @State private var lengthText: String
    @State private var widthText: String
    @State private var heightText: String

    init(garage: Garage) {
        self.garage = garage
        _name = State(initialValue: garage.name)
        _lengthText = State(initialValue: String(format: "%.2f", garage.lengthM))
        _widthText = State(initialValue: String(format: "%.2f", garage.widthM))
        _heightText = State(initialValue: String(format: "%.2f", garage.heightM))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Garage Name") {
                    TextField("e.g. Rumah Depok", text: $name)
                }

                Section("Dimensions (in meters)") {
                    dimensionField(label: "Length (front-to-back)", text: $lengthText)
                    dimensionField(label: "Width (side-to-side)", text: $widthText)
                    dimensionField(label: "Height (floor-to-ceiling)", text: $heightText)
                }

                Section {
                    Text("Typical Depok developer garage: 2.4–2.6 m wide × 4.5–5.0 m long × 2.2–2.4 m tall")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Edit Garage")
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
        }
    }

    // MARK: - Helpers

    private func dimensionField(label: String, text: Binding<String>) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0.0", text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            Text("m").foregroundColor(.secondary)
        }
    }

    private var isFormValid: Bool {
        guard let l = Double(lengthText), let w = Double(widthText), let h = Double(heightText) else { return false }
        return l > 0 && w > 0 && h > 0
    }

    private func saveAndDismiss() {
        guard let l = Double(lengthText),
              let w = Double(widthText),
              let h = Double(heightText) else { return }
        scanService.saveManualGarage(name: name, lengthM: l, widthM: w, heightM: h, existingID: garage.id)
        dismiss()
    }
}
