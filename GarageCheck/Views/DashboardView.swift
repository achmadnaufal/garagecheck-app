import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var carDataService: CarDataService
    @EnvironmentObject var garageScanService: GarageScanService

    @State private var selectedTab = 0
    @AppStorage(Constants.Storage.savedResultsKey) private var savedResultsData: Data = Data()

    var body: some View {
        TabView(selection: $selectedTab) {
            garageTab
                .tabItem {
                    Label("Garage", systemImage: "building.2.fill")
                }
                .tag(0)

            carSelectionTab
                .tabItem {
                    Label("Cars", systemImage: "car.2.fill")
                }
                .tag(1)

            resultsTab
                .tabItem {
                    Label("Results", systemImage: "list.bullet.clipboard.fill")
                }
                .tag(2)
        }
    }

    // MARK: - Garage Tab
    private var garageTab: some View {
        NavigationStack {
            GarageScanView()
                .navigationTitle("My Garage")
                .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Cars Tab
    private var carSelectionTab: some View {
        NavigationStack {
            CarSelectionView()
                .navigationTitle("Select Car")
                .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Results Tab
    private var resultsTab: some View {
        NavigationStack {
            SavedResultsView()
                .navigationTitle("Results")
                .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(CarDataService())
            .environmentObject(GarageScanService())
    }
}
