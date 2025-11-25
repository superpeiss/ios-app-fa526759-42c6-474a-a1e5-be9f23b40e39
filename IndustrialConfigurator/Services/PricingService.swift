import Foundation

class PricingService {
    static let shared = PricingService()

    private init() {}

    func calculateBillOfMaterials(
        for configuration: Configuration,
        with pricingRules: [PricingRule]
    ) -> BillOfMaterials {
        let components = configuration.getAllComponents()

        // Create BOM items
        let items = components.map { BOMItem(component: $0, quantity: 1) }

        // Calculate subtotal
        let subtotal = items.reduce(Decimal(0)) { $0 + $1.lineTotal }

        // Apply pricing rules
        let (discounts, charges) = applyPricingRules(
            to: components,
            rules: pricingRules,
            subtotal: subtotal
        )

        // Calculate total discounts and charges
        let totalDiscounts = discounts.reduce(Decimal(0)) { $0 + $1.amount }
        let totalCharges = charges.reduce(Decimal(0)) { $0 + $1.amount }

        // Calculate tax (8.5% for example)
        let taxableAmount = subtotal - totalDiscounts + totalCharges
        let tax = (taxableAmount * Decimal(0.085)).rounded(2)

        // Calculate final total
        let total = subtotal - totalDiscounts + totalCharges + tax

        return BillOfMaterials(
            items: items,
            subtotal: subtotal,
            discounts: discounts,
            additionalCharges: charges,
            tax: tax,
            total: total,
            generatedDate: Date()
        )
    }

    private func applyPricingRules(
        to components: [Component],
        rules: [PricingRule],
        subtotal: Decimal
    ) -> ([PricingAdjustment], [PricingAdjustment]) {
        var discounts: [PricingAdjustment] = []
        var charges: [PricingAdjustment] = []

        let componentIds = Set(components.map { $0.id })

        for rule in rules {
            switch rule.ruleType {
            case .bundleDiscount:
                // Check if all required components are present
                let requiredIds = Set(rule.componentIds)
                if requiredIds.isSubset(of: componentIds) && !requiredIds.isEmpty {
                    if let discountPct = rule.discountPercentage {
                        // Calculate discount on bundle components only
                        let bundleTotal = components
                            .filter { requiredIds.contains($0.id) }
                            .reduce(Decimal(0)) { $0 + $1.basePrice }

                        let discountAmount = (bundleTotal * discountPct / 100).rounded(2)
                        discounts.append(PricingAdjustment(
                            id: rule.id,
                            description: rule.description,
                            amount: discountAmount
                        ))
                    }
                }

            case .customization:
                // Apply customization fee if configuration is complex
                if components.count >= 6 {
                    if let charge = rule.additionalCharge {
                        charges.append(PricingAdjustment(
                            id: rule.id,
                            description: rule.description,
                            amount: charge
                        ))
                    }
                }

            case .compatibilityCharge, .volumeDiscount:
                // Additional rule types can be implemented here
                break
            }
        }

        // Add assembly fee for all configurations
        charges.append(PricingAdjustment(
            id: "ASSEMBLY-FEE",
            description: "Professional assembly and testing",
            amount: 99.99
        ))

        return (discounts, charges)
    }
}

// MARK: - Decimal Extension

extension Decimal {
    func rounded(_ decimals: Int) -> Decimal {
        var result = self
        var rounded = self
        NSDecimalRound(&rounded, &result, decimals, .plain)
        return rounded
    }
}
