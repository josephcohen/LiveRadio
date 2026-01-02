import Foundation
import SwiftUI

// MARK: - Radio Station

struct RadioStation: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let streamURL: String
    let websiteURL: String?
    let logoURL: String?
    let location: String?

    init(id: String = UUID().uuidString, name: String, description: String = "", streamURL: String, websiteURL: String? = nil, logoURL: String? = nil, location: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.streamURL = streamURL
        self.websiteURL = websiteURL
        self.logoURL = logoURL
        self.location = location
    }
}

// MARK: - Radio Category

struct RadioCategory: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var shortName: String
    var icon: String
    var stations: [RadioStation]

    init(id: String = UUID().uuidString, name: String, shortName: String, icon: String, stations: [RadioStation] = []) {
        self.id = id
        self.name = name
        self.shortName = shortName.uppercased()
        self.icon = icon
        self.stations = stations
    }
}

// MARK: - Player State

enum PlayerState {
    case stopped
    case loading
    case playing
    case error(String)
}

// MARK: - Category Icons

struct CategoryIcons {
    static let all: [(name: String, icon: String)] = [
        ("News", "newspaper"),
        ("Jazz", "music.quarternote.3"),
        ("Classical", "music.note.list"),
        ("Rock", "guitars"),
        ("Electronic", "waveform"),
        ("Chill", "leaf"),
        ("Talk", "mic"),
        ("World", "globe"),
        ("Pop", "star"),
        ("Hip Hop", "headphones"),
        ("Country", "music.mic"),
        ("Sports", "sportscourt"),
        ("Radio", "radio"),
        ("Waves", "wave.3.right"),
        ("Heart", "heart"),
        ("Bolt", "bolt"),
    ]
}

// MARK: - App Settings

enum AppearanceMode: String, CaseIterable, Codable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
}

enum ColorScheme: String, CaseIterable, Codable {
    case orange = "Orange"
    case blue = "Blue"
    case green = "Green"
    case purple = "Purple"
    case red = "Red"
    case pink = "Pink"
    case teal = "Teal"
    case yellow = "Yellow"

    var color: Color {
        switch self {
        case .orange: return Color.orange
        case .blue: return Color.blue
        case .green: return Color.green
        case .purple: return Color.purple
        case .red: return Color.red
        case .pink: return Color.pink
        case .teal: return Color.teal
        case .yellow: return Color.yellow
        }
    }
}

enum VisualizationStyle: String, CaseIterable, Codable {
    case bars = "Bars"
    case wave = "Wave"
    case pulse = "Pulse"
    case matrix = "Matrix"
    case spectrum = "Spectrum"
    case circle = "Circle"

    var description: String {
        switch self {
        case .bars: return "Classic equalizer bars"
        case .wave: return "Flowing wave pattern"
        case .pulse: return "Pulsing from center"
        case .matrix: return "Random dot matrix"
        case .spectrum: return "Frequency spectrum"
        case .circle: return "Circular ripples"
        }
    }
}

@MainActor
class AppSettings: ObservableObject {
    @Published var appearanceMode: AppearanceMode {
        didSet { save() }
    }
    @Published var colorScheme: ColorScheme {
        didSet { save() }
    }
    @Published var visualizationStyle: VisualizationStyle {
        didSet { save() }
    }

    private let appearanceKey = "appearanceMode"
    private let colorSchemeKey = "colorScheme"
    private let visualizationKey = "visualizationStyle"

    init() {
        if let data = UserDefaults.standard.string(forKey: appearanceKey),
           let mode = AppearanceMode(rawValue: data) {
            self.appearanceMode = mode
        } else {
            self.appearanceMode = .dark
        }

        if let data = UserDefaults.standard.string(forKey: colorSchemeKey),
           let scheme = ColorScheme(rawValue: data) {
            self.colorScheme = scheme
        } else {
            self.colorScheme = .orange
        }

        if let data = UserDefaults.standard.string(forKey: visualizationKey),
           let style = VisualizationStyle(rawValue: data) {
            self.visualizationStyle = style
        } else {
            self.visualizationStyle = .bars
        }
    }

    private func save() {
        UserDefaults.standard.set(appearanceMode.rawValue, forKey: appearanceKey)
        UserDefaults.standard.set(colorScheme.rawValue, forKey: colorSchemeKey)
        UserDefaults.standard.set(visualizationStyle.rawValue, forKey: visualizationKey)
    }
}

// MARK: - Suggested Stations

struct SuggestedStations {
    static let all: [RadioStation] = [
        // Popular international stations
        RadioStation(name: "Radio Paradise", description: "Eclectic DJ-curated mix", streamURL: "https://stream.radioparadise.com/aac-320", location: "Paradise, CA"),
        RadioStation(name: "SomaFM Groove Salad", description: "Ambient & downtempo", streamURL: "https://ice4.somafm.com/groovesalad-256-mp3", location: "San Francisco, CA"),
        RadioStation(name: "SomaFM DEF CON", description: "Music for hackers", streamURL: "https://ice4.somafm.com/defcon-256-mp3", location: "San Francisco, CA"),
        RadioStation(name: "BBC Radio 1", description: "New music & entertainment", streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_one", location: "London, UK"),
        RadioStation(name: "BBC Radio 2", description: "Great music variety", streamURL: "https://stream.live.vc.bbcmedia.co.uk/bbc_radio_two", location: "London, UK"),
        RadioStation(name: "Triple J", description: "Australian youth radio", streamURL: "https://live-radio01.mediahubaustralia.com/2TJW/mp3/", location: "Sydney, Australia"),
        RadioStation(name: "NTS Radio 2", description: "Underground music", streamURL: "https://stream-relay-geo.ntslive.net/stream2", location: "London, UK"),
        RadioStation(name: "Dublab", description: "Future roots radio", streamURL: "https://dublab.out.airtime.pro/dublab_a", location: "Los Angeles, CA"),
        RadioStation(name: "KCRW Eclectic24", description: "24/7 music mix", streamURL: "https://kcrw.streamguys1.com/kcrw_192k_mp3_e24", location: "Santa Monica, CA"),
        RadioStation(name: "FIP Groove", description: "Funk, soul & groove", streamURL: "https://icecast.radiofrance.fr/fipgroove-midfi.mp3", location: "Paris, France"),
        RadioStation(name: "SomaFM Drone Zone", description: "Atmospheric ambient", streamURL: "https://ice4.somafm.com/dronezone-256-mp3", location: "San Francisco, CA"),
        RadioStation(name: "SomaFM Indie Pop", description: "New indie pop", streamURL: "https://ice4.somafm.com/indiepop-128-mp3", location: "San Francisco, CA"),
        RadioStation(name: "FluxFM", description: "Berlin alternative", streamURL: "https://streams.fluxfm.de/live/mp3-320/audio/", location: "Berlin, Germany"),
        RadioStation(name: "Radio Nova", description: "Eclectic French", streamURL: "https://novazz.ice.infomaniak.ch/novazz-128.mp3", location: "Paris, France"),
        RadioStation(name: "WFMU", description: "Freeform radio", streamURL: "https://stream0.wfmu.org/freeform-128k", location: "Jersey City, NJ"),
        RadioStation(name: "Resonance FM", description: "London arts radio", streamURL: "https://stream.resonance.fm/resonance", location: "London, UK"),
        RadioStation(name: "SomaFM Secret Agent", description: "Spy soundtrack", streamURL: "https://ice4.somafm.com/secretagent-256-mp3", location: "San Francisco, CA"),
        RadioStation(name: "SomaFM Folk Forward", description: "Contemporary folk", streamURL: "https://ice4.somafm.com/folkfwd-128-mp3", location: "San Francisco, CA"),
        RadioStation(name: "Worldwide FM", description: "Global sounds", streamURL: "https://worldwidefm.out.airtime.pro/worldwidefm_a", location: "London, UK"),
        RadioStation(name: "Le Mellotron", description: "Vinyl selections", streamURL: "https://lemellotron.out.airtime.pro/lemellotron_b", location: "Paris, France"),
    ]
}
