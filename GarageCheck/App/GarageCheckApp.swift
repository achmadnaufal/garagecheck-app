import SwiftUI

@main
struct GarageCheckApp: App {
    @StateObject private var carDataService = CarDataService()
    @StateObject private var garageScanService = GarageScanService()
    @StateObject private var savedResultsService = SavedResultsService()
    @AppStorage(Constants.Storage.hasSeenOnboardingKey) private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                DashboardView()
                    .environmentObject(carDataService)
                    .environmentObject(garageScanService)
                    .environmentObject(savedResultsService)
            } else {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                    .environmentObject(carDataService)
                    .environmentObject(garageScanService)
                    .environmentObject(savedResultsService)
            }
        }
    }
}
