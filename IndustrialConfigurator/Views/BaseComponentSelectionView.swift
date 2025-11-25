import SwiftUI

struct BaseComponentSelectionView: View {
    @ObservedObject var viewModel: ConfiguratorViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Select Base Component")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                Text("Choose the foundation for your industrial assembly. This will determine compatible components.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                LazyVStack(spacing: 12) {
                    ForEach(viewModel.getAvailableComponents(for: .baseUnit)) { component in
                        ComponentCard(
                            component: component,
                            isSelected: viewModel.isComponentSelected(component),
                            action: {
                                viewModel.selectBaseComponent(component)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

struct ComponentCard: View {
    let component: Component
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                // Component image placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)

                    Image(systemName: iconForCategory(component.category))
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(component.name)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Spacer()

                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }

                    Text(component.partNumber)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(component.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    // Specifications
                    if !component.specifications.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(Array(component.specifications.prefix(3)), id: \.key) { key, value in
                                HStack {
                                    Text(key)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(value)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }

                    Text(component.priceFormatted)
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                }

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func iconForCategory(_ category: ComponentCategory) -> String {
        switch category {
        case .baseUnit: return "cube.box.fill"
        case .motor: return "bolt.fill"
        case .gearbox: return "gearshape.fill"
        case .controller: return "cpu.fill"
        case .sensor: return "sensor.fill"
        case .housing: return "square.stack.3d.up.fill"
        case .connector: return "cable.connector"
        case .mounting: return "wrench.and.screwdriver.fill"
        }
    }
}

#Preview {
    BaseComponentSelectionView(viewModel: ConfiguratorViewModel())
}
