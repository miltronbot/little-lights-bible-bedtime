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

    var id: String {
        switch self {
        case .theme(let c): return "theme-\(c.rawValue)"
        case .bedtimeRoutine: return "bedtime-routine"
        case .parentDashboard: return "parent-dashboard"
        case .nightSky: return "night-sky"
        case .journeys: return "journeys"
        }
    }
}

struct SideMenuView: View {
    @Binding var isOpen: Bool
    /// Set when the user picks an entry; Home navigates after the drawer closes.
    @Binding var selection: SideMenuDestination?

    @EnvironmentObject private var appSettings: AppSettings

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

                    // Browse by Theme — the twilight cards, now living here
                    Text("Browse by Theme")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.85))

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

                    Divider()
                        .overlay(Color.white.opacity(0.15))
                        .padding(.vertical, 2)

                    // Quick links — future v2 features join this section
                    Text("More")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.85))

                    VStack(spacing: 10) {
                        menuRow(icon: "map.fill", title: "7-Day Journeys",
                                subtitle: "A gentle week of themed stories") {
                            select(.journeys)
                        }
                        menuRow(icon: "moon.zzz.fill", title: "Bedtime Routine",
                                subtitle: "Story + Prayer + Sounds") {
                            select(.bedtimeRoutine)
                        }
                        menuRow(icon: "sparkles", title: "Lumi's Night Sky",
                                subtitle: "Decorate with your treasures") {
                            select(.nightSky)
                        }
                        menuRow(icon: "chart.bar.fill", title: "Parent Dashboard",
                                subtitle: "Progress & insights") {
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

    @ViewBuilder
    private func menuRow(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accent(for: true).opacity(0.22))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 17))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.65))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(10)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
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
