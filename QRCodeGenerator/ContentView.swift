//
//----------------------------------------------
// Original project: QRCodeGenerator
//
// Follow me on Mastodon: https://iosdev.space/@StewartLynch
// Follow me on Threads: https://www.threads.net/@stewartlynch
// Follow me on Bluesky: https://bsky.app/profile/stewartlynch.bsky.social
// Follow me on X: https://x.com/StewartLynch
// Follow me on LinkedIn: https://linkedin.com/in/StewartLynch
// Email: slynch@createchsol.com
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var text = ""
    @State private var qrCodeText = ""
    @State private var isSharingPresented = false
    @FocusState private var isEditorFocused: Bool
    
    private var qrCodeImage: UIImage? {
        guard !qrCodeText.isEmpty else { return nil }
        return QRCodeGenerator.uiImage(from: qrCodeText)
    }
    
    private var shareImage: UIImage? {
        guard let qrImage = qrCodeImage else { return nil }
        return ShareImageRenderer.makeShareImage(qrImage: qrImage, text: qrCodeText)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("QR Code Content") {
                    ZStack(alignment: .topTrailing) {
                        TextEditor(text: $text)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .frame(minHeight: 96)
                            .padding(.trailing, 24)
                            .focused($isEditorFocused)

                        if text.isEmpty {
                            Text("Enter text or a URL")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                                .allowsHitTesting(false)
                        }

                        if !text.isEmpty || !qrCodeText.isEmpty {
                            Button {
                                text = ""
                                qrCodeText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Clear text")
                            .padding(.top, 8)
                        }
                    }

                    Button {
                        isEditorFocused = false

                        if !qrCodeText.isEmpty {
                            text = ""
                            qrCodeText = ""
                            return
                        }

                        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedText.isEmpty else { return }
                        qrCodeText = trimmedText
                    } label: {
                        Label(
                            qrCodeText.isEmpty ? "Generate QR Code" : "Reset",
                            systemImage: qrCodeText.isEmpty ? "qrcode" : "arrow.counterclockwise"
                        )
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(qrCodeText.isEmpty && text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if !qrCodeText.isEmpty {
                    Section {
                        VStack(spacing: 20) {
                            if let image = qrCodeImage {
                                Image(uiImage: image)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 260, height: 260)
                                    .padding(20)
                                    .background(.white, in: .rect(cornerRadius: 8))
                                    .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
                                    .frame(maxWidth: .infinity)
                            } else {
                                ContentUnavailableView(
                                    "QR Code Unavailable",
                                    systemImage: "qrcode",
                                    description: Text("Enter shorter text and try again.")
                                )
                            }

                            Text(qrCodeText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(4)
                        }
                        .padding(.vertical, 12)
                    }
                }
            }
            .navigationTitle("QR Code Generator")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isEditorFocused = false
                        isSharingPresented = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(shareImage == nil)
                }
            }
            .sheet(isPresented: $isSharingPresented) {
                if let image = shareImage {
                    ActivityViewController(activityItems: [image])
                }
            }
        }
    }
}

private enum ShareImageRenderer {
    static func makeShareImage(qrImage: UIImage, text: String) -> UIImage? {
        let margin: CGFloat = 24
        let spacing: CGFloat = 16
        let qrSize = qrImage.size
        let textBlockWidth = qrSize.width
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineBreakMode = .byWordWrapping

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.label,
            .paragraphStyle: paragraph
        ]

        let textRect = NSString(string: text).boundingRect(
            with: CGSize(width: textBlockWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        ).integral

        let canvasSize = CGSize(
            width: qrSize.width + margin * 2,
            height: qrSize.height + spacing + textRect.height + margin * 2
        )

        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        return renderer.image { context in
            UIColor.systemBackground.setFill()
            context.fill(CGRect(origin: .zero, size: canvasSize))

            let qrOrigin = CGPoint(
                x: (canvasSize.width - qrSize.width) / 2,
                y: margin
            )
            qrImage.draw(in: CGRect(origin: qrOrigin, size: qrSize))

            let textOrigin = CGPoint(
                x: (canvasSize.width - textBlockWidth) / 2,
                y: qrOrigin.y + qrSize.height + spacing
            )
            NSString(string: text).draw(
                in: CGRect(origin: textOrigin, size: CGSize(width: textBlockWidth, height: textRect.height)),
                withAttributes: attributes
            )
        }
    }
}

private struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView()
}
