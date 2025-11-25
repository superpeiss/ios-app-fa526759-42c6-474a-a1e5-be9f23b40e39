import Foundation

class QuoteManager: ObservableObject {
    @Published var savedQuotes: [Quote] = []

    private let userDefaultsKey = "SavedQuotes"

    init() {
        loadQuotes()
    }

    func generateQuote(
        from configuration: Configuration,
        billOfMaterials: BillOfMaterials,
        notes: String? = nil
    ) -> Quote {
        let quoteNumber = generateQuoteNumber()

        return Quote(
            id: UUID().uuidString,
            quoteNumber: quoteNumber,
            configuration: configuration,
            billOfMaterials: billOfMaterials,
            createdDate: Date(),
            status: .draft,
            notes: notes
        )
    }

    func saveQuote(_ quote: Quote) {
        if let index = savedQuotes.firstIndex(where: { $0.id == quote.id }) {
            savedQuotes[index] = quote
        } else {
            savedQuotes.append(quote)
        }
        persistQuotes()
    }

    func deleteQuote(_ quote: Quote) {
        savedQuotes.removeAll { $0.id == quote.id }
        persistQuotes()
    }

    func updateQuoteStatus(_ quote: Quote, status: QuoteStatus) {
        if let index = savedQuotes.firstIndex(where: { $0.id == quote.id }) {
            var updatedQuote = quote
            updatedQuote.status = status
            savedQuotes[index] = updatedQuote
            persistQuotes()
        }
    }

    private func generateQuoteNumber() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: Date())

        let sequenceNumber = String(format: "%04d", savedQuotes.count + 1)

        return "QT-\(dateString)-\(sequenceNumber)"
    }

    private func persistQuotes() {
        if let encoded = try? JSONEncoder().encode(savedQuotes) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadQuotes() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Quote].self, from: data) {
            savedQuotes = decoded
        }
    }
}
