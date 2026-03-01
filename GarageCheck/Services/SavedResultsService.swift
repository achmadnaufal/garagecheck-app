import Foundation
import Combine

/// ObservableObject that owns the saved fit results list.
/// Inject via @EnvironmentObject so SavedResultsView and FitCheckView
/// stay in sync — saving in FitCheckView immediately updates SavedResultsView.
class SavedResultsService: ObservableObject {
    @Published var results: [FitResult] = []

    private let storageKey = Constants.Storage.savedResultsKey

    init() {
        load()
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([FitResult].self, from: data) else { return }
        results = decoded
    }

    func save(result: FitResult) {
        results.append(result)
        persist()
    }

    func delete(at offsets: IndexSet, in sorted: [FitResult]) {
        var mutable = sorted
        mutable.remove(atOffsets: offsets)
        // Rebuild full list: keep any items not in sorted, plus remaining from sorted
        let sortedIds = Set(sorted.map(\.id))
        let unsorted = results.filter { !sortedIds.contains($0.id) }
        results = unsorted + mutable
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(results) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
