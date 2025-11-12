import OSLog
import SwiftUI

@main
struct YourApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
        .commands {
            ExecuteCommands()
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem?
    var mainWindow: NSWindow?
    var secondWindow: NSWindow?
    var aboutWindow: NSWindow? // Add reference for about window

    func applicationDidFinishLaunching(_: Notification) {
        // Create the status item in the menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "cloud.fill", accessibilityDescription: "Menu Bar App")
            button.action = #selector(toggleWindow)
        }

        // Create the detached window immediately
        createWindow()
    }

    func createWindow() {
        // Create a new window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = "RsyncUI"
        window.center()
        window.isReleasedWhenClosed = false
        window.contentViewController = NSHostingController(rootView: ContentView(
            onOpenSecondWindow: { [weak self] in
                self?.openSecondWindow()
            },
            onOpenAbout: { [weak self] in
                self?.openAboutWindow()
            }
        ))

        // Set delegate before showing window
        window.delegate = self
        mainWindow = window

        window.makeKeyAndOrderFront(nil)
    }

    // Method to create and show second window
    func openSecondWindow() {
        // If window already exists, just bring it to front
        if let existingWindow = secondWindow {
            NSApp.activate(ignoringOtherApps: true)
            existingWindow.makeKeyAndOrderFront(nil)
            return
        }

        // Create second window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = "Second Window"

        // Position it offset from main window
        if let mainFrame = mainWindow?.frame {
            let offsetX = mainFrame.origin.x + 50
            let offsetY = mainFrame.origin.y - 50
            window.setFrameOrigin(NSPoint(x: offsetX, y: offsetY))
        } else {
            window.center()
        }

        window.isReleasedWhenClosed = false
        window.contentViewController = NSHostingController(rootView:
            SecondWindowView()
                .frame(width: 500, height: 400))
        window.delegate = self

        secondWindow = window

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    // Method to create and show about window
    func openAboutWindow() {
        // If window already exists, just bring it to front
        if let existingWindow = aboutWindow {
            NSApp.activate(ignoringOtherApps: true)
            existingWindow.makeKeyAndOrderFront(nil)
            return
        }

        // Create about window (typically smaller)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable], // No resize/minimize for about window
            backing: .buffered,
            defer: false
        )

        window.title = "About RsyncUI"

        // Center relative to main window or screen
        if let mainWindow {
            let mainFrame = mainWindow.frame
            let x = mainFrame.origin.x + (mainFrame.width - 400) / 2
            let y = mainFrame.origin.y + (mainFrame.height - 300) / 2
            window.setFrameOrigin(NSPoint(x: x, y: y))
        } else {
            window.center()
        }

        window.isReleasedWhenClosed = false
        window.contentViewController = NSHostingController(rootView:
            AboutView()
                .frame(width: 500, height: 400))
        window.delegate = self

        aboutWindow = window

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    @objc func toggleWindow() {
        guard let window = mainWindow else {
            createWindow()
            return
        }

        if window.isVisible {
            window.orderOut(nil)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
        }
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // Hide the window instead of closing it
        sender.orderOut(nil)
        return false
    }
}

struct ContentView: View {
    @State var executetaskpath: [Tasks] = []
    let onOpenSecondWindow: () -> Void
    let onOpenAbout: () -> Void // Add callback for about

    var body: some View {
        VStack(spacing: 0) {
            // Custom header bar
            if executetaskpath.count == 0 {
                HStack {
                    Text("RsyncUI menu app")
                        .font(.headline)
                    Spacer()

                    Button("About") {
                        onOpenAbout() // Open about window instead of sheet
                    }
                    .buttonStyle(.plain)

                    Button("Open Second Window") {
                        onOpenSecondWindow()
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                .frame(width: 790, height: 40)
            }

            // Main content
            RsyncUImenuView(executetaskpath: $executetaskpath)
                .frame(width: 900, height: 400)
                .padding()
        }
    }
}

// Example second window view
struct SecondWindowView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Text("This is the second window")
                .font(.title)
            Text("You can put any content here")
                .foregroundColor(.secondary)

            if #available(macOS 26.0, *) {
                Button("Close", role: .close) {
                    dismiss()
                }
                .buttonStyle(RefinedGlassButtonStyle())

            } else {
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!
    static let process = Logger(subsystem: subsystem, category: "process")
}
