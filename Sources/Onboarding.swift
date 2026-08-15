import AppKit
import Combine
import SwiftUI

final class OnboardingController: NSObject {
    static let completedKey = "onboarding.completed"

    static var isCompleted: Bool {
        UserDefaults.standard.bool(forKey: completedKey)
    }

    static func markCompleted() {
        UserDefaults.standard.set(true, forKey: completedKey)
    }

    private var window: NSWindow?
    private var host: NSHostingController<OnboardingView>?
    private var model: OnboardingModel?
    private var lastContentSize: NSSize = .zero
    var onFinish: (() -> Void)?

    static let contentWidth: CGFloat = 460

    func present(kind: OnboardingModel.Kind, needsHelper: Bool) {
        if window != nil {
            window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let model = OnboardingModel(kind: kind, needsHelper: needsHelper)
        model.onRequestHelper = { [weak self] in
            self?.installHelper(model: model)
        }
        model.onClose = { [weak self] in
            self?.close()
        }
        model.onNeedsRefit = { [weak self] in
            DispatchQueue.main.async { self?.refit() }
        }
        self.model = model

        let host = NSHostingController(rootView: OnboardingView(model: model))
        if #available(macOS 13.0, *) {
            host.sizingOptions = [.intrinsicContentSize]
        }
        self.host = host
        let window = NSWindow(contentViewController: host)
        window.title = AppIdentity.name
        window.styleMask = [.titled, .closable]
        window.setContentSize(NSSize(width: Self.contentWidth, height: 320))
        window.center()
        window.isReleasedWhenClosed = false
        window.delegate = self
        self.window = window

        NSApp.setActivationPolicy(.regular)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async { [weak self] in
            self?.refit()
        }
    }

    private func installHelper(model: OnboardingModel) {
        do {
            try Sudoers.install()
            model.helperReady = true
            model.helperError = nil
            if !LoginItem.isEnabled {
                LoginItem.setEnabled(true)
                model.startAtLogin = true
            }
            model.goForward()
        } catch {
            model.helperError = error.localizedDescription
        }
    }

    private func refit() {
        guard let window, let host else { return }
        let proposal = NSSize(width: Self.contentWidth, height: 4000)
        let fit = host.sizeThatFits(in: proposal)
        let size = NSSize(
            width: Self.contentWidth,
            height: max(200, ceil(fit.height) + 20)
        )
        if abs(size.height - lastContentSize.height) < 1,
           abs(size.width - lastContentSize.width) < 1 {
            return
        }
        lastContentSize = size
        let old = window.frame
        window.setContentSize(size)
        var frame = window.frame
        frame.origin.x = old.midX - frame.width / 2
        frame.origin.y = old.midY - frame.height / 2
        window.setFrame(frame, display: true, animate: false)
    }

    private func close() {
        OnboardingController.markCompleted()
        LoginItem.setEnabled(model?.startAtLogin ?? LoginItem.isEnabled)
        window?.orderOut(nil)
        window = nil
        host = nil
        model = nil
        NSApp.setActivationPolicy(.accessory)
        onFinish?()
    }
}

extension OnboardingController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        OnboardingController.markCompleted()
        NSApp.setActivationPolicy(.accessory)
        window = nil
        host = nil
        model = nil
        onFinish?()
    }
}

final class OnboardingModel: ObservableObject {
    enum Step: Int, CaseIterable {
        case welcome
        case permission
        case usage
        case safety
    }

    @Published var step: Step
    @Published var helperReady: Bool
    @Published var helperError: String?
    @Published var startAtLogin: Bool
    @Published var busy = false

    var onRequestHelper: (() -> Void)?
    var onClose: (() -> Void)?
    var onNeedsRefit: (() -> Void)?

    enum Kind {
        case firstLaunch
        case howTo
        case permission
    }

    private let kind: Kind
    private let includePermission: Bool

    init(kind: Kind, needsHelper: Bool) {
        self.kind = kind
        includePermission = needsHelper || kind == .permission
        helperReady = !needsHelper
        startAtLogin = LoginItem.isEnabled || kind == .firstLaunch
        switch kind {
        case .firstLaunch:
            step = .welcome
        case .howTo:
            step = .usage
        case .permission:
            step = .permission
        }
    }

    var visibleSteps: [Step] {
        switch kind {
        case .howTo:
            return [.usage, .safety]
        case .permission:
            return [.permission]
        case .firstLaunch:
            return Step.allCases.filter { $0 != .permission || includePermission }
        }
    }

    var stepIndex: Int {
        visibleSteps.firstIndex(of: step) ?? 0
    }

    var stepCount: Int { visibleSteps.count }

    var isLast: Bool { step == .safety }

    func goForward() {
        helperError = nil
        switch step {
        case .welcome:
            step = includePermission && !helperReady ? .permission : .usage
        case .permission:
            if kind == .permission {
                onClose?()
            } else {
                step = .usage
            }
        case .usage:
            step = .safety
        case .safety:
            onClose?()
        }
    }

    func goBack() {
        helperError = nil
        switch step {
        case .welcome:
            break
        case .permission:
            step = .welcome
        case .usage:
            step = includePermission && !helperReady ? .permission : .welcome
        case .safety:
            step = .usage
        }
    }
}

struct OnboardingView: View {
    @ObservedObject var model: OnboardingModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            stepBody
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            Divider()
            footer
        }
        .frame(width: OnboardingController.contentWidth)
        .fixedSize(horizontal: true, vertical: true)
        .onChange(of: model.step) { _, _ in model.onNeedsRefit?() }
        .onChange(of: model.helperError) { _, _ in model.onNeedsRefit?() }
        .onAppear { model.onNeedsRefit?() }
    }

    private var header: some View {
        HStack(spacing: 12) {
            if let icon = NSApp.applicationIconImage {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title3.weight(.semibold))
                Text(String(format: L10n.string("onboard.progress"), model.stepIndex + 1, model.stepCount))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private var title: String {
        switch model.step {
        case .welcome: return L10n.string("onboard.welcome.title")
        case .permission: return L10n.string("onboard.permission.title")
        case .usage: return L10n.string("onboard.usage.title")
        case .safety: return L10n.string("onboard.safety.title")
        }
    }

    @ViewBuilder
    private var stepBody: some View {
        switch model.step {
        case .welcome:
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.string("onboard.welcome.body1"))
                Text(L10n.string("onboard.welcome.body2"))
                    .foregroundStyle(.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)
        case .permission:
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.string("onboard.permission.why"))
                Text(L10n.string("onboard.permission.what"))
                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.string("onboard.permission.cmdOn"))
                    Text(L10n.string("onboard.permission.cmdOff"))
                }
                .font(.system(.caption, design: .monospaced))
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                Text(L10n.string("onboard.permission.scope"))
                    .foregroundStyle(.secondary)
                if let err = model.helperError {
                    Text(err)
                        .foregroundStyle(.red)
                        .font(.callout)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        case .usage:
            VStack(alignment: .leading, spacing: 16) {
                usageRow(on: true, text: L10n.string("onboard.usage.on"))
                usageRow(on: false, text: L10n.string("onboard.usage.off"))
                Text(L10n.string("onboard.usage.click"))
                Text(L10n.string("onboard.usage.menu"))
            }
            .fixedSize(horizontal: false, vertical: true)
        case .safety:
            VStack(alignment: .leading, spacing: 16) {
                Text(L10n.string("onboard.safety.body"))
                Toggle(isOn: $model.startAtLogin) {
                    Text(L10n.string("onboard.safety.login"))
                }
                .toggleStyle(.checkbox)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func usageRow(on: Bool, text: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(nsImage: StatusIcon.image(on: on))
                .renderingMode(.template)
                .resizable()
                .frame(width: 22, height: 22)
                .padding(8)
                .background(Color(nsColor: .quaternaryLabelColor).opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text(text)
        }
    }

    private var footer: some View {
        HStack {
            if model.step != .welcome {
                Button(L10n.string("onboard.back")) { model.goBack() }
                    .keyboardShortcut(.cancelAction)
            }
            Spacer()
            if model.step == .permission && !model.helperReady {
                Button(L10n.string("onboard.later")) { model.goForward() }
                Button(L10n.string("onboard.allow")) { model.onRequestHelper?() }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
            } else {
                Button(model.isLast ? L10n.string("onboard.done") : L10n.string("onboard.continue")) {
                    if model.isLast {
                        model.onClose?()
                    } else {
                        model.goForward()
                    }
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
