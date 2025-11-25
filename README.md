# Industrial Component Configurator

A production-ready iOS application for configuring and quoting industrial component assemblies.

## Features

- **Multi-step Configuration Process**: Guided workflow for selecting compatible industrial components
- **Dynamic Compatibility Rules**: Automatically filters and displays only compatible parts based on selections
- **3D Preview**: Real-time SceneKit-based 3D visualization of assembled components
- **Advanced Pricing**: Complex pricing logic with bundle discounts, customization fees, and tax calculation
- **Quote Management**: Generate, save, and export professional quotes as PDF
- **Bill of Materials**: Detailed BOM with line items, pricing adjustments, and totals

## Architecture

### Technology Stack
- **UI Framework**: SwiftUI
- **3D Graphics**: SceneKit
- **Minimum iOS Version**: 15.0
- **Project Generator**: XcodeGen
- **Language**: Swift 5.0

### Project Structure

```
IndustrialConfigurator/
├── Models/              # Data models for components, pricing, quotes
├── Views/               # SwiftUI views for the configurator
├── ViewModels/          # View models managing business logic
├── Services/            # Product database and pricing services
├── Utilities/           # Helper utilities (PDF generation, etc.)
└── Resources/           # Assets and configuration files
```

### Key Components

#### Models
- `Component`: Represents industrial parts with specifications and pricing
- `CompatibilityRule`: Defines which components work together
- `Configuration`: Current assembly state
- `BillOfMaterials`: Pricing breakdown
- `Quote`: Saved quote with configuration and pricing

#### Services
- `ProductDatabase`: Manages component catalog and compatibility rules
- `PricingService`: Calculates totals with complex pricing logic
- `QuoteManager`: Handles quote persistence and management

#### Views
- `BaseComponentSelectionView`: Initial component selection
- `CompatiblePartsSelectionView`: Additional parts with compatibility filtering
- `Preview3DView`: SceneKit-based 3D assembly preview
- `QuoteSummaryView`: Final quote with BOM and export options
- `SavedQuotesView`: List of saved quotes

## Setup Instructions

### Prerequisites
- macOS with Xcode 14.0 or later
- Homebrew (will be installed by setup script if not present)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/superpeiss/ios-app-fa526759-42c6-474a-a1e5-be9f23b40e39.git
cd ios-app-fa526759-42c6-474a-a1e5-be9f23b40e39
```

2. Run the setup script:
```bash
./setup.sh
```

This will:
- Install Homebrew (if needed)
- Install XcodeGen
- Generate the Xcode project

3. Open the project:
```bash
open IndustrialConfigurator.xcodeproj
```

### Manual Setup (Alternative)

If you prefer manual setup:

```bash
# Install XcodeGen
brew install xcodegen

# Generate project
xcodegen generate
```

## Building and Running

1. Open `IndustrialConfigurator.xcodeproj` in Xcode
2. Select a simulator or device target
3. Press Cmd+R to build and run

## Testing

The project includes unit tests for core functionality:

```bash
# Run tests from command line
xcodebuild test -scheme IndustrialConfigurator -destination 'platform=iOS Simulator,name=iPhone 14'
```

Or press Cmd+U in Xcode.

## Sample Data

The app includes sample industrial components:

### Base Units
- Industrial Base Unit Alpha (Heavy-duty, $1,299.99)
- Compact Base Unit Beta (Space-saving, $899.99)
- Premium Base Unit Gamma (High-performance, $2,499.99)

### Compatible Components
- Motors (AC, DC, Servo)
- Gearboxes (Helical, Planetary, Worm)
- Controllers (VFD, Servo Drive)
- Sensors (Encoders, Temperature)
- Housings (NEMA 4, Aluminum)
- Connectors and Mounting Brackets

## Usage

1. **Select Base Component**: Choose the foundation for your assembly
2. **Add Compatible Parts**: Select additional components (only compatible options shown)
3. **Preview in 3D**: View the assembled configuration in real-time
4. **Review Quote**: See detailed BOM with pricing
5. **Save/Export**: Save to account or export as PDF

## Pricing Logic

The app implements sophisticated pricing:

- **Bundle Discounts**: Automatic discounts for compatible component bundles
- **Assembly Fees**: Professional assembly and testing charges
- **Tax Calculation**: Automatic tax computation (8.5% default)
- **Customization Fees**: Additional charges for complex configurations

## Data Persistence

- Quotes saved to UserDefaults
- PDF export for sharing via email/AirDrop
- Quote status tracking (Draft, Submitted, Approved, Rejected)

## CI/CD

GitHub Actions workflow automatically builds the project on every push:

```yaml
# Manually trigger workflow via GitHub UI or:
gh workflow run ios-build.yml
```

## Future Enhancements

- [ ] Backend integration for real-time product database
- [ ] User authentication and cloud sync
- [ ] AR preview using ARKit
- [ ] Advanced 3D models with textures
- [ ] Multi-currency support
- [ ] Email quote delivery

## License

Copyright © 2025 Industrial Components Inc. All rights reserved.

## Support

For issues or questions, please open a GitHub issue.
