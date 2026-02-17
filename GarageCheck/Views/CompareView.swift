import SwiftUI

/// Side-by-side comparison of two cars against the active garage.
struct CompareView: View {
    @EnvironmentObject var scanService: GarageScanService
    @EnvironmentObject var carDataService: CarDataService

    @State private var carA: Car? = nil
    @State private var carB: Car? = nil
    @State private var pickingA = false
    @State private var pickingB = false

    var body: some View {
        ScrollView {
            if let garage = scanService.activeGarage {
                VStack(spacing: 16) {
                    garageHeader(garage)

                    HStack(alignment: .top, spacing: 12) {
                        carColumn(
                            label: "Car A",
                            car: $carA,
                            showPicker: $pickingA,
                            garage: garage
                        )
                        carColumn(
                            label: "Car B",
                            car: $carB,
                            showPicker: $pickingB,
                            garage: garage
                        )
                    }

                    if carA != nil && carB != nil {
                        disclaimerCard
                    }
                }
                .padding(Constants.UI.padding)
            } else {
                noGaragePrompt
                    .padding(Constants.UI.padding)
            }
        }
        .sheet(isPresented: $pickingA) {
            CarPickerSheet(selectedCar: $carA)
        }
        .sheet(isPresented: $pickingB) {
            CarPickerSheet(selectedCar: $carB)
        }
    }

    // MARK: - Garage Header

    private func garageHeader(_ garage: Garage) -> some View {
        HStack {
            Image(systemName: "building.2.fill")
                .foregroundColor(Constants.Colors.primary)
            VStack(alignment: .leading, spacing: 2) {
                Text(garage.name)
                    .font(.headline)
                Text(garage.displayDimensions)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(Constants.UI.padding)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(Constants.UI.cornerRadius)
    }

    // MARK: - Car Column

    private func carColumn(
        label: String,
        car: Binding<Car?>,
        showPicker: Binding<Bool>,
        garage: Garage
    ) -> some View {
        VStack(spacing: 8) {
            if let selectedCar = car.wrappedValue {
                let result = FitCalculationService.calculate(garage: garage, car: selectedCar)
                FitResultCard(result: result)
                Button("Change") { showPicker.wrappedValue = true }
                    .font(.caption)
                    .foregroundColor(Constants.Colors.primary)
            } else {
                emptyCarSlot(label: label, showPicker: showPicker)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func emptyCarSlot(label: String, showPicker: Binding<Bool>) -> some View {
        Button {
            showPicker.wrappedValue = true
        } label: {
            VStack(spacing: 10) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 36))
                    .foregroundColor(Constants.Colors.primary)
                Text(label)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Tap to select")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(Constants.UI.cornerRadius)
        }
        .buttonStyle(.plain)
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

    // MARK: - No Garage Prompt

    private var noGaragePrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            Text("No Active Garage")
                .font(.title3.bold())
            Text("Add and select a garage in the Garage tab to compare cars.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
    }
}

struct CompareView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CompareView()
                .navigationTitle("Compare")
        }
        .environmentObject(GarageScanService())
        .environmentObject(CarDataService())
    }
}
