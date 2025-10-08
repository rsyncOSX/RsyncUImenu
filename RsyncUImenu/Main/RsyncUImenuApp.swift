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
            let image = NSImage(systemSymbolName: "cloud.fill", accessibilityDescription: "RsyncUI menu app")
            let darkRed = NSColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
            let config = NSImage.SymbolConfiguration(paletteColors: [darkRed])
            button.image = image?.withSymbolConfiguration(config)
            button.image?.isTemplate = false
            button.action = #selector(toggleWindow)
        }
        
        // Create the detached window immediately
        createWindow()
    }

    func createWindow() {
        // Create a new window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 380),
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
        if let window = mainWindow {
            if window.isVisible {
                window.orderOut(nil)
            } else {
                window.makeKeyAndOrderFront(nil)
            }
        } else {
            createWindow()
        }
    }

    @MainActor
    @objc func windowWillClose(_ notification: Notification) {
        Task { @MainActor in
            if let window = notification.object as? NSWindow, window == mainWindow {
                // Hide window instead of destroying it
                window.orderOut(nil)
            }
        }
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
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .frame(width: 790, height: 40)
            }

            // Main content
            RsyncUImenuView(executetaskpath: $executetaskpath)
                .sheet(isPresented: $showabout) {
                    AboutView()
                }
                .frame(width: 800, height: 380)
                .padding()
        }
    }
}

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!
    static let process = Logger(subsystem: subsystem, category: "process")
}
