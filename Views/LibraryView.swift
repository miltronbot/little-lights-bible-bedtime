
import SwiftUI

struct LibraryView: View {
    @EnvironmentObject private var viewModel: StoryLibraryViewModel
    @EnvironmentObject private var appSettings: AppSettings

    var initialCategory: StoryCategory? = nil

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

                // Age Group filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        AgeChipView(title: "All Ages", isSelected: viewModel.selectedAgeGroup == nil) {
                            viewModel.selectedAgeGroup = nil
                        }
                        ForEach(AgeGroup.allCases) { age in
                            AgeChipView(title: age.rawValue, isSelected: viewModel.selectedAgeGroup == age) {
                                viewModel.selectedAgeGroup = age
                            }
                        }
                    }
                }

                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChipView(title: "All", isSelected: viewModel.selectedCategory == nil) {
                            viewModel.selectedCategory = nil
                        }

                        ForEach(StoryCategory.allCases) { category in
                            CategoryChipView(title: category.rawValue, isSelected: viewModel.selectedCategory == category) {
                                viewModel.selectedCategory = category
                            }
                        }
                    }
                }

                // Results count
                Text("\(viewModel.filteredStories.count) stories")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

                // Story list
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredStories) { story in
                        NavigationLink(destination: StoryDetailView(story: story)) {
                            StoryCardView(story: story)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .background { StarryNightBackground(alwaysStarry: true) }
        .navigationTitle("Library")
        .onAppear {
            if let initial = initialCategory, viewModel.selectedCategory == nil {
                viewModel.selectedCategory = initial
            }
        }
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
