import SwiftUI

struct SavedResultsView: View {
    @State private var results: [FitResult] = []

    var body: some View {
        Group {
            if results.isEmpty {
                ContentUnavailableView(
                    "No Saved Results",
                    systemImage: "list.bullet.clipboard",
                    description: Text("Check a car fit from the Cars tab and save it.")
                )
            } else {
                List {
                    ForEach(results.sorted { $0.checkedAt > $1.checkedAt }) { result in
                        resultRow(result: result)
                    }
                    .onDelete(perform: deleteResults)
                }
                .listStyle(.insetGrouped)
            }
        }
        .onAppear(perform: loadResults)
        .toolbar {
            if !results.isEmpty {
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

    private func loadResults() {
        guard let data = UserDefaults.standard.data(forKey: Constants.Storage.savedResultsKey),
              let decoded = try? JSONDecoder().decode([FitResult].self, from: data) else { return }
        results = decoded
    }

    private func deleteResults(at offsets: IndexSet) {
        let sorted = results.sorted { $0.checkedAt > $1.checkedAt }
        var mutable = sorted
        mutable.remove(atOffsets: offsets)
        results = mutable
        if let data = try? JSONEncoder().encode(results) {
            UserDefaults.standard.set(data, forKey: Constants.Storage.savedResultsKey)
        }
    }
}
