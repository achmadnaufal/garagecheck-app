import SwiftUI

struct SavedResultsView: View {
    @EnvironmentObject var savedResultsService: SavedResultsService

    private var sortedResults: [FitResult] {
        savedResultsService.results.sorted { $0.checkedAt > $1.checkedAt }
    }

    var body: some View {
        Group {
            if savedResultsService.results.isEmpty {
                ContentUnavailableView(
                    "No Saved Results",
                    systemImage: "list.bullet.clipboard",
                    description: Text("Check a car fit from the Cars tab and save it.")
                )
            } else {
                List {
                    ForEach(sortedResults) { result in
                        resultRow(result: result)
                    }
                    .onDelete(perform: deleteResults)
                }
                .listStyle(.insetGrouped)
            }
        }
        .toolbar {
            if !savedResultsService.results.isEmpty {
                EditButton()
            }
        }
    }

    private func resultRow(result: FitResult) -> some View {
        HStack {
            Text(result.status.emoji)
                .font(.title2)
            VStack(alignment: .leading, spacing: 4) {
                Text(result.car.fullDisplayName)
                    .font(.headline)
                Text("in \(result.garage.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(result.summaryText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            Text(result.status.rawValue)
                .font(.caption2.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(result.status.color.opacity(0.15))
                .foregroundColor(result.status.color)
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }

    private func deleteResults(at offsets: IndexSet) {
        savedResultsService.delete(at: offsets, in: sortedResults)
    }
}
