
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var audioPlayerViewModel: AudioPlayerViewModel
    @EnvironmentObject private var readingStreak: ReadingStreakViewModel
    @EnvironmentObject private var collectiblesManager: CollectiblesManager
    @StateObject private var notificationService = NotificationService()
    @State private var newChildName: String = ""
    @State private var showResetConfirmation: Bool = false

    // Voice fetching
    @State private var fetchedVoices: [ElevenLabsVoice] = []
    @State private var isFetchingVoices: Bool = false
    @State private var voiceFetchError: String? = nil
    @State private var lastFetchedKey: String = ""

    private var voicesToShow: [ElevenLabsVoice] {
        fetchedVoices.isEmpty ? ElevenLabsVoice.defaults : fetchedVoices
    }

    var body: some View {
        List {
            Section("Display") {
                Toggle(isOn: $appSettings.isBedtimeMode) {
                    Label("Bedtime Mode", systemImage: "moon.fill")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label("Text Size", systemImage: "textformat.size")
                    HStack {
                        Text("A")
                            .font(.caption2)
                        Slider(value: $appSettings.fontSize, in: 14...28, step: 1) {
                            Text("Text Size")
                        }
                        Text("A")
                            .font(.title2)
                    }
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    Text("The quick brown fox jumps over the lazy dog.")
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                }
            }

            Section("Playback") {
                Toggle(isOn: $appSettings.autoPlayNarration) {
                    Label("Auto-play Narration", systemImage: "play.circle")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label("Narration Volume", systemImage: "speaker.wave.2.fill")
                    Slider(value: Binding(
                        get: { Double(audioPlayerViewModel.narrationVolume) },
                        set: { newValue in
                            audioPlayerViewModel.setNarrationVolume(Float(newValue))
                            appSettings.narrationVolume = newValue
                        }
                    ), in: 0...1) {
                        Text("Volume")
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label("Ambient Sound Volume", systemImage: "speaker.wave.1.fill")
                    Slider(value: Binding(
                        get: { Double(audioPlayerViewModel.ambientVolume) },
                        set: { newValue in
                            audioPlayerViewModel.setAmbientVolume(Float(newValue))
                            appSettings.ambientVolume = newValue
                        }
                    ), in: 0...1) {
                        Text("Volume")
                    }
                }
            }

            // MARK: - Voice Narration (ElevenLabs)
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Voice Narration", systemImage: "waveform.circle.fill")
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    Text("Powered by ElevenLabs AI — natural, human-like voices for every story.")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                }
                .padding(.vertical, 4)

                // API Key
                VStack(alignment: .leading, spacing: 6) {
                    Label("API Key", systemImage: "key.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    SecureField("Paste your ElevenLabs API key", text: $appSettings.elevenLabsAPIKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding(10)
                        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onSubmit { loadVoicesIfNeeded() }
                    if appSettings.elevenLabsAPIKey.isEmpty {
                        Text("Get your free key at elevenlabs.io")
                            .font(.caption2)
                            .foregroundStyle(.indigo)
                    } else {
                        HStack(spacing: 6) {
                            Label("API key saved", systemImage: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(.green)
                            Spacer()
                            Button("Load Voices") { loadVoicesIfNeeded(force: true) }
                                .font(.caption2.bold())
                                .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                        }
                    }
                }
                .padding(.vertical, 4)
                .onChange(of: appSettings.elevenLabsAPIKey) { _, _ in loadVoicesIfNeeded() }

                // Voice Picker
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label("Narrator Voice", systemImage: "person.wave.2.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        Spacer()
                        if isFetchingVoices {
                            ProgressView()
                                .scaleEffect(0.75)
                        } else if !fetchedVoices.isEmpty {
                            Text("\(fetchedVoices.count) voices")
                                .font(.caption2)
                                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                        }
                    }

                    if let error = voiceFetchError {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    ForEach(voicesToShow) { voice in
                        Button {
                            appSettings.selectedVoiceID = voice.id
                            ElevenLabsService.shared.clearCache()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: iconFor(voice: voice))
                                    .font(.title3)
                                    .foregroundStyle(appSettings.selectedVoiceID == voice.id
                                        ? AppTheme.accent(for: appSettings.isBedtimeMode)
                                        : AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 6) {
                                        Text(voice.name)
                                            .font(.subheadline.bold())
                                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                                        if voice.category == "cloned" || voice.category == "professional" {
                                            Text("MY VOICE")
                                                .font(.system(size: 9, weight: .bold))
                                                .padding(.horizontal, 5)
                                                .padding(.vertical, 2)
                                                .background(Color.purple.opacity(0.2))
                                                .foregroundStyle(.purple)
                                                .clipShape(Capsule())
                                        }
                                    }
                                    Text(voice.description)
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                                        .lineLimit(1)
                                }
                                Spacer()
                                if appSettings.selectedVoiceID == voice.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                                }
                            }
                            .padding(10)
                            .background(
                                appSettings.selectedVoiceID == voice.id
                                    ? AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.1)
                                    : AppTheme.cardBackground(for: appSettings.isBedtimeMode)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
                .onAppear { loadVoicesIfNeeded() }

                // Cache management
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Audio Cache")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        Text(ElevenLabsService.shared.cacheSize())
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    }
                    Spacer()
                    Button("Clear") {
                        ElevenLabsService.shared.clearCache()
                    }
                    .font(.caption.bold())
                    .foregroundStyle(.red)
                }

            } header: {
                Label("Voice Narration", systemImage: "mic.fill")
            }

            Section("Bedtime Reminder") {
                Toggle(isOn: Binding(
                    get: { notificationService.bedtimeReminderEnabled },
                    set: { newValue in
                        notificationService.bedtimeReminderEnabled = newValue
                        if newValue {
                            notificationService.requestPermission()
                            Task {
                                let hasPermission = await notificationService.checkPermissionStatus()
                                if hasPermission {
                                    notificationService.scheduleBedtimeReminder(
                                        at: notificationService.bedtimeHour,
                                        minute: notificationService.bedtimeMinute
                                    )
                                }
                            }
                        } else {
                            notificationService.cancelBedtimeReminder()
                        }
                    }
                )) {
                    Label("Enable Bedtime Reminder", systemImage: "moon.stars.fill")
                }

                if notificationService.bedtimeReminderEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Reminder Time", systemImage: "clock.fill")
                        DatePicker(
                            "Bedtime",
                            selection: Binding(
                                get: {
                                    Calendar.current.date(
                                        bySettingHour: notificationService.bedtimeHour,
                                        minute: notificationService.bedtimeMinute,
                                        second: 0,
                                        of: Date()
                                    ) ?? Date()
                                },
                                set: { newDate in
                                    let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                    notificationService.bedtimeHour = components.hour ?? 19
                                    notificationService.bedtimeMinute = components.minute ?? 30
                                    notificationService.scheduleBedtimeReminder(
                                        at: notificationService.bedtimeHour,
                                        minute: notificationService.bedtimeMinute
                                    )
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                    }
                }
            }

            Section("Children") {
                ForEach(Array(appSettings.childrenNames.enumerated()), id: \.offset) { index, name in
                    HStack {
                        Image(systemName: appSettings.activeChildIndex == index ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(appSettings.activeChildIndex == index ? AppTheme.accent(for: appSettings.isBedtimeMode) : AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                        Text(name)
                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        Spacer()
                        if appSettings.childrenNames.count > 1 {
                            Button {
                                appSettings.removeChild(at: index)
                            } label: {
                                Image(systemName: "trash")
                                    .font(.caption)
                                    .foregroundStyle(.red.opacity(0.7))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        appSettings.switchToChild(at: index)
                    }
                }

                if appSettings.childrenNames.count < 4 {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                        TextField("Add child", text: $newChildName)
                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                            .submitLabel(.done)
                            .onSubmit {
                                if !newChildName.trimmingCharacters(in: .whitespaces).isEmpty {
                                    appSettings.addChild(name: newChildName)
                                    newChildName = ""
                                }
                            }
                    }
                }
            }

            Section("Content") {
                Picker(selection: Binding(
                    get: { appSettings.selectedAgeGroup },
                    set: { appSettings.selectedAgeGroup = $0 }
                )) {
                    Text("All Ages").tag("")
                    ForEach(AgeGroup.allCases) { age in
                        Text(age.rawValue).tag(age.rawValue)
                    }
                } label: {
                    Label("Default Age Group", systemImage: "figure.child")
                }
            }

            Section("For Parents") {
                NavigationLink(destination: ParentDashboardView()) {
                    Label("Parent Dashboard", systemImage: "chart.bar.fill")
                }
            }

            Section("About") {
                NavigationLink(destination: PrivacyPolicyView()) {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                }

                NavigationLink(destination: TermsOfUseView()) {
                    Label("Terms of Use", systemImage: "doc.text.fill")
                }

                NavigationLink(destination: SupportView()) {
                    Label("Support", systemImage: "envelope.fill")
                }
            }

            Section {
                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Label("Reset App (Start Fresh)", systemImage: "arrow.counterclockwise")
                }
            }

            Section {
                VStack(spacing: 6) {
                    Text("Firefly Bible Bedtime")
                        .font(.footnote.bold())
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    Text("Version 2.0 — Free for all families")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    Text("50 Bible bedtime stories with love")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                }
                .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .scrollContentBackground(.hidden)
        .background { StarryNightBackground(alwaysStarry: true) }
        .navigationTitle("Settings")
        .onAppear {
            // Restore previously cached voices immediately (no network needed)
            if fetchedVoices.isEmpty,
               let data = UserDefaults.standard.data(forKey: "cachedElevenLabsVoices"),
               let saved = try? JSONDecoder().decode([ElevenLabsVoice].self, from: data) {
                fetchedVoices = saved
            }
            loadVoicesIfNeeded()
        }
        .alert("Reset App?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset Everything", role: .destructive) {
                // Reset in-memory state first
                readingStreak.resetAll()
                collectiblesManager.resetAll()
                audioPlayerViewModel.stop()
                audioPlayerViewModel.setAmbientSound(.none)

                // Clear all UserDefaults
                if let bundleID = Bundle.main.bundleIdentifier {
                    UserDefaults.standard.removePersistentDomain(forName: bundleID)
                    UserDefaults.standard.synchronize()
                }

                // Reset app settings to trigger onboarding
                appSettings.hasCompletedOnboarding = false
            }
        } message: {
            Text("This will erase all data including children names, reading streaks, badges, and collectibles. You'll see the welcome screen again.")
        }
    }

    // MARK: - Voice Helpers

    /// Fetches voices from ElevenLabs, debounced by API key. Pass force:true to always re-fetch.
    private func loadVoicesIfNeeded(force: Bool = false) {
        let key = appSettings.elevenLabsAPIKey.trimmingCharacters(in: .whitespaces)
        guard !key.isEmpty else { return }
        guard force || key != lastFetchedKey else { return }
        lastFetchedKey = key
        isFetchingVoices = true
        voiceFetchError = nil
        Task {
            do {
                let voices = try await ElevenLabsService.shared.fetchVoices(apiKey: key)
                await MainActor.run {
                    fetchedVoices = voices
                    isFetchingVoices = false
                }
                // Persist so the list survives app restarts without a network call
                if let data = try? JSONEncoder().encode(voices) {
                    UserDefaults.standard.set(data, forKey: "cachedElevenLabsVoices")
                }
            } catch {
                await MainActor.run {
                    voiceFetchError = error.localizedDescription
                    isFetchingVoices = false
                }
            }
        }
    }

    /// SF Symbol icon for a voice row based on category and gender.
    private func iconFor(voice: ElevenLabsVoice) -> String {
        if voice.category == "cloned" || voice.category == "professional" {
            return "person.crop.circle.badge.checkmark"
        }
        return voice.gender == "female" ? "person.circle.fill" : "person.circle"
    }
}
