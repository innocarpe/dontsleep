import AppKit
import SwiftUI

/// One-command console: the command is fixed, Enter runs it.
/// Looks like an in-app terminal so setup stays in the window.
struct EmbeddedCommandConsole: View {
    let command: String
    let copyCommand: String
    let output: String
    let isBusy: Bool
    let isDone: Bool
    let onRun: () -> Void

    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            commandField
            Text(L10n.string("onboard.permission.hint"))
                .font(.caption)
                .foregroundStyle(.secondary)
            terminal
        }
    }

    private var commandField: some View {
        HStack(spacing: 8) {
            Text(command)
                .font(.system(size: 12, design: .monospaced))
                .lineLimit(2)
                .textSelection(.enabled)
            Spacer(minLength: 8)
            Button(copied ? L10n.string("onboard.permission.copied") : L10n.string("onboard.permission.copy")) {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(copyCommand, forType: .string)
                copied = true
            }
            .buttonStyle(.borderless)
            .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var terminal: some View {
        VStack(alignment: .leading, spacing: 4) {
            promptLine
            if !output.isEmpty {
                Text(output)
                    .foregroundStyle(isDone ? Color.green.opacity(0.9) : Color(red: 1, green: 0.45, blue: 0.4))
                    .fixedSize(horizontal: false, vertical: true)
                if isDone {
                    Text("~ ❯ ")
                        .foregroundStyle(Color.white.opacity(0.45))
                }
            }
        }
        .font(.system(size: 12, design: .monospaced))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .frame(minHeight: 120, alignment: .topLeading)
        .background(Color(red: 0.11, green: 0.11, blue: 0.12))
        .foregroundStyle(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var promptLine: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("~ ❯ ")
                .foregroundStyle(Color.white.opacity(0.45))
            Text(command)
            if !isDone && !isBusy {
                TimelineView(.periodic(from: .now, by: 0.55)) { context in
                    Rectangle()
                        .fill(Color.white.opacity(
                            Int(context.date.timeIntervalSinceReferenceDate * 2) % 2 == 0 ? 0.9 : 0
                        ))
                        .frame(width: 7, height: 13)
                        .offset(y: 1)
                }
            } else if isBusy {
                Text(" ")
                Text("…")
                    .foregroundStyle(Color.white.opacity(0.55))
            }
        }
    }
}
