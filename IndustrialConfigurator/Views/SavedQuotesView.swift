import SwiftUI

struct SavedQuotesView: View {
    @EnvironmentObject var quoteManager: QuoteManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                if quoteManager.savedQuotes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("No Saved Quotes")
                            .font(.headline)

                        Text("Create a configuration and save a quote to see it here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ForEach(quoteManager.savedQuotes.sorted(by: { $0.createdDate > $1.createdDate })) { quote in
                        NavigationLink(destination: QuoteDetailView(quote: quote)) {
                            QuoteRowView(quote: quote)
                        }
                    }
                    .onDelete(perform: deleteQuotes)
                }
            }
            .navigationTitle("Saved Quotes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                if !quoteManager.savedQuotes.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
            }
        }
    }

    private func deleteQuotes(at offsets: IndexSet) {
        let sortedQuotes = quoteManager.savedQuotes.sorted(by: { $0.createdDate > $1.createdDate })
        offsets.forEach { index in
            quoteManager.deleteQuote(sortedQuotes[index])
        }
    }
}

struct QuoteRowView: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(quote.quoteNumber)
                    .font(.headline)

                Spacer()

                StatusBadge(status: quote.status)
            }

            Text(quote.createdDateFormatted)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Text("\(quote.configuration.getAllComponents().count) components")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(quote.billOfMaterials.totalFormatted)
                    .font(.headline)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: QuoteStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(4)
    }

    private var backgroundColor: Color {
        switch status {
        case .draft: return .gray
        case .submitted: return .blue
        case .approved: return .green
        case .rejected: return .red
        }
    }
}

struct QuoteDetailView: View {
    let quote: Quote
    @EnvironmentObject var quoteManager: QuoteManager
    @State private var showingShareSheet = false
    @State private var pdfData: Data?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(quote.quoteNumber)
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack {
                        Text(quote.createdDateFormatted)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        StatusBadge(status: quote.status)
                    }
                }
                .padding(.horizontal)

                // Components
                VStack(alignment: .leading, spacing: 12) {
                    Text("Components")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(quote.billOfMaterials.items) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.component.name)
                                    .font(.subheadline)

                                Text(item.component.partNumber)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text(item.lineTotalFormatted)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }

                // Total
                HStack {
                    Text("Total")
                        .font(.title3)
                        .fontWeight(.bold)

                    Spacer()

                    Text(quote.billOfMaterials.totalFormatted)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)

                // Notes
                if let notes = quote.notes {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)

                        Text(notes)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

                // Export button
                Button(action: {
                    pdfData = QuotePDFGenerator.generatePDF(for: quote)
                    showingShareSheet = true
                }) {
                    Label("Export as PDF", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Quote Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShareSheet) {
            if let pdfData = pdfData {
                ShareSheet(items: [pdfData])
            }
        }
    }
}

#Preview {
    SavedQuotesView()
        .environmentObject(QuoteManager())
}
