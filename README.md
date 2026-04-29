# QRCodeGenerator

![QRCodeGenerator](assets/QRCodeGenerator.gif)

QRCodeGenerator is a finished SwiftUI demo app that generates a scannable QR code from text or a URL entered by the user.

It is designed as the complete sample project that accompanies a focused blog post about the reusable `QRCodeGenerator` helper. The post can stay small and teach the Core Image technique, while this app shows the surrounding user experience needed for a polished demo.

You can find the blog post on my website: << ENTER LINK HERE >>

## What the App Demonstrates

- Generating a QR code from a `String` using Core Image.
- Wrapping QR generation in a small reusable `QRCodeGenerator` enum.
- Displaying a crisp, non-blurry QR code in SwiftUI.
- Separating draft input from the committed generated value.
- Handling empty input and failed QR generation gracefully.
- Resetting the interface back to a clean state.
- Sharing a generated image with the system share sheet.
- Rendering a share image that includes both the QR code and its source text.

## Project Structure

- `QRCodeGenerator/QRCodeGenerator.swift` contains the reusable QR code generation logic.
- `QRCodeGenerator/ContentView.swift` contains the app UI, preview state, reset behavior, and share flow.
- `QRCodeGenerator/QRCodeGeneratorApp.swift` is the SwiftUI app entry point.
- `QRCodeGenerator/Assets.xcassets` contains the app assets.

## Core QR Code Helper

The central teaching piece is the `QRCodeGenerator` enum:

```swift
@MainActor
enum QRCodeGenerator {
    private static let context = CIContext()

    static func image(from text: String) -> Image? {
        guard let uiImage = uiImage(from: text) else { return nil }
        return Image(uiImage: uiImage)
    }

    static func uiImage(from text: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }

        let scaledImage = outputImage.transformed(
            by: CGAffineTransform(scaleX: 12, y: 12)
        )

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
```

The app uses `uiImage(from:)` because the generated QR code is displayed in SwiftUI and also passed into a custom sharing renderer.

## User Flow

1. Enter text or a URL.
2. Tap **Generate QR Code**.
3. The app trims whitespace and commits the text as the generated value.
4. A QR code preview appears.
5. Use the share button to export a rendered image containing the QR code and source text.
6. Tap **Reset** or the clear button to return to an empty state.

## Requirements

- Xcode 16 or later
- iOS 18 or later recommended
- SwiftUI
- Core Image
- UIKit for `UIImage`, image rendering, and `UIActivityViewController`

No third-party dependencies are required.

## Build and Run

1. Open `QRCodeGenerator.xcodeproj` in Xcode.
2. Select the `QRCodeGenerator` scheme.
3. Run the app on an iOS Simulator or connected iOS device.
