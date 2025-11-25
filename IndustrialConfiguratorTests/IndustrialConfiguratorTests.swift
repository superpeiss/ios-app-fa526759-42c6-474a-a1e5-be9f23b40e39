import XCTest
@testable import IndustrialConfigurator

final class IndustrialConfiguratorTests: XCTestCase {

    func testComponentCreation() {
        let component = Component(
            id: "TEST-001",
            name: "Test Component",
            category: .baseUnit,
            description: "A test component",
            partNumber: "TEST-001-PN",
            basePrice: 99.99,
            specifications: ["Weight": "10 kg"],
            compatibilityTags: ["test"],
            imageURL: nil,
            modelFileName: nil
        )

        XCTAssertEqual(component.id, "TEST-001")
        XCTAssertEqual(component.name, "Test Component")
        XCTAssertEqual(component.basePrice, 99.99)
    }

    func testConfigurationManagement() {
        var config = Configuration()

        let baseComponent = Component(
            id: "BASE-001",
            name: "Base Unit",
            category: .baseUnit,
            description: "Base unit",
            partNumber: "BASE-001-PN",
            basePrice: 1000.00,
            specifications: [:],
            compatibilityTags: [],
            imageURL: nil,
            modelFileName: nil
        )

        config.setBaseComponent(baseComponent)

        XCTAssertNotNil(config.baseComponent)
        XCTAssertEqual(config.baseComponent?.id, "BASE-001")
        XCTAssertTrue(config.isValid)
    }

    func testPricingCalculation() {
        let component1 = Component(
            id: "COMP-001",
            name: "Component 1",
            category: .baseUnit,
            description: "Component 1",
            partNumber: "COMP-001-PN",
            basePrice: 100.00,
            specifications: [:],
            compatibilityTags: [],
            imageURL: nil,
            modelFileName: nil
        )

        let component2 = Component(
            id: "COMP-002",
            name: "Component 2",
            category: .motor,
            description: "Component 2",
            partNumber: "COMP-002-PN",
            basePrice: 200.00,
            specifications: [:],
            compatibilityTags: [],
            imageURL: nil,
            modelFileName: nil
        )

        var config = Configuration()
        config.setBaseComponent(component1)
        config.addComponent(component2)

        let pricingService = PricingService.shared
        let bom = pricingService.calculateBillOfMaterials(for: config, with: [])

        XCTAssertEqual(bom.items.count, 2)
        XCTAssertEqual(bom.subtotal, 300.00)
        XCTAssertGreaterThan(bom.total, 0)
    }

    func testQuoteGeneration() {
        let component = Component(
            id: "BASE-001",
            name: "Base Unit",
            category: .baseUnit,
            description: "Base unit",
            partNumber: "BASE-001-PN",
            basePrice: 1000.00,
            specifications: [:],
            compatibilityTags: [],
            imageURL: nil,
            modelFileName: nil
        )

        var config = Configuration()
        config.setBaseComponent(component)

        let pricingService = PricingService.shared
        let bom = pricingService.calculateBillOfMaterials(for: config, with: [])

        let quoteManager = QuoteManager()
        let quote = quoteManager.generateQuote(from: config, billOfMaterials: bom)

        XCTAssertFalse(quote.quoteNumber.isEmpty)
        XCTAssertEqual(quote.status, .draft)
        XCTAssertNotNil(quote.billOfMaterials)
    }

    func testCompatibilityRules() {
        let rule = CompatibilityRule(
            id: "RULE-001",
            requiredComponentId: "BASE-001",
            compatibleComponentIds: ["MOTOR-001", "MOTOR-002"],
            category: .motor,
            conditions: nil
        )

        let matrix = CompatibilityMatrix(rules: [rule])

        // Test basic compatibility
        XCTAssertTrue(matrix.areCompatible(componentIds: ["BASE-001", "MOTOR-001"]))
    }
}
