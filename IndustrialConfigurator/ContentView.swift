import SwiftUI

struct ContentView: View {
    @StateObject private var configuratorViewModel = ConfiguratorViewModel()
    @EnvironmentObject var quoteManager: QuoteManager
    @State private var showingSavedQuotes = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress indicator
                ProgressBar(currentStep: configuratorViewModel.currentStep, totalSteps: 4)
                    .padding()

                // Main content area
                TabView(selection: $configuratorViewModel.currentStep) {
                    BaseComponentSelectionView(viewModel: configuratorViewModel)
                        .tag(0)

                    CompatiblePartsSelectionView(viewModel: configuratorViewModel)
                        .tag(1)

                    Preview3DView(viewModel: configuratorViewModel)
                        .tag(2)

                    QuoteSummaryView(viewModel: configuratorViewModel)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .disabled(true) // Disable swipe, use buttons instead

                // Navigation buttons
                HStack {
                    if configuratorViewModel.currentStep > 0 {
                        Button(action: {
                            withAnimation {
                                configuratorViewModel.previousStep()
                            }
                        }) {
                            Label("Previous", systemImage: "chevron.left")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }

                    Spacer()

                    if configuratorViewModel.currentStep < 3 {
                        Button(action: {
                            withAnimation {
                                configuratorViewModel.nextStep()
                            }
                        }) {
                            Label("Next", systemImage: "chevron.right")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!configuratorViewModel.canProceedToNextStep())
                    }
                }
                .padding()
            }
            .navigationTitle("Component Configurator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSavedQuotes = true
                    }) {
                        Image(systemName: "doc.text.magnifyingglass")
                    }
                }
            }
            .sheet(isPresented: $showingSavedQuotes) {
                SavedQuotesView()
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    private let stepTitles = ["Base Component", "Additional Parts", "3D Preview", "Quote"]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Rectangle()
                        .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 4)
                }
            }

            Text(stepTitles[currentStep])
                .font(.headline)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(QuoteManager())
}
