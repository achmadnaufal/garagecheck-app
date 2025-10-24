import SwiftUI

struct CarSelectionView: View {
    @EnvironmentObject var carDataService: CarDataService
    @EnvironmentObject var scanService: GarageScanService

    @State private var searchText = ""
    @State private var selectedCar: Car? = nil
    @State private var showFitCheck = false

    private var filteredCars: [Car] {
        carDataService.search(query: searchText)
    }

    var body: some View {
        Group {
            if carDataService.isLoading {
                ProgressView("Loading cars...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                carList
            }
        }
        .searchable(text: $searchText, prompt: "Search make or model")
        .sheet(item: $selectedCar) { car in
            if let garage = scanService.scannedGarage {
                FitCheckView(garage: garage, car: car)
            } else {
                noGarageSheet(car: car)
            }
        }
    }

    private var carList: some View {
        List {
            if filteredCars.isEmpty {
                ContentUnavailableView(
                    "No Cars Found",
                    systemImage: "car.fill",
                    description: Text("Try a different search term.")
                )
            } else {
                ForEach(carDataService.makes.filter { make in
                    filteredCars.contains { $0.make == make }
                }, id: \.self) { make in
                    Section(make) {
                        ForEach(filteredCars.filter { $0.make == make }) { car in
                            carRow(car: car)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func carRow(car: Car) -> some View {
        Button(action: { selectedCar = car }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(car.model)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(car.displayDimensions)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(car.segment)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    Text(String(car.year))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func noGarageSheet(car: Car) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "building.2")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            Text("No Garage Scanned")
                .font(.title2.bold())
            Text("Please scan or enter your garage dimensions first in the Garage tab, then check the fit for \(car.displayName).")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
            Button("OK") { selectedCar = nil }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct CarSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CarSelectionView()
                .navigationTitle("Select Car")
        }
        .environmentObject(CarDataService())
        .environmentObject(GarageScanService())
    }
}
