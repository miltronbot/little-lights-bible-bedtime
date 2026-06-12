import SwiftUI

// MARK: - Side Menu
// A slide-out drawer on the left edge of Home. Today it hosts theme
// browsing (the twilight CategoryCards, moved off the Home scroll) and
// quick links; new v2 features get added here as new sections so the
// menu grows without crowding the Home screen.

enum SideMenuDestination: Hashable, Identifiable {
    case theme(StoryCategory)
    case bedtimeRoutine
    case parentDashboard
    case nightSky
    case journeys
    case favorites
    case tonightsGoals

    var id: String {
        switch self {
        case .theme(let c): return "theme-\(c.rawValue)"
        case .bedtimeRoutine: return "bedtime-routine"
        case .parentDashboard: return "parent-dashboard"
        case .nightSky: return "night-sky"
        case .journeys: return "journeys"
        case .favorites: return "favorites"
        case .tonightsGoals: return "tonights-goals"
        }
    }
}

struct SideMenuView: View {
    @Binding var isOpen: Bool
    /// Set when the user picks an entry; Home navigates after the drawer closes.
    @Binding var selection: SideMenuDestination?

    @EnvironmentObject private var appSettings: AppSettings

    /// Themes start tucked away as a compact icon stack; tapping the header
    /// (or the stack) drops the full cards down. Resets each time the drawer
    /// opens because the panel is recreated.
    @State private var themesExpanded = false

    private let panelWidth: CGFloat = 300

    var body: some View {
        ZStack(alignment: .leading) {
            // Scrim — tap to close
            if isOpen {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                            isOpen = false
                        }
                    }
            }

            // Drawer panel — only exists while open, so the closed state
            // renders nothing at all (no shadow/edge bleed on Home)
            if isOpen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Header
                    HStack(spacing: 10) {
                        LumiMascotView(size: 26, message: nil)
                        Text("Explore")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                                isOpen = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .accessibilityLabel("Close menu")
                    }
                    .padding(.top, 8)

                    // Browse by Theme — collapsible: a tight glowing icon
                    // stack until tapped, then the full twilight cards drop down
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            themesExpanded.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Browse by Theme")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.85))
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.caption.bold())
                                .foregroundStyle(.white.opacity(0.6))
                                .rotationEffect(.degrees(themesExpanded ? 180 : 0))
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Browse by Theme")
                    .accessibilityHint(themesExpanded ? "Collapses the theme list" : "Shows the theme list")

                    if themesExpanded {
                        VStack(spacing: 10) {
                            ForEach(StoryCategory.allCases) { category in
                                Button {
                                    select(.theme(category))
                                } label: {
                                    CategoryCard(category: category)
                                        .frame(height: 64)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    } else {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                themesExpanded = true
                            }
                        } label: {
                            HStack(spacing: -7) {
                                ForEach(StoryCategory.allCases) { category in
                                    ZStack {
                                        Circle()
                                            .fill(themeGlow(category).opacity(0.30))
                                            .background(Circle().fill(Color(red: 0.05, green: 0.10, blue: 0.14)))
                                        Image(systemName: category.icon)
                                            .font(.system(size: 14))
                                            .foregroundStyle(.white)
                                            .shadow(color: themeGlow(category).opacity(0.9), radius: 5)
                                    }
                                    .frame(width: 38, height: 38)
                                    .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
                                    .shadow(color: themeGlow(category).opacity(0.45), radius: 6)
                                }
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Show themes")
                        .transition(.opacity)
                    }

                    // Quick links — right under the themes; tiles echo the
                    // theme cards' twilight gradients and glow (owner request)
                    Text("More")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.top, 2)

                    VStack(spacing: 10) {
                        linkTile(icon: "checklist", title: "Tonight's Goals",
                                 subtitle: "Three little quests before sleep", glow: .yellow,
                                 light: (Color(red: 0.40, green: 0.30, blue: 0.10),
                                         Color(red: 0.50, green: 0.38, blue: 0.14),
                                         Color(red: 0.58, green: 0.45, blue: 0.20)),
                                 dim: (Color(red: 0.28, green: 0.21, blue: 0.07),
                                       Color(red: 0.34, green: 0.26, blue: 0.10),
                                       Color(red: 0.39, green: 0.30, blue: 0.13))) {
                            select(.tonightsGoals)
                        }
                        linkTile(icon: "heart.fill", title: "My Favorites",
                                 subtitle: "The stories you love most", glow: .pink,
                                 light: (Color(red: 0.45, green: 0.18, blue: 0.28),
                                         Color(red: 0.55, green: 0.25, blue: 0.36),
                                         Color(red: 0.62, green: 0.34, blue: 0.36)),
                                 dim: (Color(red: 0.31, green: 0.12, blue: 0.19),
                                       Color(red: 0.37, green: 0.16, blue: 0.24),
                                       Color(red: 0.42, green: 0.22, blue: 0.24))) {
                            select(.favorites)
                        }
                        linkTile(icon: "map.fill", title: "7-Day Journeys",
                                 subtitle: "A gentle week of themed stories", glow: .mint,
                                 light: (Color(red: 0.10, green: 0.28, blue: 0.42),
                                         Color(red: 0.14, green: 0.36, blue: 0.52),
                                         Color(red: 0.20, green: 0.44, blue: 0.58)),
                                 dim: (Color(red: 0.07, green: 0.19, blue: 0.29),
                                       Color(red: 0.10, green: 0.25, blue: 0.36),
                                       Color(red: 0.13, green: 0.30, blue: 0.40))) {
                            select(.journeys)
                        }
                        linkTile(icon: "moon.zzz.fill", title: "Bedtime Routine",
                                 subtitle: "Story + Prayer + Sounds", glow: .indigo,
                                 light: (Color(red: 0.16, green: 0.16, blue: 0.42),
                                         Color(red: 0.22, green: 0.21, blue: 0.52),
                                         Color(red: 0.30, green: 0.27, blue: 0.58)),
                                 dim: (Color(red: 0.11, green: 0.11, blue: 0.29),
                                       Color(red: 0.15, green: 0.14, blue: 0.36),
                                       Color(red: 0.20, green: 0.18, blue: 0.40))) {
                            select(.bedtimeRoutine)
                        }
                        linkTile(icon: "sparkles", title: "Lumi's Night Sky",
                                 subtitle: "Decorate with your treasures", glow: .yellow,
                                 light: (Color(red: 0.24, green: 0.12, blue: 0.40),
                                         Color(red: 0.32, green: 0.16, blue: 0.50),
                                         Color(red: 0.38, green: 0.22, blue: 0.55)),
                                 dim: (Color(red: 0.16, green: 0.08, blue: 0.28),
                                       Color(red: 0.21, green: 0.11, blue: 0.34),
                                       Color(red: 0.25, green: 0.15, blue: 0.37))) {
                            select(.nightSky)
                        }
                        linkTile(icon: "chart.bar.fill", title: "Parent Dashboard",
                                 subtitle: "Progress & insights", glow: .teal,
                                 light: (Color(red: 0.18, green: 0.22, blue: 0.30),
                                         Color(red: 0.24, green: 0.29, blue: 0.38),
                                         Color(red: 0.30, green: 0.35, blue: 0.44)),
                                 dim: (Color(red: 0.12, green: 0.15, blue: 0.21),
                                       Color(red: 0.16, green: 0.20, blue: 0.26),
                                       Color(red: 0.20, green: 0.23, blue: 0.30))) {
                            select(.parentDashboard)
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
            }
            .frame(width: panelWidth)
            .background(
                ZStack {
                    Color(red: 0.03, green: 0.09, blue: 0.12)
                    StarryNightBackground(alwaysStarry: true)
                        .opacity(0.85)
                }
                .ignoresSafeArea()
            )
            .shadow(color: .black.opacity(0.5), radius: 24, x: 8)
            .transition(.move(edge: .leading))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .gesture(
            DragGesture(minimumDistance: 25)
                .onEnded { value in
                    if value.translation.width < -40 {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                            isOpen = false
                        }
                    }
                }
        )
        .allowsHitTesting(isOpen)
    }

    private func select(_ destination: SideMenuDestination) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
            isOpen = false
        }
        // Navigate after the drawer has begun closing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            selection = destination
        }
    }

    /// Same glow mapping CategoryCard uses, for the collapsed icon stack.
    private func themeGlow(_ category: StoryCategory) -> Color {
        switch category {
        case .peace:    return .cyan
        case .love:     return .pink
        case .hope:     return .yellow
        case .courage:  return .orange
        case .trust:    return .blue
        case .prayer:   return .purple
        case .kindness: return .green
        }
    }

    /// A quick-link row dressed like the theme cards: twilight gradient,
    /// radial glow behind the icon, sparkle accents.
    @ViewBuilder
    private func linkTile(icon: String, title: String, subtitle: String, glow: Color,
                          light: (Color, Color, Color), dim: (Color, Color, Color),
                          action: @escaping () -> Void) -> some View {
        let palette = appSettings.isBedtimeMode ? dim : light
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [glow.opacity(0.55), glow.opacity(0.18), .clear],
                                center: .center, startRadius: 0, endRadius: 26
                            )
                        )
                        .frame(width: 52, height: 52)
                        .blur(radius: 4)
                    Image(systemName: icon)
                        .font(.system(size: 19))
                        .foregroundStyle(.white)
                        .shadow(color: glow.opacity(0.8), radius: 8)
                }
                .frame(width: 44, height: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.75))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(10)
            .frame(height: 64)
            .background(
                ZStack {
                    LinearGradient(
                        stops: [
                            .init(color: palette.0, location: 0.0),
                            .init(color: palette.1, location: 0.55),
                            .init(color: palette.2, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    Image(systemName: "sparkle")
                        .font(.system(size: 7))
                        .foregroundStyle(.white.opacity(0.55))
                        .offset(x: -52, y: -16)
                    Image(systemName: "sparkle")
                        .font(.system(size: 5))
                        .foregroundStyle(.white.opacity(0.35))
                        .offset(x: 70, y: 12)
                    Image(systemName: "sparkle")
                        .font(.system(size: 6))
                        .foregroundStyle(.white.opacity(0.45))
                        .offset(x: 40, y: -20)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Library Filter Drawer
// The Library's age + theme filters live in a slide-out panel (same
// pattern as Home's side menu). Picks apply instantly; the footer
// button shows the live result count and closes the drawer.

struct LibraryFilterMenu: View {
    @Binding var isOpen: Bool
    @EnvironmentObject private var viewModel: StoryLibraryViewModel
    @EnvironmentObject private var appSettings: AppSettings

    @State private var agesExpanded = false
    @State private var themesExpanded = true

    private let panelWidth: CGFloat = 290

    var body: some View {
        ZStack(alignment: .leading) {
            if isOpen {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { close() }

                VStack(alignment: .leading, spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Filters")
                                    .font(.title2.bold())
                                    .foregroundStyle(.white)
                                Spacer()
                                Button { close() } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                                .accessibilityLabel("Close filters")
                            }
                            .padding(.top, 8)

                            // Ages — drop-down
                            dropDownHeader(
                                title: "Ages",
                                current: viewModel.selectedAgeGroup?.rawValue ?? "All Ages",
                                expanded: $agesExpanded
                            )
                            if agesExpanded {
                                Group {
                                    filterRow(title: "All Ages", icon: "person.3.fill",
                                              selected: viewModel.selectedAgeGroup == nil) {
                                        viewModel.selectedAgeGroup = nil
                                    }
                                    ForEach(AgeGroup.allCases) { age in
                                        filterRow(title: age.rawValue, icon: age.icon,
                                                  selected: viewModel.selectedAgeGroup == age) {
                                            viewModel.selectedAgeGroup = age
                                        }
                                    }
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            Divider().overlay(Color.white.opacity(0.15))

                            // Themes — drop-down
                            dropDownHeader(
                                title: "Themes",
                                current: viewModel.selectedCategory?.rawValue ?? "All Themes",
                                expanded: $themesExpanded
                            )
                            if themesExpanded {
                                Group {
                                    filterRow(title: "All Themes", icon: "sparkles",
                                              selected: viewModel.selectedCategory == nil) {
                                        viewModel.selectedCategory = nil
                                    }
                                    ForEach(StoryCategory.allCases) { category in
                                        filterRow(title: category.rawValue, icon: category.icon,
                                                  selected: viewModel.selectedCategory == category) {
                                            viewModel.selectedCategory = category
                                        }
                                    }
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Live result count — tap to see them
                    Button { close() } label: {
                        Text("Show \(viewModel.filteredStories.count) stories")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.accent(for: true))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(16)
                }
                .frame(width: panelWidth)
                .background(
                    ZStack {
                        Color(red: 0.03, green: 0.09, blue: 0.12)
                        StarryNightBackground(alwaysStarry: true).opacity(0.85)
                    }
                    .ignoresSafeArea()
                )
                .shadow(color: .black.opacity(0.5), radius: 24, x: 8)
                .transition(.move(edge: .leading))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .allowsHitTesting(isOpen)
    }

    private func close() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
            isOpen = false
        }
    }

    @ViewBuilder
    private func dropDownHeader(title: String, current: String, expanded: Binding<Bool>) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                expanded.wrappedValue.toggle()
            }
        } label: {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text(current)
                    .font(.caption.bold())
                    .foregroundStyle(.yellow)
                Image(systemName: "chevron.down")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.7))
                    .rotationEffect(.degrees(expanded.wrappedValue ? 0 : -90))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityHint(expanded.wrappedValue ? "Collapses \(title)" : "Expands \(title)")
    }

    @ViewBuilder
    private func filterRow(title: String, icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .frame(width: 24)
                    .foregroundStyle(selected ? .yellow : .white.opacity(0.8))
                Text(title)
                    .font(.subheadline.weight(selected ? .bold : .regular))
                    .foregroundStyle(.white)
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.yellow)
                }
            }
            .padding(.vertical, 9)
            .padding(.horizontal, 12)
            .background(selected ? Color.white.opacity(0.10) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
