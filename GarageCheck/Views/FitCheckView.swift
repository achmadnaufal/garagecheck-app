import SwiftUI

struct FitCheckView: View {
    let garage: Garage
    let car: Car

    @EnvironmentObject var savedResultsService: SavedResultsService
    @Environment(\.dismiss) private var dismiss

    @State private var savedResult = false
    @State private var mirrorsExtended = false
    @State private var shareImage: Image? = nil
    @State private var isSharing = false

    private var result: FitResult {
        FitCalculationService.calculate(garage: garage, car: car, mirrorsExtended: mirrorsExtended)
    }

    private var effectiveWidth: Double {
        if mirrorsExtended, let ext = car.mirrorWidthExtendedMm { return ext }
        if !mirrorsExtended, let fld = car.mirrorWidthFoldedMm { return fld }
        return car.widthMm
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    resultBadge
                    if car.mirrorWidthFoldedMm != nil || car.mirrorWidthExtendedMm != nil {
                        mirrorToggleCard
                    }
                    summaryCard
                    marginsCard
                    dimensionsComparisonCard
                    disclaimerCard
                }
                .padding(Constants.UI.padding)
            }
            .navigationTitle("Fit Check")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItemGroup(placement: .primaryAction) {
                    shareButton
                    saveButton
                }
            }
        }
    }

    // MARK: - Toolbar Buttons

    private var saveButton: some View {
        Button(action: saveResult) {
            Image(systemName: savedResult ? "checkmark" : "square.and.arrow.down")
        }
        .disabled(savedResult)
    }

    private var shareButton: some View {
        Button {
            renderAndShare()
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
    }

    // MARK: - Result Badge

    private var resultBadge: some View {
        VStack(spacing: 12) {
            Text(result.status.emoji)
                .font(.system(size: 72))
            Text(result.status.rawValue)
                .font(.title.bold())
                .foregroundColor(result.status.color)
            Text(result.car.fullDisplayName)
                .font(.headline)
                .foregroundColor(.secondary)
            Text("in \(result.garage.name)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(result.status.color.opacity(0.1))
        .cornerRadius(Constants.UI.cornerRadius)
    }

    // MARK: - Mirror Toggle

    private var mirrorToggleCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Side Mirror Width")
                .font(.headline)
            Picker("Mirror position", selection: $mirrorsExtended) {
                Text("Folded").tag(false)
                Text("Extended").tag(true)
            }
            .pickerStyle(.segmented)
            Text(mirrorsExtended
                 ? "Width includes extended mirrors (\(Int(effectiveWidth)) mm)"
                 : "Width uses folded mirrors (\(Int(effectiveWidth)) mm)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(Constants.UI.padding)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
    }

    // MARK: - Summary

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Summary")
                .font(.headline)
            Text(result.summaryText)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.UI.padding)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
    }

    // MARK: - Margins

    private var marginsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Clearance")
                .font(.headline)

            VStack(spacing: 8) {
                marginRow(
                    label: "Width (total)",
                    valueMm: result.widthMarginMm,
                    note: String(format: "%.0f cm per side", result.widthMarginMm / 20)
                )
                Divider()
                marginRow(
                    label: "Length (total)",
                    valueMm: result.lengthMarginMm,
                    note: String(format: "%.0f cm per side", result.lengthMarginMm / 20)
                )
                Divider()
                marginRow(
                    label: "Height",
                    valueMm: result.heightMarginMm,
                    note: result.heightMarginMm < 0 ? "Exceeds ceiling!" : "Clearance above car"
                )
            }
        }
        .padding(Constants.UI.padding)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
    }

    private func marginRow(label: String, valueMm: Double, note: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline)
                Text(note)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(valueMm < 0
                    ? String(format: "-%.0f mm", abs(valueMm))
                    : String(format: "+%.0f mm", valueMm))
                    .font(.headline)
                    .foregroundColor(colorForMargin(valueMm))
                Text(valueMm < 0
                    ? String(format: "-%.1f cm", abs(valueMm) / 10)
                    : String(format: "+%.1f cm", valueMm / 10))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func colorForMargin(_ mm: Double) -> Color {
        if mm < 0 { return .red }
        if mm < Constants.Fit.tightThreshold { return .red }
        if mm < Constants.Fit.comfortableThreshold { return .orange }
        return .green
    }

    // MARK: - Dimensions Comparison

    private var dimensionsComparisonCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dimensions Compared")
                .font(.headline)
            HStack {
                Text("")
                    .frame(width: 80, alignment: .leading)
                    .font(.caption.bold())
                Spacer()
                Text("Garage")
                    .font(.caption.bold())
                    .frame(width: 80, alignment: .trailing)
                Text("Car")
                    .font(.caption.bold())
                    .frame(width: 80, alignment: .trailing)
            }
            .foregroundColor(.secondary)

            Divider()
            comparisonRow(label: "Length", garageMm: garage.lengthMm, carMm: car.lengthMm)
            Divider()
            comparisonRow(label: "Width", garageMm: garage.widthMm, carMm: effectiveWidth)
            Divider()
            comparisonRow(label: "Height", garageMm: garage.heightMm, carMm: car.heightMm)
        }
        .padding(Constants.UI.padding)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
    }

    private func comparisonRow(label: String, garageMm: Double, carMm: Double) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)
            Spacer()
            Text(String(format: "%.0fmm", garageMm))
                .font(.subheadline)
                .frame(width: 80, alignment: .trailing)
            Text(String(format: "%.0fmm", carMm))
                .font(.subheadline)
                .foregroundColor(carMm > garageMm ? .red : .primary)
                .frame(width: 80, alignment: .trailing)
        }
    }

    // MARK: - Disclaimer

    private var disclaimerCard: some View {
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

    // MARK: - Share as Image

    @MainActor
    private func renderAndShare() {
        let renderer = ImageRenderer(content: shareCard)
        renderer.scale = 3
        guard let uiImage = renderer.uiImage else { return }
        let activityVC = UIActivityViewController(
            activityItems: [uiImage],
            applicationActivities: nil
        )
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }

    /// Compact card rendered to image for sharing
    private var shareCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "car.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("GarageCheck")
                    .font(.headline)
                    .foregroundColor(.blue)
            }

            Text(result.status.emoji)
                .font(.system(size: 56))
            Text(result.status.rawValue)
                .font(.title2.bold())
                .foregroundColor(result.status.color)
            Text(result.car.fullDisplayName)
                .font(.headline)
            Text("in \(result.garage.name)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Divider()

            VStack(spacing: 6) {
                shareMarginRow(label: "Width", valueMm: result.widthMarginMm)
                shareMarginRow(label: "Length", valueMm: result.lengthMarginMm)
                shareMarginRow(label: "Height", valueMm: result.heightMarginMm)
            }
            .font(.subheadline)

            Text(Constants.Disclaimer.measurementWarning)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(width: 320)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 8)
    }

    private func shareMarginRow(label: String, valueMm: Double) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(valueMm < 0
                 ? String(format: "-%.0fmm", abs(valueMm))
                 : String(format: "+%.0fmm", valueMm))
                .foregroundColor(colorForMargin(valueMm))
                .bold()
        }
    }

    // MARK: - Save

    private func saveResult() {
        savedResultsService.save(result: result)
        savedResult = true
    }
}

struct FitCheckView_Previews: PreviewProvider {
    static var previews: some View {
        FitCheckView(garage: Garage.example, car: Car.example)
            .environmentObject(SavedResultsService())
    }
}
