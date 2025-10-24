import SwiftUI

@main
struct GarageCheckApp: App {
    @StateObject private var carDataService = CarDataService()
    @StateObject private var garageScanService = GarageScanService()
    @AppStorage(Constants.Storage.hasSeenOnboardingKey) private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                DashboardView()
                    .environmentObject(carDataService)
                    .environmentObject(garageScanService)
            } else {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                    .environmentObject(carDataService)
                    .environmentObject(garageScanService)
            }
        }
    }
}
