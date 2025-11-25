import Foundation

// MARK: - Component Models

enum ComponentCategory: String, Codable, CaseIterable {
    case baseUnit = "Base Unit"
    case motor = "Motor"
    case gearbox = "Gearbox"
    case controller = "Controller"
    case sensor = "Sensor"
    case housing = "Housing"
    case connector = "Connector"
    case mounting = "Mounting Bracket"
}

struct Component: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let category: ComponentCategory
    let description: String
    let partNumber: String
    let basePrice: Decimal
    let specifications: [String: String]
    let compatibilityTags: [String]
    let imageURL: String?
    let modelFileName: String? // For 3D model

    // Computed property for display
    var priceFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: basePrice as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Compatibility Models

struct CompatibilityRule: Codable {
    let id: String
    let requiredComponentId: String
    let compatibleComponentIds: [String]
    let category: ComponentCategory
    let conditions: [String: String]? // Additional conditions
}

struct CompatibilityMatrix {
    private var rules: [String: [CompatibilityRule]]

    init(rules: [CompatibilityRule]) {
        self.rules = Dictionary(grouping: rules, by: { $0.requiredComponentId })
    }

    func getCompatibleComponents(
        for componentId: String,
        in category: ComponentCategory,
        from allComponents: [Component]
    ) -> [Component] {
        guard let rulesForComponent = rules[componentId] else {
            // If no specific rules, return all components in category
            return allComponents.filter { $0.category == category }
        }

        let compatibleIds = rulesForComponent
            .filter { $0.category == category }
            .flatMap { $0.compatibleComponentIds }

        return allComponents.filter { compatibleIds.contains($0.id) }
    }

    func areCompatible(componentIds: [String]) -> Bool {
        // Check if all components are mutually compatible
        for id in componentIds {
            guard let rulesForId = rules[id] else { continue }

            for rule in rulesForId {
                let requiredCompatibles = Set(rule.compatibleComponentIds)
                let selectedInCategory = componentIds.filter { otherId in
                    // This is a simplified check
                    return otherId != id
                }

                // If there are specific rules, at least one must match
                if !rule.compatibleComponentIds.isEmpty {
                    let hasMatch = selectedInCategory.contains { requiredCompatibles.contains($0) }
                    if !hasMatch && !selectedInCategory.isEmpty {
                        return false
                    }
                }
            }
        }
        return true
    }
}

// MARK: - Configuration Models

struct Configuration: Codable {
    var baseComponent: Component?
    var selectedComponents: [ComponentCategory: Component]

    init() {
        self.selectedComponents = [:]
    }

    mutating func setBaseComponent(_ component: Component) {
        self.baseComponent = component
        self.selectedComponents = [component.category: component]
    }

    mutating func addComponent(_ component: Component) {
        selectedComponents[component.category] = component
    }

    mutating func removeComponent(category: ComponentCategory) {
        selectedComponents.removeValue(forKey: category)
    }

    func getAllComponents() -> [Component] {
        return Array(selectedComponents.values)
    }

    var isValid: Bool {
        return baseComponent != nil && !selectedComponents.isEmpty
    }
}

// MARK: - Pricing Models

struct PricingRule: Codable {
    let id: String
    let ruleType: PricingRuleType
    let componentIds: [String]
    let discountPercentage: Decimal?
    let additionalCharge: Decimal?
    let description: String
}

enum PricingRuleType: String, Codable {
    case bundleDiscount = "Bundle Discount"
    case compatibilityCharge = "Compatibility Charge"
    case volumeDiscount = "Volume Discount"
    case customization = "Customization Fee"
}

struct BillOfMaterials: Codable {
    let items: [BOMItem]
    let subtotal: Decimal
    let discounts: [PricingAdjustment]
    let additionalCharges: [PricingAdjustment]
    let tax: Decimal
    let total: Decimal
    let generatedDate: Date

    var totalFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: total as NSDecimalNumber) ?? "$0.00"
    }
}

struct BOMItem: Codable, Identifiable {
    let id: String
    let component: Component
    let quantity: Int
    let unitPrice: Decimal
    let lineTotal: Decimal

    init(component: Component, quantity: Int = 1) {
        self.id = component.id
        self.component = component
        self.quantity = quantity
        self.unitPrice = component.basePrice
        self.lineTotal = component.basePrice * Decimal(quantity)
    }

    var lineTotalFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: lineTotal as NSDecimalNumber) ?? "$0.00"
    }
}

struct PricingAdjustment: Codable, Identifiable {
    let id: String
    let description: String
    let amount: Decimal

    var amountFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        let formatted = formatter.string(from: abs(amount) as NSDecimalNumber) ?? "$0.00"
        return amount >= 0 ? formatted : "-\(formatted)"
    }
}

// MARK: - Quote Models

struct Quote: Identifiable, Codable {
    let id: String
    let quoteNumber: String
    let configuration: Configuration
    let billOfMaterials: BillOfMaterials
    let createdDate: Date
    var status: QuoteStatus
    let notes: String?

    var createdDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdDate)
    }
}

enum QuoteStatus: String, Codable {
    case draft = "Draft"
    case submitted = "Submitted"
    case approved = "Approved"
    case rejected = "Rejected"
}
