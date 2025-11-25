import Foundation

class ProductDatabase: ObservableObject {
    static let shared = ProductDatabase()

    @Published var allComponents: [Component] = []
    @Published var compatibilityMatrix: CompatibilityMatrix
    @Published var pricingRules: [PricingRule] = []

    private init() {
        // Initialize with sample data
        let rules = Self.createSampleCompatibilityRules()
        self.compatibilityMatrix = CompatibilityMatrix(rules: rules)
        self.allComponents = Self.createSampleComponents()
        self.pricingRules = Self.createSamplePricingRules()
    }

    // MARK: - Component Queries

    func getComponents(byCategory category: ComponentCategory) -> [Component] {
        return allComponents.filter { $0.category == category }
    }

    func getComponent(byId id: String) -> Component? {
        return allComponents.first { $0.id == id }
    }

    func getBaseComponents() -> [Component] {
        return getComponents(byCategory: .baseUnit)
    }

    func getCompatibleComponents(
        for selectedComponents: [Component],
        in category: ComponentCategory
    ) -> [Component] {
        guard let baseComponent = selectedComponents.first(where: { $0.category == .baseUnit }) else {
            return []
        }

        // Get compatible components based on base component
        var compatible = compatibilityMatrix.getCompatibleComponents(
            for: baseComponent.id,
            in: category,
            from: allComponents
        )

        // Further filter based on all selected components
        compatible = compatible.filter { candidate in
            let allIds = selectedComponents.map { $0.id } + [candidate.id]
            return compatibilityMatrix.areCompatible(componentIds: allIds)
        }

        return compatible
    }

    // MARK: - Sample Data Creation

    private static func createSampleComponents() -> [Component] {
        var components: [Component] = []

        // Base Units
        components.append(Component(
            id: "BASE-001",
            name: "Industrial Base Unit Alpha",
            category: .baseUnit,
            description: "Heavy-duty base unit with reinforced mounting points. Supports high-torque applications.",
            partNumber: "IBU-ALPHA-1000",
            basePrice: 1299.99,
            specifications: [
                "Max Torque": "500 Nm",
                "Weight": "45 kg",
                "Dimensions": "400x300x150 mm",
                "Material": "Aluminum Alloy"
            ],
            compatibilityTags: ["heavy-duty", "standard-mount"],
            imageURL: nil,
            modelFileName: "base_alpha"
        ))

        components.append(Component(
            id: "BASE-002",
            name: "Compact Base Unit Beta",
            category: .baseUnit,
            description: "Lightweight compact base unit ideal for space-constrained installations.",
            partNumber: "CBU-BETA-500",
            basePrice: 899.99,
            specifications: [
                "Max Torque": "250 Nm",
                "Weight": "22 kg",
                "Dimensions": "250x200x100 mm",
                "Material": "Steel Composite"
            ],
            compatibilityTags: ["compact", "standard-mount"],
            imageURL: nil,
            modelFileName: "base_beta"
        ))

        components.append(Component(
            id: "BASE-003",
            name: "Premium Base Unit Gamma",
            category: .baseUnit,
            description: "High-performance base unit with integrated cooling system and vibration dampening.",
            partNumber: "PBU-GAMMA-2000",
            basePrice: 2499.99,
            specifications: [
                "Max Torque": "1000 Nm",
                "Weight": "68 kg",
                "Dimensions": "500x400x200 mm",
                "Material": "Titanium Alloy",
                "Cooling": "Active"
            ],
            compatibilityTags: ["heavy-duty", "premium", "cooled"],
            imageURL: nil,
            modelFileName: "base_gamma"
        ))

        // Motors
        components.append(Component(
            id: "MOTOR-001",
            name: "Standard AC Motor 5HP",
            category: .motor,
            description: "Reliable 5 horsepower AC motor for general industrial applications.",
            partNumber: "MOTOR-AC-5HP",
            basePrice: 649.99,
            specifications: [
                "Power": "5 HP / 3.7 kW",
                "Voltage": "230/460V",
                "RPM": "1750",
                "Frame": "184T"
            ],
            compatibilityTags: ["heavy-duty", "standard-mount"],
            imageURL: nil,
            modelFileName: "motor_standard"
        ))

        components.append(Component(
            id: "MOTOR-002",
            name: "Compact DC Motor 3HP",
            category: .motor,
            description: "Space-saving DC motor with variable speed control.",
            partNumber: "MOTOR-DC-3HP",
            basePrice: 549.99,
            specifications: [
                "Power": "3 HP / 2.2 kW",
                "Voltage": "180V DC",
                "RPM": "0-2000 (Variable)",
                "Frame": "145T"
            ],
            compatibilityTags: ["compact", "variable-speed"],
            imageURL: nil,
            modelFileName: "motor_compact"
        ))

        components.append(Component(
            id: "MOTOR-003",
            name: "High-Efficiency Servo Motor 10HP",
            category: .motor,
            description: "Premium servo motor with encoder feedback for precision applications.",
            partNumber: "MOTOR-SERVO-10HP",
            basePrice: 1899.99,
            specifications: [
                "Power": "10 HP / 7.5 kW",
                "Voltage": "480V 3-Phase",
                "RPM": "0-3000 (Variable)",
                "Feedback": "Absolute Encoder"
            ],
            compatibilityTags: ["heavy-duty", "premium", "precision"],
            imageURL: nil,
            modelFileName: "motor_servo"
        ))

        // Gearboxes
        components.append(Component(
            id: "GEAR-001",
            name: "Helical Gearbox 10:1",
            category: .gearbox,
            description: "Smooth helical gearbox with 10:1 reduction ratio.",
            partNumber: "GEAR-HEL-10",
            basePrice: 799.99,
            specifications: [
                "Ratio": "10:1",
                "Type": "Helical",
                "Efficiency": "96%",
                "Max Input RPM": "1800"
            ],
            compatibilityTags: ["heavy-duty", "standard-mount"],
            imageURL: nil,
            modelFileName: "gearbox_helical"
        ))

        components.append(Component(
            id: "GEAR-002",
            name: "Planetary Gearbox 20:1",
            category: .gearbox,
            description: "Compact planetary gearbox with high torque capacity.",
            partNumber: "GEAR-PLAN-20",
            basePrice: 1199.99,
            specifications: [
                "Ratio": "20:1",
                "Type": "Planetary",
                "Efficiency": "94%",
                "Max Torque": "800 Nm"
            ],
            compatibilityTags: ["compact", "heavy-duty"],
            imageURL: nil,
            modelFileName: "gearbox_planetary"
        ))

        components.append(Component(
            id: "GEAR-003",
            name: "Right-Angle Worm Gearbox 40:1",
            category: .gearbox,
            description: "Self-locking worm gearbox for high reduction applications.",
            partNumber: "GEAR-WORM-40",
            basePrice: 699.99,
            specifications: [
                "Ratio": "40:1",
                "Type": "Worm",
                "Efficiency": "85%",
                "Self-Locking": "Yes"
            ],
            compatibilityTags: ["standard-mount"],
            imageURL: nil,
            modelFileName: "gearbox_worm"
        ))

        // Controllers
        components.append(Component(
            id: "CTRL-001",
            name: "Basic VFD Controller",
            category: .controller,
            description: "Variable frequency drive for motor speed control.",
            partNumber: "CTRL-VFD-BASIC",
            basePrice: 449.99,
            specifications: [
                "Type": "VFD",
                "Input": "230V Single Phase",
                "Output": "230V 3-Phase",
                "Max HP": "7.5"
            ],
            compatibilityTags: ["heavy-duty", "compact"],
            imageURL: nil,
            modelFileName: "controller_vfd"
        ))

        components.append(Component(
            id: "CTRL-002",
            name: "Advanced Servo Controller",
            category: .controller,
            description: "High-performance servo controller with position/velocity/torque modes.",
            partNumber: "CTRL-SERVO-ADV",
            basePrice: 1299.99,
            specifications: [
                "Type": "Servo Drive",
                "Control Modes": "P/V/T",
                "Communication": "EtherCAT, CANopen",
                "Max Power": "15 HP"
            ],
            compatibilityTags: ["premium", "precision"],
            imageURL: nil,
            modelFileName: "controller_servo"
        ))

        // Sensors
        components.append(Component(
            id: "SENSOR-001",
            name: "Optical Encoder",
            category: .sensor,
            description: "High-resolution optical encoder for position feedback.",
            partNumber: "SENS-ENC-OPT",
            basePrice: 299.99,
            specifications: [
                "Resolution": "2048 PPR",
                "Type": "Incremental",
                "Interface": "TTL",
                "Shaft": "10mm"
            ],
            compatibilityTags: ["precision", "premium"],
            imageURL: nil,
            modelFileName: "sensor_encoder"
        ))

        components.append(Component(
            id: "SENSOR-002",
            name: "Temperature Sensor Kit",
            category: .sensor,
            description: "Thermistor-based temperature monitoring kit.",
            partNumber: "SENS-TEMP-KIT",
            basePrice: 149.99,
            specifications: [
                "Type": "Thermistor",
                "Range": "-40 to 150°C",
                "Accuracy": "±1°C",
                "Output": "4-20mA"
            ],
            compatibilityTags: ["heavy-duty", "compact", "premium"],
            imageURL: nil,
            modelFileName: "sensor_temp"
        ))

        // Housings
        components.append(Component(
            id: "HOUSE-001",
            name: "Standard NEMA 4 Enclosure",
            category: .housing,
            description: "Weatherproof enclosure for indoor/outdoor use.",
            partNumber: "HOUS-NEMA4-STD",
            basePrice: 399.99,
            specifications: [
                "Rating": "NEMA 4/IP66",
                "Material": "Powder-coated Steel",
                "Dimensions": "500x400x200 mm"
            ],
            compatibilityTags: ["heavy-duty"],
            imageURL: nil,
            modelFileName: "housing_nema4"
        ))

        components.append(Component(
            id: "HOUSE-002",
            name: "Compact Aluminum Housing",
            category: .housing,
            description: "Lightweight aluminum housing for compact installations.",
            partNumber: "HOUS-ALU-COMP",
            basePrice: 299.99,
            specifications: [
                "Rating": "IP54",
                "Material": "Aluminum",
                "Dimensions": "300x250x150 mm"
            ],
            compatibilityTags: ["compact"],
            imageURL: nil,
            modelFileName: "housing_compact"
        ))

        // Connectors
        components.append(Component(
            id: "CONN-001",
            name: "Industrial Connector Set",
            category: .connector,
            description: "Heavy-duty connector set with IP67 rating.",
            partNumber: "CONN-IND-SET",
            basePrice: 89.99,
            specifications: [
                "Rating": "IP67",
                "Contacts": "12-pin",
                "Current": "10A per pin"
            ],
            compatibilityTags: ["heavy-duty", "compact", "premium"],
            imageURL: nil,
            modelFileName: "connector_industrial"
        ))

        // Mounting Brackets
        components.append(Component(
            id: "MOUNT-001",
            name: "Universal Mounting Bracket Set",
            category: .mounting,
            description: "Adjustable mounting bracket set for various configurations.",
            partNumber: "MOUNT-UNIV-SET",
            basePrice: 129.99,
            specifications: [
                "Material": "Steel",
                "Adjustable": "Yes",
                "Load Capacity": "200 kg"
            ],
            compatibilityTags: ["heavy-duty", "compact", "standard-mount"],
            imageURL: nil,
            modelFileName: "mounting_universal"
        ))

        return components
    }

    private static func createSampleCompatibilityRules() -> [CompatibilityRule] {
        var rules: [CompatibilityRule] = []

        // BASE-001 (Heavy-duty Alpha) compatibility
        rules.append(CompatibilityRule(
            id: "RULE-001",
            requiredComponentId: "BASE-001",
            compatibleComponentIds: ["MOTOR-001", "MOTOR-003"],
            category: .motor,
            conditions: nil
        ))
        rules.append(CompatibilityRule(
            id: "RULE-002",
            requiredComponentId: "BASE-001",
            compatibleComponentIds: ["GEAR-001", "GEAR-002"],
            category: .gearbox,
            conditions: nil
        ))
        rules.append(CompatibilityRule(
            id: "RULE-003",
            requiredComponentId: "BASE-001",
            compatibleComponentIds: ["CTRL-001", "CTRL-002"],
            category: .controller,
            conditions: nil
        ))
        rules.append(CompatibilityRule(
            id: "RULE-004",
            requiredComponentId: "BASE-001",
            compatibleComponentIds: ["HOUSE-001"],
            category: .housing,
            conditions: nil
        ))

        // BASE-002 (Compact Beta) compatibility
        rules.append(CompatibilityRule(
            id: "RULE-005",
            requiredComponentId: "BASE-002",
            compatibleComponentIds: ["MOTOR-002"],
            category: .motor,
            conditions: nil
        ))
        rules.append(CompatibilityRule(
            id: "RULE-006",
            requiredComponentId: "BASE-002",
            compatibleComponentIds: ["GEAR-002", "GEAR-003"],
            category: .gearbox,
            conditions: nil
        ))
        rules.append(CompatibilityRule(
            id: "RULE-007",
            requiredComponentId: "BASE-002",
            compatibleComponentIds: ["CTRL-001"],
            category: .controller,
            conditions: nil
        ))
        rules.append(CompatibilityRule(
            id: "RULE-008",
            requiredComponentId: "BASE-002",
            compatibleComponentIds: ["HOUSE-002"],
            category: .housing,
            conditions: nil
        ))

        // BASE-003 (Premium Gamma) compatibility
        rules.append(CompatibilityRule(
            id: "RULE-009",
            requiredComponentId: "BASE-003",
            compatibleComponentIds: ["MOTOR-003"],
            category: .motor,
            conditions: nil
        ))
        rules.append(CompatibilityRule(
            id: "RULE-010",
            requiredComponentId: "BASE-003",
            compatibleComponentIds: ["GEAR-001", "GEAR-002"],
            category: .gearbox,
            conditions: nil
        ))
        rules.append(CompatibilityRule(
            id: "RULE-011",
            requiredComponentId: "BASE-003",
            compatibleComponentIds: ["CTRL-002"],
            category: .controller,
            conditions: nil
        ))
        rules.append(CompatibilityRule(
            id: "RULE-012",
            requiredComponentId: "BASE-003",
            compatibleComponentIds: ["HOUSE-001"],
            category: .housing,
            conditions: nil
        ))

        // Universal components (sensors, connectors, mounting)
        for baseId in ["BASE-001", "BASE-002", "BASE-003"] {
            rules.append(CompatibilityRule(
                id: "RULE-SENS-\(baseId)",
                requiredComponentId: baseId,
                compatibleComponentIds: ["SENSOR-001", "SENSOR-002"],
                category: .sensor,
                conditions: nil
            ))
            rules.append(CompatibilityRule(
                id: "RULE-CONN-\(baseId)",
                requiredComponentId: baseId,
                compatibleComponentIds: ["CONN-001"],
                category: .connector,
                conditions: nil
            ))
            rules.append(CompatibilityRule(
                id: "RULE-MOUNT-\(baseId)",
                requiredComponentId: baseId,
                compatibleComponentIds: ["MOUNT-001"],
                category: .mounting,
                conditions: nil
            ))
        }

        return rules
    }

    private static func createSamplePricingRules() -> [PricingRule] {
        return [
            PricingRule(
                id: "PRICE-001",
                ruleType: .bundleDiscount,
                componentIds: ["MOTOR-003", "CTRL-002"],
                discountPercentage: 10,
                additionalCharge: nil,
                description: "Premium servo bundle discount"
            ),
            PricingRule(
                id: "PRICE-002",
                ruleType: .bundleDiscount,
                componentIds: ["BASE-003", "MOTOR-003", "GEAR-002"],
                discountPercentage: 15,
                additionalCharge: nil,
                description: "Complete premium system discount"
            ),
            PricingRule(
                id: "PRICE-003",
                ruleType: .customization,
                componentIds: [],
                discountPercentage: nil,
                additionalCharge: 150,
                description: "Complex configuration assembly fee"
            )
        ]
    }
}
