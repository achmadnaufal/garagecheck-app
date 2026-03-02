import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var carDataService: CarDataService
    @EnvironmentObject var garageScanService: GarageScanService

    @State private var selectedTab = 0

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

            compareTab
                .tabItem {
                    Label("Compare", systemImage: "arrow.left.arrow.right.square.fill")
                }
                .tag(2)

            resultsTab
                .tabItem {
                    Label("Results", systemImage: "list.bullet.clipboard.fill")
                }
                .tag(3)
        }
    }

    // MARK: - Tabs

    private var garageTab: some View {
        NavigationStack {
            GarageListView()
                .navigationTitle("Garages")
                .navigationBarTitleDisplayMode(.large)
        }
    }

    private var carSelectionTab: some View {
        NavigationStack {
            CarSelectionView()
                .navigationTitle("Select Car")
                .navigationBarTitleDisplayMode(.large)
        }
    }

    private var compareTab: some View {
        NavigationStack {
            CompareView()
                .navigationTitle("Compare")
                .navigationBarTitleDisplayMode(.large)
        }
    }

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
            .environmentObject(SavedResultsService())
    }
}
