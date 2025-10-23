//
//  RsyncUImenuApp.swift
//
//  Created by Thomas Evensen on 12/01/2021.
//
// swiftlint:disable multiple_closures_with_trailing_closure

import OSLog
import SwiftUI

@main
struct YourApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem?
    var mainWindow: NSWindow?

    func applicationDidFinishLaunching(_: Notification) {
        // Create the status item in the menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "cloud.fill", accessibilityDescription: "Menu Bar App")
            // let image = NSImage(systemSymbolName: "cloud.fill", accessibilityDescription: "RsyncUI menu app")
            // let darkRed = NSColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
            // let config = NSImage.SymbolConfiguration(paletteColors: [darkRed])
            // button.image = image?.withSymbolConfiguration(config)
            // button.image?.isTemplate = false
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
        window.contentViewController = NSHostingController(rootView: ContentView())

        // Set delegate before showing window
        window.delegate = self
        mainWindow = window

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
            // Ensure window is properly shown and activated
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
        }
    }

    // This is the key fix - return false to prevent actual closing
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // Hide the window instead of closing it
        sender.orderOut(nil)
        return false
    }
}

struct ContentView: View {
    @State var executetaskpath: [Tasks] = []
    @State private var showabout: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Custom header bar
            if executetaskpath.count == 0 {
                HStack {
                    Text("RsyncUI menu app")
                        .font(.headline)
                    Spacer()

                    Button("About") {
                        showabout = true
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
                .sheet(isPresented: $showabout) {
                    AboutView()
                }
                .frame(width: 900, height: 400)
                .padding()
        }
    }
}

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!
    static let process = Logger(subsystem: subsystem, category: "process")
}
