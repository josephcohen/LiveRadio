import Foundation
import AVFoundation
import MediaPlayer
import Combine
import ShazamKit

@MainActor
class AudioPlayerManager: NSObject, ObservableObject {
    @Published var currentCategoryId: String = ""
    @Published var currentStation: RadioStation?
    @Published var isPlaying = false
    @Published var isLoading = false
    @Published var isPoweredOn = false
    @Published var error: String?
    @Published var audioLevels: [CGFloat] = Array(repeating: 0.0, count: 11)
    @Published var isIdentifyingTrack = false
    @Published var identifiedTrack: SHMatchedMediaItem?
    @Published var trackIDError: String?

    private var player: AVPlayer?
    private var shazamSession: SHSession?
    private var audioEngine: AVAudioEngine?
    private var playerItem: AVPlayerItem?
    private var statusObserver: NSKeyValueObservation?
    private var currentStationIndex: Int = 0
    private var levelTimer: Timer?
    private var levelPhase: Double = 0
    var radioStore: RadioStore?
    var appSettings: AppSettings?

    override init() {
        super.init()
        setupAudioSession()
        setupRemoteTransportControls()
        setupNotifications()
    }

    deinit {
        statusObserver?.invalidate()
        levelTimer?.invalidate()
    }

    // MARK: - Configuration

    func configure(with store: RadioStore, settings: AppSettings) {
        self.radioStore = store
        self.appSettings = settings

        // Set initial category to JAZZ, or first category as fallback
        if let jazzCategory = store.categories.first(where: { $0.shortName == "JAZZ" }) {
            currentCategoryId = jazzCategory.id
            if let firstStation = jazzCategory.stations.first {
                currentStation = firstStation
            }
        } else if let firstCategory = store.categories.first {
            currentCategoryId = firstCategory.id
            if let firstStation = firstCategory.stations.first {
                currentStation = firstStation
            }
        }

        // Start powered on
        powerOn()
    }

    // MARK: - Audio Session

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Power Control

    func powerOn() {
        isPoweredOn = true
        if currentStation != nil {
            playCurrentStation()
        }
    }

    func powerOff() {
        isPoweredOn = false
        stop()
    }

    func togglePower() {
        if isPoweredOn {
            powerOff()
        } else {
            powerOn()
        }
    }

    // MARK: - Playback Controls

    func playCurrentStation() {
        guard isPoweredOn, let station = currentStation else { return }
        play(station: station)
    }

    func play(station: RadioStation) {
        guard isPoweredOn else { return }

        isLoading = true
        error = nil
        currentStation = station

        // Update station index
        if let stations = radioStore?.stations(for: currentCategoryId),
           let index = stations.firstIndex(where: { $0.id == station.id }) {
            currentStationIndex = index
        }

        guard let url = URL(string: station.streamURL) else {
            isLoading = false
            error = "Invalid stream URL"
            return
        }

        // Stop current playback
        player?.pause()
        statusObserver?.invalidate()

        // Create new player item
        playerItem = AVPlayerItem(url: url)

        // Observe status
        statusObserver = playerItem?.observe(\.status, options: [.new]) { [weak self] item, _ in
            Task { @MainActor in
                switch item.status {
                case .readyToPlay:
                    self?.isLoading = false
                    self?.player?.play()
                    self?.isPlaying = true
                    self?.startLevelMonitoring()
                    self?.updateNowPlayingInfo()
                case .failed:
                    self?.isLoading = false
                    self?.isPlaying = false
                    self?.error = item.error?.localizedDescription ?? "Playback failed"
                case .unknown:
                    break
                @unknown default:
                    break
                }
            }
        }

        if player == nil {
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }
    }

    func stop() {
        player?.pause()
        isPlaying = false
        stopLevelMonitoring()
        updateNowPlayingInfo()
    }

    func resume() {
        guard isPoweredOn, currentStation != nil else { return }
        player?.play()
        isPlaying = true
        startLevelMonitoring()
        updateNowPlayingInfo()
    }

    // MARK: - Station Navigation

    func nextStation() {
        guard let stations = radioStore?.stations(for: currentCategoryId),
              !stations.isEmpty else { return }

        currentStationIndex = (currentStationIndex + 1) % stations.count
        let station = stations[currentStationIndex]
        if isPoweredOn {
            play(station: station)
        } else {
            currentStation = station
        }
    }

    func previousStation() {
        guard let stations = radioStore?.stations(for: currentCategoryId),
              !stations.isEmpty else { return }

        currentStationIndex = (currentStationIndex - 1 + stations.count) % stations.count
        let station = stations[currentStationIndex]
        if isPoweredOn {
            play(station: station)
        } else {
            currentStation = station
        }
    }

    // MARK: - Category Navigation

    func nextCategory() {
        guard let categories = radioStore?.categories,
              !categories.isEmpty else { return }

        let currentIndex = categories.firstIndex(where: { $0.id == currentCategoryId }) ?? 0
        let nextIndex = (currentIndex + 1) % categories.count
        let nextCategory = categories[nextIndex]

        changeCategory(to: nextCategory.id)
    }

    func previousCategory() {
        guard let categories = radioStore?.categories,
              !categories.isEmpty else { return }

        let currentIndex = categories.firstIndex(where: { $0.id == currentCategoryId }) ?? 0
        let prevIndex = (currentIndex - 1 + categories.count) % categories.count
        let prevCategory = categories[prevIndex]

        changeCategory(to: prevCategory.id)
    }

    func switchToCategory(_ category: RadioCategory) {
        changeCategory(to: category.id)
    }

    func changeCategory(to categoryId: String) {
        currentCategoryId = categoryId

        if let stations = radioStore?.stations(for: categoryId),
           !stations.isEmpty {
            let stationIndex: Int
            if appSettings?.shuffleOnCategoryChange ?? true {
                // Shuffle: pick a random station
                stationIndex = Int.random(in: 0..<stations.count)
            } else {
                // Play first station
                stationIndex = 0
            }
            currentStationIndex = stationIndex
            let station = stations[stationIndex]

            if isPoweredOn {
                play(station: station)
            } else {
                currentStation = station
            }
        }
    }

    // MARK: - Current Category Helper

    var currentCategory: RadioCategory? {
        radioStore?.category(for: currentCategoryId)
    }

    // MARK: - Now Playing Info

    private func updateNowPlayingInfo() {
        var info = [String: Any]()

        if let station = currentStation {
            info[MPMediaItemPropertyTitle] = station.name
            info[MPMediaItemPropertyArtist] = station.description
            info[MPNowPlayingInfoPropertyIsLiveStream] = true
        }

        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: - Remote Transport Controls

    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.resume()
            }
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.stop()
            }
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                if self?.isPlaying == true {
                    self?.stop()
                } else {
                    self?.resume()
                }
            }
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.nextStation()
            }
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.previousStation()
            }
            return .success
        }
    }

    // MARK: - Notifications

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let userInfo = notification.userInfo,
                  let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

            Task { @MainActor in
                if type == .began {
                    self?.stop()
                } else if type == .ended {
                    if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                        let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                        if options.contains(.shouldResume) {
                            self?.resume()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Share

    func shareText() -> String {
        guard let station = currentStation else { return "Shortwave" }
        return "Listening to \(station.name) on Shortwave"
    }

    func shareURL() -> URL? {
        currentStation?.websiteURL.flatMap { URL(string: $0) }
    }

    // MARK: - Audio Level Monitoring

    func startLevelMonitoring() {
        stopLevelMonitoring()
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateAudioLevels()
            }
        }
    }

    func stopLevelMonitoring() {
        levelTimer?.invalidate()
        levelTimer = nil
        // Fade out levels
        for i in 0..<audioLevels.count {
            audioLevels[i] = 0
        }
    }

    private func updateAudioLevels() {
        guard isPlaying else {
            // Fade out when not playing
            for i in 0..<audioLevels.count {
                audioLevels[i] = max(0, audioLevels[i] - 0.1)
            }
            return
        }

        levelPhase += 0.2

        // Generate realistic-looking audio levels
        // Each "band" has its own characteristics
        for i in 0..<audioLevels.count {
            let bandFreq = Double(i + 1) * 0.3
            let baseLevel: Double

            // Bass frequencies (left side) tend to be higher
            // Mid frequencies (center) are most active
            // High frequencies (right side) are more variable
            if i < 3 {
                // Bass - slower movement, higher average
                baseLevel = 0.5 + sin(levelPhase * 0.5 + Double(i)) * 0.2
            } else if i < 8 {
                // Mids - most active
                baseLevel = 0.4 + sin(levelPhase * bandFreq) * 0.3
            } else {
                // Highs - faster, more variable
                baseLevel = 0.3 + sin(levelPhase * 1.5 + Double(i) * 0.5) * 0.25
            }

            // Add randomness for natural feel
            let randomVariation = Double.random(in: -0.15...0.15)
            let targetLevel = max(0.05, min(0.95, baseLevel + randomVariation))

            // Smooth transition (attack faster than decay)
            if targetLevel > audioLevels[i] {
                audioLevels[i] = audioLevels[i] + (targetLevel - audioLevels[i]) * 0.4
            } else {
                audioLevels[i] = audioLevels[i] + (targetLevel - audioLevels[i]) * 0.15
            }
        }
    }

    // MARK: - Track Identification (Shazam)

    func identifyTrack() {
        guard !isIdentifyingTrack else { return }

        isIdentifyingTrack = true
        identifiedTrack = nil
        trackIDError = nil

        // Configure audio session for recording
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            isIdentifyingTrack = false
            trackIDError = "Failed to configure audio session"
            return
        }

        shazamSession = SHSession()
        shazamSession?.delegate = self
        audioEngine = AVAudioEngine()

        let inputNode = audioEngine!.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // Use larger buffer for better Shazam recognition
        inputNode.installTap(onBus: 0, bufferSize: 8192, format: recordingFormat) { [weak self] buffer, _ in
            self?.shazamSession?.matchStreamingBuffer(buffer, at: nil)
        }

        do {
            try audioEngine?.start()
            // Stop after 12 seconds if no match
            DispatchQueue.main.asyncAfter(deadline: .now() + 12) { [weak self] in
                if self?.isIdentifyingTrack == true && self?.identifiedTrack == nil {
                    self?.stopIdentifying()
                    self?.trackIDError = "Could not identify track"
                }
            }
        } catch {
            isIdentifyingTrack = false
            trackIDError = "Failed to start audio capture: \(error.localizedDescription)"
            // Restore playback audio session
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
        }
    }

    func stopIdentifying() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine = nil
        shazamSession = nil
        isIdentifyingTrack = false

        // Restore playback audio session
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func clearIdentifiedTrack() {
        identifiedTrack = nil
        trackIDError = nil
    }
}

// MARK: - SHSessionDelegate

extension AudioPlayerManager: SHSessionDelegate {
    nonisolated func session(_ session: SHSession, didFind match: SHMatch) {
        Task { @MainActor in
            if let firstMatch = match.mediaItems.first {
                self.identifiedTrack = firstMatch
            }
            self.stopIdentifying()
        }
    }

    nonisolated func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        Task { @MainActor in
            // Keep listening, don't stop yet
        }
    }
}
