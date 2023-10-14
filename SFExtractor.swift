import Foundation
import AppKit

let redColor = "\u{001B}[31m"
let orangeColor = "\u{001B}[33m"
let greenColor = "\u{001B}[32m"
let resetColor = "\u{001B}[0m"

let arguments = CommandLine.arguments

if arguments.contains("-h") {
    print("Usage:")
    print("  -s <symbol_name> : Extract a specific symbol")
    print("  -h : Show help")
    print("  (No options) : Extract all symbols until the program is shut down")
    exit(0)
}

let fileManager = FileManager.default
let binDirectoryURL = URL(fileURLWithPath: "bin")
do {
    try fileManager.createDirectory(at: binDirectoryURL, withIntermediateDirectories: true, attributes: nil)
} catch {
    print("\(redColor)Failed to create 'bin/' directory: \(error)\(resetColor)")
    exit(1)
}

if let symbolIndex = arguments.firstIndex(of: "-s"), symbolIndex + 1 < arguments.count {
    let symbolName = arguments[symbolIndex + 1]
    extractSymbol(symbolName)
} else {
    var symbolNames: [String] = []

    if let symbolNamesURL = Bundle.main.url(forResource: "symbol_names", withExtension: "txt"),
        let symbolNamesText = try? String(contentsOf: symbolNamesURL, encoding: .utf8) {
        symbolNames = symbolNamesText.components(separatedBy: .newlines)
    } else {
        print("\(orangeColor)Warning: Failed to load symbol names from the text file. Skipping to the next symbol.\(resetColor)")
    }
    
    for symbolName in symbolNames {
        extractSymbol(symbolName)
    }
}

func extractSymbol(_ symbolName: String) {
    if let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "") {
        guard let tiffData = image.tiffRepresentation, !tiffData.isEmpty else {
            print("\(redColor)Error: Failed to extract the SF Symbol tiff representation for symbol: \(symbolName)\(resetColor)")
            return
        }

        let targetSize = NSSize(width: 200, height: 200)

        let resizedImage = NSImage(size: targetSize)
        resizedImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(in: NSRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        resizedImage.unlockFocus()

        let outputDirectoryURL = URL(fileURLWithPath: "bin")
        let outputFileURL = outputDirectoryURL.appendingPathComponent("\(symbolName).png")

        if let pngData = resizedImage.tiffRepresentation {
            do {
                try pngData.write(to: outputFileURL)
                print("\(greenColor)Success: SF Symbol extracted and saved as bin/\(symbolName).png (200x200)\(resetColor)")
            } catch {
                print("\(redColor)Error: Failed to write PNG data to file for symbol: \(symbolName) - \(error)\(resetColor)")
            }
        } else {
            print("\(redColor)Error: Failed to extract the SF Symbol tiff representation for symbol: \(symbolName)\(resetColor)")
        }
    } else {
        print("\(orangeColor)Warning: SF Symbol not found: \(symbolName). Skipping to the next symbol.\(resetColor)")
    }
}
