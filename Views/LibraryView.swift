
import SwiftUI

struct LibraryView: View {
    @EnvironmentObject private var viewModel: StoryLibraryViewModel
    @EnvironmentObject private var appSettings: AppSettings

    var initialCategory: StoryCategory? = nil
    @State private var showFilters = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    TextField("Search stories, themes, or Bible references...", text: $viewModel.searchText)
                }
                .padding(12)
                .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                // Active filters summary — full controls live in the drawer
                HStack(spacing: 8) {
                    Text("\(viewModel.filteredStories.count) stories")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

                    if viewModel.selectedAgeGroup != nil || viewModel.selectedCategory != nil {
                        Text("·")
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                        if let age = viewModel.selectedAgeGroup {
                            filterPill(age.rawValue) { viewModel.selectedAgeGroup = nil }
                        }
                        if let category = viewModel.selectedCategory {
                            filterPill(category.rawValue) { viewModel.selectedCategory = nil }
                        }
                    }
                    Spacer()
                }

                // Story list
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredStories) { story in
                        StoryCardView(story: story)
                    }
                }
            }
            .padding()
        }
        .background { StarryNightBackground(alwaysStarry: true) }
        .navigationTitle("Library")
        .toolbar {
            // Leading + plain glyph to match Home's hamburger exactly — the
            // two drawer buttons read as one consistent control, and this
            // drawer slides in from the left anyway
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                        showFilters = true
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                        .foregroundStyle(
                            (viewModel.selectedAgeGroup != nil || viewModel.selectedCategory != nil)
                                ? AppTheme.accent(for: appSettings.isBedtimeMode)
                                : AppTheme.primaryText(for: appSettings.isBedtimeMode)
                        )
                }
                .accessibilityLabel("Filter stories")
            }
        }
        .overlay {
            LibraryFilterMenu(isOpen: $showFilters)
        }
        .onAppear {
            if let initial = initialCategory, viewModel.selectedCategory == nil {
                viewModel.selectedCategory = initial
            }
        }
    }

    @ViewBuilder
    private func filterPill(_ title: String, clear: @escaping () -> Void) -> some View {
        Button(action: clear) {
            HStack(spacing: 4) {
                Text(title)
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
            }
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.25))
            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Age Chip

struct AgeChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.bold())
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.orange : AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                .foregroundStyle(isSelected ? .white : AppTheme.primaryText(for: appSettings.isBedtimeMode))
                .clipShape(Capsule())
        }
    }
}
