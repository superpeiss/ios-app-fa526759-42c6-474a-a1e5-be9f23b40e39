import SwiftUI

struct CompatiblePartsSelectionView: View {
    @ObservedObject var viewModel: ConfiguratorViewModel

    private let categories: [ComponentCategory] = [
        .motor, .gearbox, .controller, .sensor, .housing, .connector, .mounting
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Add Compatible Components")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                Text("Select additional components. Only compatible parts are shown based on your base selection.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                ForEach(categories, id: \.self) { category in
                    ComponentCategorySection(
                        category: category,
                        viewModel: viewModel
                    )
                }
            }
            .padding(.vertical)
        }
    }
}

struct ComponentCategorySection: View {
    let category: ComponentCategory
    @ObservedObject var viewModel: ConfiguratorViewModel
    @State private var isExpanded = false

    var body: some View {
        let components = viewModel.getAvailableComponents(for: category)

        if !components.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(category.rawValue)
                            .font(.headline)

                        Spacer()

                        if let selected = viewModel.configuration.selectedComponents[category] {
                            Text(selected.name)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)

                if isExpanded {
                    LazyVStack(spacing: 8) {
                        ForEach(components) { component in
                            CompactComponentCard(
                                component: component,
                                isSelected: viewModel.isComponentSelected(component),
                                action: {
                                    if viewModel.isComponentSelected(component) {
                                        viewModel.deselectComponent(category: category)
                                    } else {
                                        viewModel.selectComponent(component)
                                    }
                                }
                            )
                        }
                    }
                    .transition(.opacity)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CompactComponentCard: View {
    let component: Component
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(component.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)

                        Spacer()

                        Text(component.priceFormatted)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }

                    Text(component.partNumber)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // Key specifications
                    if let firstSpec = component.specifications.first {
                        Text("\(firstSpec.key): \(firstSpec.value)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CompatiblePartsSelectionView(viewModel: ConfiguratorViewModel())
}
