import AppKit

class AirDropDelegate: NSObject, NSSharingServiceDelegate, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func sharingService(_ sharingService: NSSharingService, didShareItems items: [Any]) {
        NSApplication.shared.terminate(nil)
    }

    func sharingService(_ sharingService: NSSharingService, didFailToShareItems items: [Any], error: Error) {
        fputs("AirDrop failed: \(error.localizedDescription)\n", stderr)
        exit(1)
    }
}

guard CommandLine.arguments.count > 1 else {
    fputs("Usage: airdrop <file> [file ...]\n", stderr)
    exit(1)
}

let fileManager = FileManager.default
var urls: [URL] = []

for path in CommandLine.arguments.dropFirst() {
    guard fileManager.fileExists(atPath: path) else {
        fputs("File not found: \(path)\n", stderr)
        exit(1)
    }
    urls.append(URL(fileURLWithPath: path))
}

guard let service = NSSharingService(named: .sendViaAirDrop) else {
    fputs("AirDrop service not available\n", stderr)
    exit(1)
}

let delegate = AirDropDelegate()
service.delegate = delegate

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
app.delegate = delegate

service.perform(withItems: urls)

// Run the event loop until the AirDrop window is dismissed
app.run()
