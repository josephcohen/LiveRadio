import SwiftUI
import AVFoundation

@main
struct LiveRadioApp: App {
    @StateObject private var audioManager = AudioPlayerManager()
    @StateObject private var radioStore = RadioStore()
    @StateObject private var appSettings = AppSettings()

    init() {
        // Configure audio session for background playback
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.allowAirPlay, .allowBluetooth]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioManager)
                .environmentObject(radioStore)
                .environmentObject(appSettings)
                .onAppear {
                    audioManager.configure(with: radioStore)
                }
        }
    }
}
