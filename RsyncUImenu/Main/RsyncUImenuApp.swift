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
    var popover: NSPopover?
    var detachedWindow: NSWindow?

    func applicationDidFinishLaunching(_: Notification) {
        // Create the status item in the menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "cloud.fill", accessibilityDescription: "Menu Bar App")
            button.action = #selector(togglePopover)
        }

        // Create the popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 800, height: 400)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView(onDetach: detachPopover))
    }

    @objc func togglePopover() {
        if let button = statusItem?.button {
            if let popover {
                if popover.isShown {
                    popover.performClose(nil)
                } else {
                    // Only show popover if window is not detached
                    if detachedWindow == nil {
                        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                    } else {
                        // If already detached, just bring window to front
                        detachedWindow?.makeKeyAndOrderFront(nil)
                    }
                }
            }
        }
    }

    func detachPopover() {
        // Close the popover
        popover?.performClose(nil)

        // Create a new window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = "RsyncUI"
        window.center()
        window.isReleasedWhenClosed = false
        window.contentViewController = NSHostingController(rootView: ContentView(onDetach: nil))

        // Set delegate before showing window
        window.delegate = self
        detachedWindow = window

        window.makeKeyAndOrderFront(nil)
    }

    @MainActor
    @objc func windowWillClose(_ notification: Notification) {
        Task { @MainActor in
            if let window = notification.object as? NSWindow, window == detachedWindow {
                detachedWindow = nil
            }
        }
    }
}

struct ContentView: View {
    @State var executetaskpath: [Tasks] = []
    @State private var showabout: Bool = false
    var onDetach: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            // Custom header bar
            
            if executetaskpath.count == 0 {
                HStack {
                    Text("RsyncUI")
                        .font(.headline)
                    Spacer()

                    // Show detach button only if we can detach (onDetach is not nil)
                    if onDetach != nil {
                        Button(action: {
                            onDetach?()
                        }) {
                            Image(systemName: "arrow.up.right.square")
                        }
                        .buttonStyle(.plain)
                        .help("Detach to window")
                    }

                    Button("About") {
                        showabout = true
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))

                Divider()

            }
            
            // Main content
            RsyncUImenuView(executetaskpath: $executetaskpath)
                .sheet(isPresented: $showabout) {
                    AboutView()
                }
                .frame(width: 800, height: 400)
                .padding()
        }
    }
}

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!
    static let process = Logger(subsystem: subsystem, category: "process")
}
