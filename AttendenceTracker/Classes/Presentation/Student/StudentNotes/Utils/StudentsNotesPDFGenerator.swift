//
//  StudentsNotesPDFGenerator.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 05.08.2025.
//

import UIKit

final class StudentsNotesPDFGenerator {
    func generatePDF(for student: Student, notes: [StudentNote]) -> Data {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"

        let pageWidth: CGFloat = 595
        let margin: CGFloat = 32

        let titleAttributes = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.IBMPlexSans.bold(size: 21.scale))
            .dictionary
        let fullName = "\(student.firstName) \(student.lastName)"
        let titleBounding = fullName.boundingRect(
            with: CGSize(width: pageWidth - 2 * margin, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: titleAttributes,
            context: nil
        )
        let titleHeight = ceil(titleBounding.height)

        var contentHeight = margin + titleHeight + 8
        let separatorHeight: CGFloat = 1
        contentHeight += separatorHeight + 16

        let bodyAttributes = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.IBMPlexSans.regular(size: 16.scale))
            .dictionary
        let textWidth = pageWidth - 2 * margin

        for note in notes {
            let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: note.createdAt))
            let noteText = String(format: "%@\n%@", dateString, note.text)
            let bounding = noteText.boundingRect(
                with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: bodyAttributes,
                context: nil
            )
            contentHeight += ceil(bounding.height) + 12
        }
        contentHeight += margin

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: contentHeight))
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            var y = margin

            let titleRect = CGRect(x: margin, y: y, width: pageWidth - 2 * margin, height: titleHeight)
            fullName.draw(in: titleRect, withAttributes: titleAttributes)
            y += titleHeight + 8

            ctx.cgContext.setFillColor(Appearance.mono200.cgColor)
            ctx.cgContext.fill(CGRect(x: margin, y: y, width: pageWidth - 2 * margin, height: separatorHeight))
            y += separatorHeight + 16

            for note in notes {
                let date = Date(timeIntervalSince1970: note.createdAt)
                let dateString = dateFormatter.string(from: date)
                let noteText = String(format: "%@\n%@", dateString, note.text)
                let bounding = noteText.boundingRect(
                    with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: bodyAttributes,
                    context: nil
                )
                let textRect = CGRect(x: margin, y: y, width: textWidth, height: ceil(bounding.height))
                noteText.draw(in: textRect, withAttributes: bodyAttributes)
                y += ceil(bounding.height) + 12
            }
        }

        return data
    }
}
