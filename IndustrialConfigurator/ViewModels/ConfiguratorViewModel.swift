import Foundation
import Combine

class ConfiguratorViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var configuration = Configuration()
    @Published var availableComponents: [ComponentCategory: [Component]] = [:]
    @Published var billOfMaterials: BillOfMaterials?
    @Published var currentQuote: Quote?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let productDatabase = ProductDatabase.shared
    private let pricingService = PricingService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupObservers()
        loadBaseComponents()
    }

    private func setupObservers() {
        // Observe configuration changes to update available components
        $configuration
            .sink { [weak self] config in
                self?.updateAvailableComponents()
            }
            .store(in: &cancellables)
    }

    // MARK: - Step Navigation

    func nextStep() {
        guard canProceedToNextStep() else { return }

        if currentStep == 2 {
            // Generate BOM before showing quote
            calculateBillOfMaterials()
        }

        currentStep = min(currentStep + 1, 3)
    }

    func previousStep() {
        currentStep = max(currentStep - 1, 0)
    }

    func canProceedToNextStep() -> Bool {
        switch currentStep {
        case 0:
            return configuration.baseComponent != nil
        case 1:
            // Can proceed even without selecting additional parts
            return true
        case 2:
            return billOfMaterials != nil
        default:
            return false
        }
    }

    // MARK: - Component Selection

    func selectBaseComponent(_ component: Component) {
        configuration.setBaseComponent(component)
        updateAvailableComponents()
    }

    func selectComponent(_ component: Component) {
        configuration.addComponent(component)
        updateAvailableComponents()
    }

    func deselectComponent(category: ComponentCategory) {
        configuration.removeComponent(category: category)
        updateAvailableComponents()
    }

    func isComponentSelected(_ component: Component) -> Bool {
        return configuration.selectedComponents[component.category]?.id == component.id
    }

    // MARK: - Available Components

    private func loadBaseComponents() {
        let baseComponents = productDatabase.getBaseComponents()
        availableComponents[.baseUnit] = baseComponents
    }

    private func updateAvailableComponents() {
        guard let baseComponent = configuration.baseComponent else {
            // Clear all except base units
            let baseUnits = availableComponents[.baseUnit]
            availableComponents = [.baseUnit: baseUnits ?? []]
            return
        }

        let selectedComponents = configuration.getAllComponents()

        // Update available components for each category
        for category in ComponentCategory.allCases where category != .baseUnit {
            let compatible = productDatabase.getCompatibleComponents(
                for: selectedComponents,
                in: category
            )
            availableComponents[category] = compatible
        }
    }

    func getAvailableComponents(for category: ComponentCategory) -> [Component] {
        return availableComponents[category] ?? []
    }

    // MARK: - Pricing and BOM

    func calculateBillOfMaterials() {
        isLoading = true

        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }

            let bom = self.pricingService.calculateBillOfMaterials(
                for: self.configuration,
                with: self.productDatabase.pricingRules
            )

            self.billOfMaterials = bom
            self.isLoading = false
        }
    }

    // MARK: - Quote Generation

    func generateQuote(notes: String? = nil) -> Quote? {
        guard let bom = billOfMaterials else { return nil }

        let quoteManager = QuoteManager()
        let quote = quoteManager.generateQuote(
            from: configuration,
            billOfMaterials: bom,
            notes: notes
        )

        currentQuote = quote
        return quote
    }

    // MARK: - Reset

    func reset() {
        configuration = Configuration()
        currentStep = 0
        billOfMaterials = nil
        currentQuote = nil
        loadBaseComponents()
    }
}
