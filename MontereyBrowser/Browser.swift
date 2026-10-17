import AppKit
import WebKit

private final class BrowserTab {
    let id = UUID()
    let webView = WKWebView(frame: .zero)
    var title = "New Tab"
    var urlText = ""
}

@MainActor
@main
final class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate {
    private var window: NSWindow!
    private let addressField = NSTextField()
    private let tabPicker = NSPopUpButton()
    private let pageHost = NSView()
    private var tabs: [BrowserTab] = []
    private var selectedTabID: UUID?
    private var history: [String] = UserDefaults.standard.stringArray(forKey: "RiftHistory") ?? []
    private var bookmarks: [String] = UserDefaults.standard.stringArray(forKey: "RiftBookmarks") ?? []

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.regular)
        app.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1100, height: 720),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered, defer: false)
        window.title = "Rift Browser"
        window.center()
        window.minSize = NSSize(width: 640, height: 420)
        window.contentView = makeRootView()
        window.makeKeyAndOrderFront(nil)
        newTab()
        NSApp.activate(ignoringOtherApps: true)
    }

    private func makeRootView() -> NSView {
        let root = NSView()
        let back = button("←", #selector(goBack))
        let forward = button("→", #selector(goForward))
        let reload = button("↻", #selector(reloadPage))
        let home = button("⌂", #selector(goHome))
        let addTab = button("+", #selector(newTabAction))
        let bookmark = button("☆", #selector(showBookmarks))
        let historyButton = button("History", #selector(showHistory))
        let closeTab = button("×", #selector(closeCurrentTab))
        tabPicker.target = self
        tabPicker.action = #selector(changeTab)
        tabPicker.widthAnchor.constraint(greaterThanOrEqualToConstant: 125).isActive = true
        addressField.placeholderString = "Search or enter website address"
        addressField.target = self
        addressField.action = #selector(navigateFromAddress)
        let row = NSStackView(views: [back, forward, reload, home, addressField, bookmark, historyButton, tabPicker, closeTab, addTab])
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 6
        row.translatesAutoresizingMaskIntoConstraints = false
        pageHost.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(row)
        root.addSubview(pageHost)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 10),
            row.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -10),
            row.topAnchor.constraint(equalTo: root.topAnchor, constant: 10),
            row.heightAnchor.constraint(equalToConstant: 32),
            addressField.widthAnchor.constraint(greaterThanOrEqualToConstant: 220),
            pageHost.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            pageHost.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            pageHost.topAnchor.constraint(equalTo: row.bottomAnchor, constant: 10),
            pageHost.bottomAnchor.constraint(equalTo: root.bottomAnchor)
        ])
        return root
    }

    private func button(_ title: String, _ action: Selector) -> NSButton {
        let b = NSButton(title: title, target: self, action: action)
        b.bezelStyle = .rounded
        b.setButtonType(.momentaryPushIn)
        b.widthAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        return b
    }

    @objc private func newTabAction() { newTab() }

    @objc private func closeCurrentTab() {
        guard let id = selectedTabID, let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        tabs.remove(at: index)
        if tabs.isEmpty {
            selectedTabID = nil
            pageHost.subviews.forEach { $0.removeFromSuperview() }
            newTab()
            return
        }
        selectedTabID = tabs[min(index, tabs.count - 1)].id
        showSelectedTab()
    }

    private func newTab() {
        let tab = BrowserTab()
        tab.webView.navigationDelegate = self
        tabs.append(tab)
        selectedTabID = tab.id
        refreshTabs()
        showSelectedTab()
        addressField.stringValue = ""
        if let url = URL(string: "https://www.google.com") {
            tab.webView.load(URLRequest(url: url))
        }
    }

    @objc private func changeTab() {
        let index = tabPicker.indexOfSelectedItem
        guard tabs.indices.contains(index) else { return }
        selectedTabID = tabs[index].id
        showSelectedTab()
    }

    private var selectedTab: BrowserTab? {
        tabs.first(where: { $0.id == selectedTabID })
    }

    private func showSelectedTab() {
        pageHost.subviews.forEach { $0.removeFromSuperview() }
        guard let tab = selectedTab else { return }
        tab.webView.frame = pageHost.bounds
        tab.webView.autoresizingMask = [.width, .height]
        pageHost.addSubview(tab.webView)
        addressField.stringValue = tab.urlText
        window.title = tab.title.isEmpty ? "Rift Browser" : "\(tab.title) — Rift Browser"
        refreshTabs()
    }

    private func refreshTabs() {
        tabPicker.removeAllItems()
        for tab in tabs { tabPicker.addItem(withTitle: tab.title) }
        if let id = selectedTabID, let index = tabs.firstIndex(where: { $0.id == id }) {
            tabPicker.selectItem(at: index)
        }
    }

    @objc private func navigateFromAddress() {
        guard let tab = selectedTab else { return }
        let raw = addressField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return }
        let candidate: String
        if raw.contains("://") {
            candidate = raw
        } else if raw.contains(".") && !raw.contains(" ") {
            candidate = "https://" + raw
        } else {
            candidate = "https://www.google.com/search?q=" + (raw.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? raw)
        }
        guard let url = URL(string: candidate) else { return }
        tab.urlText = url.absoluteString
        tab.webView.load(URLRequest(url: url))
        addressField.stringValue = url.absoluteString
    }

    @objc private func goBack() { selectedTab?.webView.goBack() }
    @objc private func goForward() { selectedTab?.webView.goForward() }
    @objc private func reloadPage() { selectedTab?.webView.reload() }
    @objc private func goHome() {
        addressField.stringValue = "https://www.google.com"
        navigateFromAddress()
    }

    @objc private func showBookmarks() {
        let menu = NSMenu()
        if bookmarks.isEmpty {
            menu.addItem(NSMenuItem(title: "No bookmarks yet", action: nil, keyEquivalent: ""))
        } else {
            for url in bookmarks {
                let item = NSMenuItem(title: url, action: #selector(openBookmark(_:)), keyEquivalent: "")
                item.target = self
                item.representedObject = url
                menu.addItem(item)
            }
        }
        menu.addItem(NSMenuItem.separator())
        let addItem = NSMenuItem(title: "Bookmark This Page", action: #selector(addBookmark), keyEquivalent: "d")
        addItem.target = self
        menu.addItem(addItem)
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: 0), in: pageHost)
    }

    @objc private func showHistory() {
        let menu = NSMenu()
        if history.isEmpty {
            menu.addItem(NSMenuItem(title: "No history yet", action: nil, keyEquivalent: ""))
        } else {
            for url in history.prefix(40) {
                let item = NSMenuItem(title: url, action: #selector(openHistoryItem(_:)), keyEquivalent: "")
                item.target = self
                item.representedObject = url
                menu.addItem(item)
            }
        }
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: 0), in: pageHost)
    }

    @objc private func openHistoryItem(_ sender: NSMenuItem) {
        guard let url = sender.representedObject as? String else { return }
        addressField.stringValue = url
        navigateFromAddress()
    }

    @objc private func addBookmark() {
        guard let url = selectedTab?.urlText, !url.isEmpty else { return }
        if !bookmarks.contains(url) { bookmarks.insert(url, at: 0) }
        UserDefaults.standard.set(bookmarks, forKey: "RiftBookmarks")
    }

    @objc private func openBookmark(_ sender: NSMenuItem) {
        guard let url = sender.representedObject as? String else { return }
        addressField.stringValue = url
        navigateFromAddress()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let tab = tabs.first(where: { $0.webView === webView }) else { return }
        tab.title = webView.title ?? webView.url?.host ?? "Webpage"
        tab.urlText = webView.url?.absoluteString ?? tab.urlText
        if let url = webView.url?.absoluteString, url.hasPrefix("http") {
            history.removeAll(where: { $0 == url })
            history.insert(url, at: 0)
            history = Array(history.prefix(500))
            UserDefaults.standard.set(history, forKey: "RiftHistory")
        }
        if tab.id == selectedTabID {
            addressField.stringValue = tab.urlText
            window.title = "\(tab.title) — Rift Browser"
        }
        refreshTabs()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}
