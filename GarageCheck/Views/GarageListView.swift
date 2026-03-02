import SwiftUI

/// Lists all saved garages; lets the user set the active one, add new ones, edit, or delete.
struct GarageListView: View {
    @EnvironmentObject var scanService: GarageScanService

    @State private var showAddGarage = false
    @State private var editingGarage: Garage? = nil
    @State private var garageToDelete: Garage? = nil
    @State private var showDeleteConfirm = false

    var body: some View {
        List {
            if !scanService.garages.isEmpty {
                Section {
                    ForEach(scanService.garages) { garage in
                        garageRow(garage)
                    }
                } header: {
                    Text("Tap a garage to make it active")
                }
            }

            Section {
                Button {
                    showAddGarage = true
                } label: {
                    Label("Add New Garage", systemImage: "plus.circle.fill")
                        .foregroundColor(Constants.Colors.primary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if scanService.garages.isEmpty {
                emptyState
            }
        }
        .sheet(isPresented: $showAddGarage) {
            NavigationStack {
                GarageScanView()
            }
        }
        .sheet(item: $editingGarage) { garage in
            GarageEditSheet(garage: garage)
        }
        .confirmationDialog(
            "Delete Garage",
            isPresented: $showDeleteConfirm,
            presenting: garageToDelete
        ) { garage in
            Button("Delete \"\(garage.name)\"", role: .destructive) {
                scanService.deleteGarage(id: garage.id)
            }
        } message: { garage in
            Text(garage.displayDimensions)
        }
    }

    // MARK: - Garage Row

    private func garageRow(_ garage: Garage) -> some View {
        HStack(spacing: 12) {
            Image(systemName: scanService.activeGarageID == garage.id
                  ? "checkmark.circle.fill"
                  : "circle")
                .foregroundColor(scanService.activeGarageID == garage.id
                                 ? .green : .secondary)
                .font(.title3)

            VStack(alignment: .leading, spacing: 3) {
                Text(garage.name)
                    .font(.headline)
                Text(garage.displayDimensions)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if scanService.activeGarageID == garage.id {
                Text("Active")
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.green.opacity(0.15))
                    .foregroundColor(.green)
                    .cornerRadius(8)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            scanService.setActiveGarage(id: garage.id)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                garageToDelete = garage
                showDeleteConfirm = true
            } label: {
                Label("Delete", systemImage: "trash")
            }

            Button {
                editingGarage = garage
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            Text("No Garages Yet")
                .font(.title3.bold())
            Text("Add your first garage to start checking car fitment.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Add Garage") {
                showAddGarage = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
    }
}

struct GarageListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GarageListView()
                .navigationTitle("Garages")
        }
        .environmentObject(GarageScanService())
    }
}
