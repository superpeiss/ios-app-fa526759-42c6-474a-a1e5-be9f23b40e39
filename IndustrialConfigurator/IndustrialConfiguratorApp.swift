import SwiftUI

@main
struct IndustrialConfiguratorApp: App {
    @StateObject private var quoteManager = QuoteManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(quoteManager)
        }
    }
}
