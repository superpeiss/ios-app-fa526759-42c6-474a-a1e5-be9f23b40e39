import Foundation
import UIKit
import PDFKit

class QuotePDFGenerator {
    static func generatePDF(for quote: Quote) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Industrial Configurator",
            kCGPDFContextAuthor: "Industrial Components Inc.",
            kCGPDFContextTitle: quote.quoteNumber
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { (context) in
            context.beginPage()

            var yPosition: CGFloat = 50

            // Header
            yPosition = drawHeader(quote: quote, in: pageRect, yPosition: yPosition)

            // Quote Info
            yPosition = drawQuoteInfo(quote: quote, in: pageRect, yPosition: yPosition)

            // Line Items
            yPosition = drawLineItems(quote: quote, in: pageRect, yPosition: yPosition)

            // Totals
            yPosition = drawTotals(quote: quote, in: pageRect, yPosition: yPosition)

            // Notes
            if let notes = quote.notes, !notes.isEmpty {
                yPosition = drawNotes(notes: notes, in: pageRect, yPosition: yPosition)
            }

            // Footer
            drawFooter(in: pageRect)
        }

        return data
    }

    private static func drawHeader(quote: Quote, in rect: CGRect, yPosition: CGFloat) -> CGFloat {
        let title = "QUOTE"
        let titleFont = UIFont.boldSystemFont(ofSize: 32)
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]

        let titleSize = title.size(withAttributes: titleAttributes)
        let titleRect = CGRect(x: 50, y: yPosition, width: titleSize.width, height: titleSize.height)
        title.draw(in: titleRect, withAttributes: titleAttributes)

        let companyName = "Industrial Components Inc."
        let companyFont = UIFont.systemFont(ofSize: 12)
        let companyAttributes: [NSAttributedString.Key: Any] = [.font: companyFont]
        let companyRect = CGRect(x: rect.width - 200, y: yPosition, width: 150, height: 20)
        companyName.draw(in: companyRect, withAttributes: companyAttributes)

        return yPosition + titleSize.height + 30
    }

    private static func drawQuoteInfo(quote: Quote, in rect: CGRect, yPosition: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 12)
        let boldFont = UIFont.boldSystemFont(ofSize: 12)
        var currentY = yPosition

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        let quoteInfo: [(String, String)] = [
            ("Quote Number:", quote.quoteNumber),
            ("Date:", dateFormatter.string(from: quote.createdDate)),
            ("Status:", quote.status.rawValue)
        ]

        for (label, value) in quoteInfo {
            let labelAttributes: [NSAttributedString.Key: Any] = [.font: boldFont]
            let valueAttributes: [NSAttributedString.Key: Any] = [.font: font]

            let labelRect = CGRect(x: 50, y: currentY, width: 150, height: 20)
            label.draw(in: labelRect, withAttributes: labelAttributes)

            let valueRect = CGRect(x: 200, y: currentY, width: 300, height: 20)
            value.draw(in: valueRect, withAttributes: valueAttributes)

            currentY += 25
        }

        return currentY + 20
    }

    private static func drawLineItems(quote: Quote, in rect: CGRect, yPosition: CGFloat) -> CGFloat {
        var currentY = yPosition

        // Header
        let headerFont = UIFont.boldSystemFont(ofSize: 14)
        let headerAttributes: [NSAttributedString.Key: Any] = [.font: headerFont]

        "Bill of Materials".draw(
            in: CGRect(x: 50, y: currentY, width: 300, height: 20),
            withAttributes: headerAttributes
        )

        currentY += 30

        // Table header
        let tableHeaderFont = UIFont.boldSystemFont(ofSize: 10)
        let tableHeaderAttributes: [NSAttributedString.Key: Any] = [.font: tableHeaderFont]

        let headers = ["Part Number", "Description", "Qty", "Price"]
        let columnWidths: [CGFloat] = [120, 250, 50, 80]
        var xPosition: CGFloat = 50

        for (index, header) in headers.enumerated() {
            header.draw(
                in: CGRect(x: xPosition, y: currentY, width: columnWidths[index], height: 20),
                withAttributes: tableHeaderAttributes
            )
            xPosition += columnWidths[index]
        }

        currentY += 25

        // Line items
        let itemFont = UIFont.systemFont(ofSize: 10)
        let itemAttributes: [NSAttributedString.Key: Any] = [.font: itemFont]

        for item in quote.billOfMaterials.items {
            xPosition = 50

            let values = [
                item.component.partNumber,
                item.component.name,
                "\(item.quantity)",
                item.lineTotalFormatted
            ]

            for (index, value) in values.enumerated() {
                value.draw(
                    in: CGRect(x: xPosition, y: currentY, width: columnWidths[index], height: 20),
                    withAttributes: itemAttributes
                )
                xPosition += columnWidths[index]
            }

            currentY += 20
        }

        return currentY + 20
    }

    private static func drawTotals(quote: Quote, in rect: CGRect, yPosition: CGFloat) -> CGFloat {
        var currentY = yPosition
        let font = UIFont.systemFont(ofSize: 11)
        let boldFont = UIFont.boldSystemFont(ofSize: 12)

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"

        let bom = quote.billOfMaterials

        // Subtotal
        currentY = drawTotalLine(
            label: "Subtotal:",
            value: formatter.string(from: bom.subtotal as NSDecimalNumber) ?? "$0.00",
            yPosition: currentY,
            font: font
        )

        // Discounts
        for discount in bom.discounts {
            currentY = drawTotalLine(
                label: discount.description + ":",
                value: "-" + discount.amountFormatted,
                yPosition: currentY,
                font: font
            )
        }

        // Charges
        for charge in bom.additionalCharges {
            currentY = drawTotalLine(
                label: charge.description + ":",
                value: charge.amountFormatted,
                yPosition: currentY,
                font: font
            )
        }

        // Tax
        currentY = drawTotalLine(
            label: "Tax (8.5%):",
            value: formatter.string(from: bom.tax as NSDecimalNumber) ?? "$0.00",
            yPosition: currentY,
            font: font
        )

        currentY += 10

        // Total
        currentY = drawTotalLine(
            label: "TOTAL:",
            value: formatter.string(from: bom.total as NSDecimalNumber) ?? "$0.00",
            yPosition: currentY,
            font: boldFont
        )

        return currentY + 20
    }

    private static func drawTotalLine(label: String, value: String, yPosition: CGFloat, font: UIFont) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]

        label.draw(
            in: CGRect(x: 350, y: yPosition, width: 150, height: 20),
            withAttributes: attributes
        )

        value.draw(
            in: CGRect(x: 500, y: yPosition, width: 100, height: 20),
            withAttributes: attributes
        )

        return yPosition + 20
    }

    private static func drawNotes(notes: String, in rect: CGRect, yPosition: CGFloat) -> CGFloat {
        let headerFont = UIFont.boldSystemFont(ofSize: 12)
        let headerAttributes: [NSAttributedString.Key: Any] = [.font: headerFont]

        "Notes:".draw(
            in: CGRect(x: 50, y: yPosition, width: 100, height: 20),
            withAttributes: headerAttributes
        )

        let notesFont = UIFont.systemFont(ofSize: 10)
        let notesAttributes: [NSAttributedString.Key: Any] = [.font: notesFont]

        let notesRect = CGRect(x: 50, y: yPosition + 25, width: rect.width - 100, height: 100)
        notes.draw(in: notesRect, withAttributes: notesAttributes)

        return yPosition + 150
    }

    private static func drawFooter(in rect: CGRect) {
        let footer = "Thank you for your business!"
        let footerFont = UIFont.italicSystemFont(ofSize: 10)
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: footerFont,
            .foregroundColor: UIColor.gray
        ]

        let footerSize = footer.size(withAttributes: footerAttributes)
        let footerRect = CGRect(
            x: (rect.width - footerSize.width) / 2,
            y: rect.height - 50,
            width: footerSize.width,
            height: footerSize.height
        )

        footer.draw(in: footerRect, withAttributes: footerAttributes)
    }
}
