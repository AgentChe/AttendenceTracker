//
//  AttendancePDFGenerator.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 08.08.2025.
//

import UIKit

final class AttendancePDFGenerator {
    func generatePDF(for records: [AttendanceTableRecordElement], notes: [AttendanceNote]) -> Data {
        // Ширина стандартного A4 в pt (72 dpi)
        let pageWidth: CGFloat = 595.2
        let margin: CGFloat   = 20

        // MARK: — Сначала измеряем высоту всего содержимого
        
        // Заголовок
        let title = "Records:"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: Fonts.IBMPlexSans.semiBold(size: 18.scale),
            .foregroundColor: Appearance.mono200
        ]
        let titleSize = title.size(withAttributes: titleAttrs)
        var contentHeight = margin + titleSize.height + 16

        // Записи
        for record in records {
            // Имя
            let name = "\(record.student.firstName) \(record.student.lastName)"
            let nameAttrs: [NSAttributedString.Key: Any] = [
                .font: Fonts.IBMPlexSans.regular(size: 16.scale),
                .foregroundColor: Appearance.mono200
            ]
            let nameSize = name.size(withAttributes: nameAttrs)

            // Статус
            let statusText = record.status.title
            let statusAttrs: [NSAttributedString.Key: Any] = [
                .font: Fonts.IBMPlexSans.semiBold(size: 16.scale),
                .foregroundColor: Appearance.mono100
            ]
            let textSize = statusText.size(withAttributes: statusAttrs)
            let badgeHeight = textSize.height + 2 * 4  // vPadding = 4

            // Высота строки = max(name, badge) + отступ
            contentHeight += max(nameSize.height, badgeHeight) + 8
        }

        // Разделитель после записей
        contentHeight += 8 + 1 + 16

        // Заметки
        let notesAttrs: [NSAttributedString.Key: Any] = [
            .font: Fonts.IBMPlexSans.regular(size: 16.scale),
            .foregroundColor: Appearance.mono200
        ]
        let notesWidth = pageWidth - 2 * margin
        for note in notes {
            let text = note.text as NSString
            let rect = text.boundingRect(
                with: CGSize(width: notesWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin],
                attributes: notesAttrs,
                context: nil
            )
            contentHeight += rect.height + 8
            // Добавляем место для разделителя между заметками (кроме последней)
            if notes.count > 1 {
                contentHeight += 12
            }
        }

        // Добавим нижний margin
        contentHeight += margin

        // MARK: — Генерируем PDF одного размера
        
        let pdfBounds = CGRect(x: 0, y: 0, width: pageWidth, height: contentHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pdfBounds)

        let data = renderer.pdfData { context in
            context.beginPage()
            let ctx = context.cgContext
            var currentY = margin

            // Title
            title.draw(at: CGPoint(x: margin, y: currentY), withAttributes: titleAttrs)
            currentY += titleSize.height + 16

            // Records
            for record in records {
                // Name
                let name = "\(record.student.firstName) \(record.student.lastName)"
                let nameAttrs: [NSAttributedString.Key: Any] = [
                    .font: Fonts.IBMPlexSans.regular(size: 16.scale),
                    .foregroundColor: Appearance.mono200
                ]
                let nameSize = name.size(withAttributes: nameAttrs)
                name.draw(at: CGPoint(x: margin, y: currentY), withAttributes: nameAttrs)

                // Badge
                let statusText = record.status.title
                let statusAttrs: [NSAttributedString.Key: Any] = [
                    .font: Fonts.IBMPlexSans.semiBold(size: 16.scale),
                    .foregroundColor: Appearance.mono100
                ]
                let textSize = statusText.size(withAttributes: statusAttrs)
                let hPadding: CGFloat = 8
                let vPadding: CGFloat = 4
                let badgeWidth  = textSize.width + 2 * hPadding
                let badgeHeight = textSize.height + 2 * vPadding
                let badgeX = pageWidth - margin - badgeWidth
                let badgeRect = CGRect(x: badgeX, y: currentY, width: badgeWidth, height: badgeHeight)

                let badgePath = UIBezierPath(roundedRect: badgeRect, cornerRadius: 8)
                Appearance.main100.setFill()
                badgePath.fill()

                let textPoint = CGPoint(x: badgeX + hPadding, y: currentY + vPadding)
                statusText.draw(at: textPoint, withAttributes: statusAttrs)

                currentY += max(nameSize.height, badgeHeight) + 8
            }

            // Разделитель после записей
            currentY += 8
            ctx.setStrokeColor(Appearance.mono200.withAlphaComponent(0.2).cgColor)
            ctx.setLineWidth(1)
            ctx.move(to: CGPoint(x: margin, y: currentY))
            ctx.addLine(to: CGPoint(x: pageWidth - margin, y: currentY))
            ctx.strokePath()
            currentY += 16

            // Notes
            for (index, note) in notes.enumerated() {
                let text = note.text as NSString
                let boundingRect = text.boundingRect(
                    with: CGSize(width: notesWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin],
                    attributes: notesAttrs,
                    context: nil
                )
                let drawRect = CGRect(x: margin, y: currentY, width: notesWidth, height: boundingRect.height)
                text.draw(with: drawRect, options: [.usesLineFragmentOrigin], attributes: notesAttrs, context: nil)
                currentY += boundingRect.height + 8

                // Разделитель между заметками (кроме последней)
                if index < notes.count - 1 {
                    ctx.setStrokeColor(Appearance.main100.withAlphaComponent(0.2).cgColor)
                    ctx.setLineWidth(1)
                    ctx.setLineDash(phase: 0, lengths: [4, 4])
                    let sepY = currentY
                    ctx.move(to: CGPoint(x: margin, y: sepY))
                    ctx.addLine(to: CGPoint(x: pageWidth - margin, y: sepY))
                    ctx.strokePath()
                    ctx.setLineDash(phase: 0, lengths: [])
                    currentY += 12
                }
            }
        }

        return data
    }
}
