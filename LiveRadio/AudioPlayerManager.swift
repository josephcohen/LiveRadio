import Foundation
import AVFoundation
import MediaPlayer
import Combine

@MainActor
class AudioPlayerManager: ObservableObject {
    @Published var currentCategoryId: String = ""
    @Published var currentStation: RadioStation?
    @Published var isPlaying = false
    @Published var isLoading = false
    @Published var isPoweredOn = false
    @Published var error: String?

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var statusObserver: NSKeyValueObservation?
    private var currentStationIndex: Int = 0
    var radioStore: RadioStore?

    init() {
        setupAudioSession()
        setupRemoteTransportControls()
        setupNotifications()
    }

    deinit {
        statusObserver?.invalidate()
    }

    // MARK: - Configuration

    func configure(with store: RadioStore) {
        self.radioStore = store

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
        updateNowPlayingInfo()
    }

    func resume() {
        guard isPoweredOn, currentStation != nil else { return }
        player?.play()
        isPlaying = true
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
            // Shuffle: pick a random station
            let randomIndex = Int.random(in: 0..<stations.count)
            currentStationIndex = randomIndex
            let randomStation = stations[randomIndex]

            if isPoweredOn {
                play(station: randomStation)
            } else {
                currentStation = randomStation
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
        guard let station = currentStation else { return "Live Radio" }
        return "Listening to \(station.name) on Live Radio"
    }

    func shareURL() -> URL? {
        currentStation?.websiteURL.flatMap { URL(string: $0) }
    }
}
