/*
Usage: swift SFExtractor <symbol_name>
*/

import Foundation
import AppKit

let arguments = CommandLine.arguments
if arguments.count < 2 {
    print("Usage: SFExtractor.swift <symbol_name>")
    exit(1)
}

let symbolName = arguments[1]

if let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "") {
    if let tiffData = image.tiffRepresentation, let cgImage = NSBitmapImageRep(data: tiffData)?.cgImage {
        _ = cgImage.width
        _ = cgImage.height
        let targetSize = NSSize(width: 200, height: 200)

        let resizedImage = NSImage(size: targetSize)
        resizedImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(in: NSRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        resizedImage.unlockFocus()

        if let pngData = resizedImage.tiffRepresentation {
            do {
                try pngData.write(to: URL(fileURLWithPath: "\(symbolName).png"))
                print("SF Symbol extracted and saved as \(symbolName).png (200x200)")
            } catch {
                print("Failed to write PNG data to file: \(error)")
                exit(1)
            }
        } else {
            print("Failed to extract the SF Symbol tiff representation.")
            exit(1)
        }
    } else {
        print("Failed to extract the SF Symbol CGImage.")
        exit(1)
    }
} else {
    print("SF Symbol not found.")
    exit(1)
}
