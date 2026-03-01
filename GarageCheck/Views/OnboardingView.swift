import SwiftUI

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "camera.viewfinder",
            title: "Scan Your Garage",
            description: "Point your iPhone at your garage floor and walls. The app uses AR to measure your space accurately."
        ),
        OnboardingPage(
            icon: "car.fill",
            title: "Pick a Car",
            description: "Browse our database of top Indonesian market cars with real dimensions. Or enter your own measurements."
        ),
        OnboardingPage(
            icon: "checkmark.seal.fill",
            title: "Get Your Answer",
            description: "See exactly how much clearance you have on each side. Green means comfortable, orange means tight, red means it won't fit."
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    pageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            bottomButton
                .padding(.horizontal, Constants.UI.largePadding)
                .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
    }

    private func pageView(page: OnboardingPage) -> some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(Constants.Colors.primary)
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
            Spacer()
        }
    }

    private var bottomButton: some View {
        Button(action: {
            if currentPage < pages.count - 1 {
                withAnimation { currentPage += 1 }
            } else {
                hasSeenOnboarding = true
            }
        }) {
            Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Constants.Colors.primary)
                .cornerRadius(Constants.UI.cornerRadius)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasSeenOnboarding: .constant(false))
    }
}
