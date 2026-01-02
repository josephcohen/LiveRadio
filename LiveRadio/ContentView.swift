import SwiftUI

struct ContentView: View {
    @EnvironmentObject var audioManager: AudioPlayerManager
    @EnvironmentObject var radioStore: RadioStore
    @EnvironmentObject var appSettings: AppSettings
    @State private var showingSettings = false
    @State private var showingInfo = false
    @State private var showingStationList = false
    @State private var selectedCategoryForList: RadioCategory?
    @State private var dialRotation: Double = 0

    private var backgroundColor: Color {
        appSettings.appearanceMode == .light ? Color(white: 0.95) : Color(red: 0.08, green: 0.08, blue: 0.10)
    }

    private var accentColor: Color {
        appSettings.colorScheme.color
    }

    private func updateDialRotation() {
        guard let currentCategory = audioManager.currentCategory,
              let index = radioStore.categories.firstIndex(where: { $0.id == currentCategory.id }) else { return }
        let degreesPerCategory = 360.0 / Double(radioStore.categories.count)
        let targetRotation = Double(index) * degreesPerCategory
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            dialRotation = targetRotation
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top bar with settings and info
                    HStack {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(white: 0.5))
                        }

                        Spacer()

                        // Station info button
                        Button(action: { showingInfo = true }) {
                            Image(systemName: "radio")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(white: 0.5))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                    Spacer()
                        .frame(height: 12)

                    // Speaker Grille
                    SpeakerGrille(
                        isPlaying: audioManager.isPlaying && audioManager.isPoweredOn,
                        accentColor: accentColor,
                        visualizationStyle: appSettings.visualizationStyle,
                        isLightMode: appSettings.appearanceMode == .light
                    )
                    .frame(width: geometry.size.width * 0.75, height: geometry.size.width * 0.65)

                    Spacer()

                    // Dial Control
                    DialView(
                        currentCategory: audioManager.currentCategory,
                        categories: radioStore.categories,
                        rotation: $dialRotation,
                        isPoweredOn: audioManager.isPoweredOn,
                        onCenterTap: {
                            if audioManager.isPoweredOn {
                                audioManager.nextCategory()
                            }
                        },
                        onCategoryTap: { category in
                            if audioManager.currentCategory?.id == category.id {
                                // Already on this category, show stream list
                                selectedCategoryForList = category
                                showingStationList = true
                            } else {
                                // Switch to this category
                                audioManager.switchToCategory(category)
                            }
                        }
                    )
                    .frame(width: geometry.size.width * 0.75, height: geometry.size.width * 0.75)
                    .onChange(of: audioManager.currentCategory?.id) { _, _ in
                        updateDialRotation()
                    }
                    .onAppear {
                        updateDialRotation()
                    }

                    Spacer()

                    Spacer()
                        .frame(height: 16)

                    // Control Bar
                    ControlBar(
                        isPoweredOn: audioManager.isPoweredOn,
                        isPlaying: audioManager.isPlaying,
                        isLoading: audioManager.isLoading,
                        accentColor: accentColor,
                        onPowerToggle: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                audioManager.togglePower()
                            }
                        },
                        onPrevious: { audioManager.previousStation() },
                        onNext: { audioManager.nextStation() }
                    )
                    .padding(.horizontal, 32)
                    .padding(.bottom, 8)
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(radioStore)
                .environmentObject(audioManager)
                .environmentObject(appSettings)
        }
        .sheet(isPresented: $showingInfo) {
            InfoSheet(
                station: audioManager.currentStation,
                category: audioManager.currentCategory,
                shareText: audioManager.shareText(),
                shareURL: audioManager.shareURL()
            )
            .environmentObject(audioManager)
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingStationList) {
            if let category = selectedCategoryForList {
                StationListSheet(category: category, accentColor: accentColor)
                    .environmentObject(audioManager)
                    .environmentObject(radioStore)
                    .presentationDetents([.medium, .large])
            }
        }
        .preferredColorScheme(appSettings.appearanceMode == .system ? nil : (appSettings.appearanceMode == .dark ? .dark : .light))
    }
}

// MARK: - Speaker Grille

struct SpeakerGrille: View {
    let isPlaying: Bool
    let accentColor: Color
    let visualizationStyle: VisualizationStyle
    let isLightMode: Bool

    @State private var animationPhase: Double = 0
    @State private var visualizerMode = false
    @State private var audioLevels: [CGFloat] = Array(repeating: 0.5, count: 11)
    @State private var matrixStates: [[Bool]] = Array(repeating: Array(repeating: false, count: 11), count: 10)
    @State private var timer: Timer?

    private let rows = 10
    private let cols = 11

    private var grillColor: Color {
        isLightMode ? Color(white: 0.75) : Color(red: 0.25, green: 0.25, blue: 0.28)
    }

    var body: some View {
        GeometryReader { geometry in
            let spacingX = geometry.size.width / CGFloat(cols + 1)
            let spacingY = geometry.size.height / CGFloat(rows + 1)
            let centerX = CGFloat(cols) / 2.0
            let centerY = CGFloat(rows) / 2.0

            Canvas { context, size in
                for row in 0..<rows {
                    for col in 0..<cols {
                        let x = spacingX * CGFloat(col + 1)
                        let y = spacingY * CGFloat(row + 1)

                        var radius: CGFloat = min(spacingX, spacingY) * 0.3
                        var dotColor = grillColor.opacity(0.85)

                        if isPlaying && visualizerMode {
                            switch visualizationStyle {
                            case .bars:
                                // Classic equalizer bars
                                let level = audioLevels[col]
                                let rowFromBottom = CGFloat(rows - 1 - row)
                                let threshold = level * CGFloat(rows)
                                if rowFromBottom < threshold {
                                    let intensity = 1.0 - (rowFromBottom / CGFloat(rows))
                                    radius *= 1.0 + (level * 0.4)
                                    dotColor = accentColor.opacity(0.6 + intensity * 0.4)
                                }

                            case .wave:
                                // Flowing wave pattern
                                let wavePhase = animationPhase + Double(col) * 0.4
                                let waveHeight = (sin(wavePhase) + 1) / 2 * CGFloat(rows)
                                let rowFromBottom = CGFloat(rows - 1 - row)
                                if abs(rowFromBottom - waveHeight) < 1.5 {
                                    radius *= 1.3
                                    dotColor = accentColor.opacity(0.9)
                                } else if rowFromBottom < waveHeight {
                                    dotColor = accentColor.opacity(0.3)
                                }

                            case .pulse:
                                // Pulsing from center
                                let distance = sqrt(pow(CGFloat(row) - centerY, 2) + pow(CGFloat(col) - centerX, 2))
                                let maxDist = sqrt(centerX * centerX + centerY * centerY)
                                let pulseWave = (sin(animationPhase * 2 - distance * 0.8) + 1) / 2
                                if pulseWave > 0.5 {
                                    radius *= 1.0 + pulseWave * 0.5
                                    dotColor = accentColor.opacity(pulseWave)
                                }

                            case .matrix:
                                // Random dot matrix
                                if matrixStates[row][col] {
                                    radius *= 1.2
                                    dotColor = accentColor.opacity(0.8)
                                }

                            case .spectrum:
                                // Frequency spectrum (mirrored)
                                let mirrorCol = col < cols / 2 ? col : cols - 1 - col
                                let level = audioLevels[mirrorCol]
                                let rowFromCenter = abs(CGFloat(row) - centerY)
                                let threshold = level * centerY
                                if rowFromCenter < threshold {
                                    let intensity = 1.0 - (rowFromCenter / centerY)
                                    radius *= 1.0 + (level * 0.3)
                                    dotColor = accentColor.opacity(0.5 + intensity * 0.5)
                                }

                            case .circle:
                                // Circular ripples
                                let distance = sqrt(pow(CGFloat(row) - centerY, 2) + pow(CGFloat(col) - centerX, 2))
                                let ripple = sin(animationPhase * 3 - distance * 1.2)
                                if ripple > 0.3 {
                                    radius *= 1.0 + ripple * 0.4
                                    dotColor = accentColor.opacity(0.4 + ripple * 0.5)
                                }
                            }
                        } else if isPlaying {
                            // Simple wave animation when visualizer off
                            let distance = sqrt(pow(CGFloat(row) - centerY, 2) + pow(CGFloat(col) - centerX, 2))
                            let wave = sin(animationPhase + distance * 0.5) * 0.12 + 1.0
                            radius *= wave
                        }

                        let rect = CGRect(
                            x: x - radius,
                            y: y - radius,
                            width: radius * 2,
                            height: radius * 2
                        )

                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(dotColor)
                        )
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if isPlaying {
                    visualizerMode.toggle()
                    if visualizerMode {
                        startVisualizerTimer()
                    } else {
                        stopVisualizerTimer()
                    }
                }
            }
        }
        .onAppear {
            if isPlaying {
                startAnimation()
            }
        }
        .onChange(of: isPlaying) { _, playing in
            if playing {
                startAnimation()
                if visualizerMode {
                    startVisualizerTimer()
                }
            } else {
                stopVisualizerTimer()
            }
        }
        .onDisappear {
            stopVisualizerTimer()
        }
    }

    private func startAnimation() {
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            animationPhase = .pi * 2
        }
    }

    private func startVisualizerTimer() {
        stopVisualizerTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
            withAnimation(.easeOut(duration: 0.08)) {
                // Update audio levels
                for i in 0..<audioLevels.count {
                    let base = 0.3 + Double(i % 3) * 0.1
                    let random = Double.random(in: -0.3...0.4)
                    let newLevel = min(1.0, max(0.1, audioLevels[i] * 0.6 + (base + random) * 0.4))
                    audioLevels[i] = CGFloat(newLevel)
                }

                // Update matrix states for matrix visualization
                for row in 0..<rows {
                    for col in 0..<cols {
                        if Double.random(in: 0...1) < 0.1 {
                            matrixStates[row][col].toggle()
                        }
                    }
                }

                // Update animation phase
                animationPhase += 0.15
            }
        }
    }

    private func stopVisualizerTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Dial View

struct DialView: View {
    let currentCategory: RadioCategory?
    let categories: [RadioCategory]
    @Binding var rotation: Double
    let isPoweredOn: Bool
    let onCenterTap: () -> Void
    let onCategoryTap: (RadioCategory) -> Void

    @State private var dragStartAngle: Double = 0
    @State private var dragStartRotation: Double = 0

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width/2, y: geometry.size.height/2)

            // Define clear hierarchy of sizes - all fit within the frame
            let outerRingDiameter = size * 0.92
            let labelCircleRadius = size * 0.40
            let innerDialDiameter = size * 0.52
            let centerButtonDiameter = size * 0.22

            let categoryCount = categories.count

            ZStack {

                // LAYER 2: Category labels positioned around the circle
                ForEach(0..<categoryCount, id: \.self) { index in
                    let category = categories[index]
                    let angle = -90.0 + (Double(index) * (360.0 / Double(categoryCount)))
                    let angleRadians = angle * .pi / 180.0

                    let xPos = center.x + cos(angleRadians) * labelCircleRadius
                    let yPos = center.y + sin(angleRadians) * labelCircleRadius

                    Button(action: {
                        if isPoweredOn {
                            onCategoryTap(category)
                        }
                    }) {
                        Text(category.shortName)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(category.id == currentCategory?.id ? .orange : Color(white: 0.55))
                    }
                    .buttonStyle(.plain)
                    .position(x: xPos, y: yPos)
                }

                // LAYER 3: Inner rotating dial
                ZStack {
                    // Dial background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.18, green: 0.18, blue: 0.20),
                                    Color(red: 0.12, green: 0.12, blue: 0.14)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)

                    // Dial border
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)

                    // Notch indicator on the dial
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 3, height: innerDialDiameter * 0.15)
                        .offset(y: -innerDialDiameter * 0.35)
                        .rotationEffect(.degrees(rotation))
                }
                .frame(width: innerDialDiameter, height: innerDialDiameter)

                // LAYER 4: Center channel button
                Button(action: onCenterTap) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(white: 0.22), Color(white: 0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)

                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)

                        Image(systemName: currentCategory?.icon ?? "radio")
                            .font(.system(size: centerButtonDiameter * 0.35, weight: .medium))
                            .foregroundColor(isPoweredOn ? .orange : .gray.opacity(0.4))
                    }
                    .frame(width: centerButtonDiameter, height: centerButtonDiameter)
                }
                .buttonStyle(.plain)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

// MARK: - Control Bar

struct ControlBar: View {
    let isPoweredOn: Bool
    let isPlaying: Bool
    let isLoading: Bool
    let accentColor: Color
    let onPowerToggle: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            PowerSwitch(isOn: isPoweredOn, accentColor: accentColor, onToggle: onPowerToggle)

            // Loading indicator
            if isLoading {
                LoadingBar(accentColor: accentColor)
                    .padding(.leading, 12)
            }

            Spacer()

            // Playback controls
            HStack(spacing: 24) {
                // Previous station
                Button(action: onPrevious) {
                    Image(systemName: "backward.end.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isPoweredOn ? Color(white: 0.7) : .gray.opacity(0.3))
                }
                .disabled(!isPoweredOn)

                // Next station
                Button(action: onNext) {
                    Image(systemName: "forward.end.fill")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(isPoweredOn ? accentColor : .gray.opacity(0.3))
                }
                .disabled(!isPoweredOn)
            }
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Power Switch

struct PowerSwitch: View {
    let isOn: Bool
    let accentColor: Color
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 6) {
                // Switch track
                ZStack(alignment: isOn ? .trailing : .leading) {
                    Capsule()
                        .fill(isOn ? accentColor : Color(white: 0.25))
                        .frame(width: 44, height: 26)

                    // Knob
                    Circle()
                        .fill(Color(white: 0.9))
                        .frame(width: 22, height: 22)
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                        .padding(2)
                }

                Text(isOn ? "ON" : "OFF")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(isOn ? accentColor : Color(white: 0.45))
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Loading Bar

struct LoadingBar: View {
    let accentColor: Color
    @State private var animationProgress: CGFloat = 0

    var body: some View {
        Capsule()
            .fill(Color(white: 0.25))
            .frame(width: 50, height: 4)
            .overlay(
                GeometryReader { geometry in
                    Capsule()
                        .fill(accentColor)
                        .frame(width: 20, height: 4)
                        .offset(x: animationProgress * (geometry.size.width - 20))
                }
            )
            .clipShape(Capsule())
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    animationProgress = 1
                }
            }
    }
}

// MARK: - Info Sheet

struct InfoSheet: View {
    let station: RadioStation?
    let category: RadioCategory?
    let shareText: String
    let shareURL: URL?

    @EnvironmentObject var audioManager: AudioPlayerManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Station Info
                VStack(spacing: 12) {
                    // Category badge
                    if let category = category {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.system(size: 12, weight: .semibold))
                            Text(category.name)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.orange.opacity(0.15))
                        )
                    }

                    // Station name
                    Text(station?.name ?? "No station selected")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)

                    // Station description
                    if let description = station?.description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    // Location
                    if let location = station?.location {
                        HStack(spacing: 4) {
                            Image(systemName: "location")
                                .font(.system(size: 11))
                            Text(location)
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    }

                    // Live indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("LIVE")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.red)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)

                Spacer()

                // Playback controls
                HStack(spacing: 32) {
                    // Previous station
                    Button(action: { audioManager.previousStation() }) {
                        Image(systemName: "backward.end.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(audioManager.isPoweredOn ? .orange : .gray.opacity(0.4))
                    }
                    .disabled(!audioManager.isPoweredOn)

                    // Next station
                    Button(action: { audioManager.nextStation() }) {
                        Image(systemName: "forward.end.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(audioManager.isPoweredOn ? .orange : .gray.opacity(0.4))
                    }
                    .disabled(!audioManager.isPoweredOn)
                }
                .padding(.vertical, 20)

                // Share button
                if shareURL != nil {
                    ShareLink(
                        item: shareText,
                        preview: SharePreview(
                            station?.name ?? "Live Radio",
                            image: Image(systemName: "radio")
                        )
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Share")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.orange)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()
                    .frame(height: 20)
            }
            .padding(.top, 24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Station List Sheet

struct StationListSheet: View {
    let category: RadioCategory
    let accentColor: Color
    @EnvironmentObject var audioManager: AudioPlayerManager
    @EnvironmentObject var radioStore: RadioStore
    @Environment(\.dismiss) var dismiss
    @State private var showingAddStation = false

    var stations: [RadioStation] {
        radioStore.category(for: category.id)?.stations ?? category.stations
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(stations) { station in
                    Button {
                        audioManager.switchToCategory(category)
                        audioManager.play(station: station)
                        // Don't dismiss - keep list open
                    } label: {
                        HStack(spacing: 12) {
                            // Now playing indicator
                            if audioManager.currentStation?.id == station.id && audioManager.currentCategory?.id == category.id {
                                Image(systemName: audioManager.isPlaying ? "waveform" : "pause.fill")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(accentColor)
                                    .frame(width: 24)
                            } else {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(white: 0.4))
                                    .frame(width: 24)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(station.name)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(audioManager.currentStation?.id == station.id ? accentColor : .primary)

                                if !station.description.isEmpty {
                                    Text(station.description)
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }

                            Spacer()

                            if let location = station.location {
                                Text(location)
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(white: 0.5))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // Add station button
                Button {
                    showingAddStation = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(accentColor)
                            .frame(width: 24)

                        Text("Add Station")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(accentColor)
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.plain)
            .navigationTitle(category.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 6) {
                        Image(systemName: category.icon)
                            .font(.system(size: 14, weight: .semibold))
                        Text("\(stations.count) stations")
                            .font(.system(size: 13))
                    }
                    .foregroundColor(accentColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingAddStation) {
                SuggestedStationsView(categoryId: category.id)
                    .environmentObject(radioStore)
            }
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var radioStore: RadioStore
    @EnvironmentObject var audioManager: AudioPlayerManager
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss

    @State private var showingAddCategory = false

    var body: some View {
        NavigationView {
            List {
                // Appearance Section
                Section {
                    Picker("Appearance", selection: $appSettings.appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }

                    NavigationLink {
                        ColorSchemePickerView()
                            .environmentObject(appSettings)
                    } label: {
                        HStack {
                            Text("Accent Color")
                            Spacer()
                            Circle()
                                .fill(appSettings.colorScheme.color)
                                .frame(width: 24, height: 24)
                        }
                    }

                    NavigationLink {
                        VisualizationPickerView()
                            .environmentObject(appSettings)
                    } label: {
                        HStack {
                            Text("Visualization Style")
                            Spacer()
                            Text(appSettings.visualizationStyle.rawValue)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Appearance")
                }

                // Categories Section
                Section {
                    ForEach(radioStore.categories) { category in
                        NavigationLink {
                            CategoryEditView(category: category)
                                .environmentObject(radioStore)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(appSettings.colorScheme.color)
                                    .frame(width: 28)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(category.name)
                                        .font(.system(size: 16, weight: .medium))
                                    Text("\(category.stations.count) stations")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { radioStore.deleteCategory(at: $0) }
                    }
                    .onMove { from, to in
                        radioStore.moveCategory(from: from, to: to)
                    }
                } header: {
                    Text("Categories")
                }

                Section {
                    Button(action: { showingAddCategory = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(appSettings.colorScheme.color)
                            Text("Add Category")
                        }
                    }

                    Button(action: { radioStore.resetToDefaults() }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(appSettings.colorScheme.color)
                            Text("Reset to Defaults")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView()
                .environmentObject(radioStore)
        }
    }
}

// MARK: - Color Scheme Picker

struct ColorSchemePickerView: View {
    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        List {
            ForEach(ColorScheme.allCases, id: \.self) { scheme in
                Button {
                    appSettings.colorScheme = scheme
                } label: {
                    HStack {
                        Circle()
                            .fill(scheme.color)
                            .frame(width: 30, height: 30)

                        Text(scheme.rawValue)
                            .foregroundColor(.primary)

                        Spacer()

                        if appSettings.colorScheme == scheme {
                            Image(systemName: "checkmark")
                                .foregroundColor(scheme.color)
                        }
                    }
                }
            }
        }
        .navigationTitle("Accent Color")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Visualization Picker

struct VisualizationPickerView: View {
    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        List {
            ForEach(VisualizationStyle.allCases, id: \.self) { style in
                Button {
                    appSettings.visualizationStyle = style
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(style.rawValue)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            Text(style.description)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if appSettings.visualizationStyle == style {
                            Image(systemName: "checkmark")
                                .foregroundColor(appSettings.colorScheme.color)
                        }
                    }
                }
            }
        }
        .navigationTitle("Visualization")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Suggested Stations View

struct SuggestedStationsView: View {
    let categoryId: String
    @EnvironmentObject var radioStore: RadioStore
    @Environment(\.dismiss) var dismiss
    @State private var addedStations: Set<String> = []

    var body: some View {
        NavigationView {
            List {
                ForEach(SuggestedStations.all) { station in
                    Button {
                        radioStore.addStation(station, toCategoryId: categoryId)
                        addedStations.insert(station.id)
                    } label: {
                        HStack(spacing: 12) {
                            if addedStations.contains(station.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(.orange)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(station.name)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)

                                Text(station.description)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            if let location = station.location {
                                Text(location)
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(white: 0.5))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .disabled(addedStations.contains(station.id))
                }
            }
            .listStyle(.plain)
            .navigationTitle("Add Station")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Category Edit View

struct CategoryEditView: View {
    let category: RadioCategory
    @EnvironmentObject var radioStore: RadioStore
    @State private var showingAddStation = false
    @State private var editingStation: RadioStation?
    @State private var editedName: String = ""
    @State private var editedShortName: String = ""
    @State private var editedIcon: String = ""

    init(category: RadioCategory) {
        self.category = category
        _editedName = State(initialValue: category.name)
        _editedShortName = State(initialValue: category.shortName)
        _editedIcon = State(initialValue: category.icon)
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Category name", text: $editedName)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Text("Short Name")
                    Spacer()
                    TextField("SHORT", text: $editedShortName)
                        .multilineTextAlignment(.trailing)
                        .textCase(.uppercase)
                        .frame(width: 60)
                }

                NavigationLink {
                    IconPickerView(selectedIcon: $editedIcon)
                } label: {
                    HStack {
                        Text("Icon")
                        Spacer()
                        Image(systemName: editedIcon)
                            .foregroundColor(.orange)
                    }
                }
            } header: {
                Text("Category Info")
            }

            Section {
                ForEach(currentCategory?.stations ?? []) { station in
                    Button {
                        editingStation = station
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(station.name)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                            if let location = station.location {
                                Text(location)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { radioStore.deleteStation(from: category.id, at: $0) }
                }
                .onMove { from, to in
                    radioStore.moveStation(in: category.id, from: from, to: to)
                }

                Button(action: { showingAddStation = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.orange)
                        Text("Add Station")
                    }
                }
            } header: {
                Text("Stations")
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .onChange(of: editedName) { _, _ in saveChanges() }
        .onChange(of: editedShortName) { _, _ in saveChanges() }
        .onChange(of: editedIcon) { _, _ in saveChanges() }
        .sheet(isPresented: $showingAddStation) {
            AddStationView(categoryId: category.id)
                .environmentObject(radioStore)
        }
        .sheet(item: $editingStation) { station in
            EditStationView(categoryId: category.id, station: station)
                .environmentObject(radioStore)
        }
    }

    var currentCategory: RadioCategory? {
        radioStore.category(for: category.id)
    }

    func saveChanges() {
        guard var updated = currentCategory else { return }
        updated.name = editedName
        updated.shortName = editedShortName.uppercased()
        updated.icon = editedIcon
        radioStore.updateCategory(updated)
    }
}

// MARK: - Icon Picker

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) var dismiss

    let columns = [GridItem(.adaptive(minimum: 60))]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(CategoryIcons.all, id: \.icon) { item in
                    Button {
                        selectedIcon = item.icon
                        dismiss()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: item.icon)
                                .font(.system(size: 24))
                                .foregroundColor(selectedIcon == item.icon ? .white : .primary)
                                .frame(width: 50, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedIcon == item.icon ? Color.orange : Color.gray.opacity(0.1))
                                )

                            Text(item.name)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Choose Icon")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Add Category View

struct AddCategoryView: View {
    @EnvironmentObject var radioStore: RadioStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var shortName = ""
    @State private var icon = "radio"

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Category name", text: $name)

                    HStack {
                        Text("Short Name")
                        Spacer()
                        TextField("SHORT", text: $shortName)
                            .multilineTextAlignment(.trailing)
                            .textCase(.uppercase)
                            .frame(width: 80)
                    }

                    NavigationLink {
                        IconPickerView(selectedIcon: $icon)
                    } label: {
                        HStack {
                            Text("Icon")
                            Spacer()
                            Image(systemName: icon)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        radioStore.addCategory(
                            name: name,
                            shortName: shortName.isEmpty ? String(name.prefix(4)) : shortName,
                            icon: icon
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Add Station View

struct AddStationView: View {
    let categoryId: String
    @EnvironmentObject var radioStore: RadioStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var streamURL = ""
    @State private var websiteURL = ""
    @State private var location = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Station name", text: $name)
                    TextField("Description", text: $description)
                    TextField("Location", text: $location)
                }

                Section {
                    TextField("Stream URL", text: $streamURL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                    TextField("Website URL (optional)", text: $websiteURL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                } footer: {
                    Text("Enter the direct stream URL (MP3, AAC, or HLS)")
                }
            }
            .navigationTitle("New Station")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let station = RadioStation(
                            name: name,
                            description: description,
                            streamURL: streamURL,
                            websiteURL: websiteURL.isEmpty ? nil : websiteURL,
                            location: location.isEmpty ? nil : location
                        )
                        radioStore.addStation(to: categoryId, station: station)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty || streamURL.isEmpty)
                }
            }
        }
    }
}

// MARK: - Edit Station View

struct EditStationView: View {
    let categoryId: String
    let station: RadioStation
    @EnvironmentObject var radioStore: RadioStore
    @Environment(\.dismiss) var dismiss

    @State private var name: String
    @State private var description: String
    @State private var streamURL: String
    @State private var websiteURL: String
    @State private var location: String

    init(categoryId: String, station: RadioStation) {
        self.categoryId = categoryId
        self.station = station
        _name = State(initialValue: station.name)
        _description = State(initialValue: station.description)
        _streamURL = State(initialValue: station.streamURL)
        _websiteURL = State(initialValue: station.websiteURL ?? "")
        _location = State(initialValue: station.location ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Station name", text: $name)
                    TextField("Description", text: $description)
                    TextField("Location", text: $location)
                }

                Section {
                    TextField("Stream URL", text: $streamURL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                    TextField("Website URL (optional)", text: $websiteURL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Edit Station")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let updated = RadioStation(
                            id: station.id,
                            name: name,
                            description: description,
                            streamURL: streamURL,
                            websiteURL: websiteURL.isEmpty ? nil : websiteURL,
                            location: location.isEmpty ? nil : location
                        )
                        radioStore.updateStation(in: categoryId, station: updated)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty || streamURL.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AudioPlayerManager())
        .environmentObject(RadioStore())
}
