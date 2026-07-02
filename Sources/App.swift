import SwiftUI
import AppFactoryKit

// Plant ID — payments via native StoreKit 2 (no third-party SDK).
private enum Product {
    static let yearly = "plantid_pro_yearly"
    static let weekly = "plantid_pro_weekly"
}

@MainActor
enum PlantIDFactory {
    static func make() -> AppFactory {
        let config = AppFactoryConfiguration(
            appName: "Plant ID",
            purchaseProvider: StoreKit2PurchaseProvider(productIDs: [Product.yearly, Product.weekly]),
            onboarding: OnboardingConfiguration(
                slides: [
                    .init(systemImage: "leaf.fill",
                          title: "What Plant Is That?",
                          message: "Snap a photo and identify it instantly — right on your device."),
                    .init(systemImage: "drop.fill",
                          title: "Keep It Alive",
                          message: "Get watering, light and soil tips matched to what you find.")
                ],
                presentsPaywallOnFinish: true,
                accent: .green
            ),
            paywall: PaywallConfiguration(
                headline: "Unlock Plant ID Pro",
                subheadline: "Identify everything, care for anything.",
                benefits: [
                    .init(systemImage: "infinity", title: "Unlimited identifications"),
                    .init(systemImage: "list.bullet.rectangle", title: "See all matches"),
                    .init(systemImage: "drop.fill", title: "Full care guides"),
                    .init(systemImage: "nosign", title: "No ads")
                ],
                productIDs: [Product.yearly, Product.weekly],
                highlightedProductID: Product.yearly,
                ctaTitle: "Continue",
                dismissButtonDelay: 4,
                isDismissable: true,
                termsURL: URL(string: "https://zubeidhendricks.github.io/PlantIdentifierCare/terms.html"),
                privacyURL: URL(string: "https://zubeidhendricks.github.io/PlantIdentifierCare/privacy.html"),
                style: PaywallStyle(accent: .green, heroSystemImage: "leaf.circle")
            )
        )
        return AppFactory(config)
    }
}

@main
struct PlantIDApp: App {
    @StateObject private var factory = PlantIDFactory.make()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .appFactoryRoot(factory)
                .tint(.green)
        }
    }
}
