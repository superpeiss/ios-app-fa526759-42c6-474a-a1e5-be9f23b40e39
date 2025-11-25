import SwiftUI

struct QuoteSummaryView: View {
    @ObservedObject var viewModel: ConfiguratorViewModel
    @EnvironmentObject var quoteManager: QuoteManager
    @State private var notes: String = ""
    @State private var showingSaveConfirmation = false
    @State private var showingShareSheet = false
    @State private var pdfData: Data?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quote Summary")
                        .font(.title2)
                        .fontWeight(.bold)

                    if let quote = viewModel.currentQuote {
                        Text("Quote #\(quote.quoteNumber)")
                            .font(.headline)
                            .foregroundColor(.blue)

                        Text(quote.createdDateFormatted)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)

                // Bill of Materials
                if let bom = viewModel.billOfMaterials {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Bill of Materials")
                            .font(.headline)

                        // Line Items
                        ForEach(bom.items) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.component.name)
                                        .font(.subheadline)

                                    Text(item.component.partNumber)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing) {
                                    Text("Qty: \(item.quantity)")
                                        .font(.caption)

                                    Text(item.lineTotalFormatted)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }

                        Divider()

                        // Subtotal
                        HStack {
                            Text("Subtotal")
                                .font(.subheadline)
                            Spacer()
                            Text(formatCurrency(bom.subtotal))
                                .font(.subheadline)
                        }
                        .padding(.horizontal)

                        // Discounts
                        if !bom.discounts.isEmpty {
                            ForEach(bom.discounts) { discount in
                                HStack {
                                    Text(discount.description)
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                    Spacer()
                                    Text("-\(discount.amountFormatted)")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Additional Charges
                        if !bom.additionalCharges.isEmpty {
                            ForEach(bom.additionalCharges) { charge in
                                HStack {
                                    Text(charge.description)
                                        .font(.subheadline)
                                    Spacer()
                                    Text(charge.amountFormatted)
                                        .font(.subheadline)
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Tax
                        HStack {
                            Text("Tax (8.5%)")
                                .font(.subheadline)
                            Spacer()
                            Text(formatCurrency(bom.tax))
                                .font(.subheadline)
                        }
                        .padding(.horizontal)

                        Divider()

                        // Total
                        HStack {
                            Text("Total")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            Text(formatCurrency(bom.total))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }

                // Notes Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes (Optional)")
                        .font(.headline)

                    TextEditor(text: $notes)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // Actions
                VStack(spacing: 12) {
                    Button(action: saveQuote) {
                        Label("Save Quote to Account", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: exportQuote) {
                        Label("Export as PDF", systemImage: "doc.text")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        viewModel.reset()
                    }) {
                        Label("Start New Configuration", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .alert("Quote Saved", isPresented: $showingSaveConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your quote has been saved to your account.")
        }
        .sheet(isPresented: $showingShareSheet) {
            if let pdfData = pdfData {
                ShareSheet(items: [pdfData])
            }
        }
    }

    private func saveQuote() {
        let quote = viewModel.generateQuote(notes: notes.isEmpty ? nil : notes)
        if let quote = quote {
            quoteManager.saveQuote(quote)
            showingSaveConfirmation = true
        }
    }

    private func exportQuote() {
        guard let bom = viewModel.billOfMaterials else { return }

        let quote = viewModel.generateQuote(notes: notes.isEmpty ? nil : notes)
        if let quote = quote {
            pdfData = QuotePDFGenerator.generatePDF(for: quote)
            showingShareSheet = true
        }
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

// Share Sheet for PDF export
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    QuoteSummaryView(viewModel: ConfiguratorViewModel())
        .environmentObject(QuoteManager())
}
