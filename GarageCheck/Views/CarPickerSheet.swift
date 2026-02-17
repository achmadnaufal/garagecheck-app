import SwiftUI

/// Reusable car picker presented as a sheet — used by CompareView.
struct CarPickerSheet: View {
    @EnvironmentObject var carDataService: CarDataService
    @Binding var selectedCar: Car?
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""

    private var filteredCars: [Car] {
        carDataService.search(query: searchText)
    }

    var body: some View {
        NavigationStack {
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
                                Button {
                                    selectedCar = car
                                    dismiss()
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(car.model)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Text("\(car.segment) · \(car.year)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        if selectedCar?.id == car.id {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "Search make or model")
            .navigationTitle("Select Car")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
