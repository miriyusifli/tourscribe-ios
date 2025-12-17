import SwiftUI

// MARK: - Sub-Components

struct HeaderButton: View {
    let icon: String
    let title: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(iconColor)
                    .padding(3)
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 100)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.glassBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .accessibilityElement(children: .combine)
    }
}

struct TimelineItemView: View {
    let item: ItineraryItem
    @State private var isExpanded = false
    
    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(item.startTime)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.textPrimary)
                        Text("-")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                        Text(item.endTime)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.textPrimary)
                    }
                    .padding(.bottom, 4)
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    Text(item.address)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                Spacer()
                Image(systemName: item.category.icon)
                    .font(.title2)
                    .foregroundColor(item.category.color)
            }
            
            Divider().background(Color.white.opacity(0.2))
            
            if let notes = item.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
            }
            
            if isExpanded {
                TimelineItemViewExpanded()
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.glassBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding(.bottom, 16)
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
        }
        }
    }
}

struct TimelineItemViewExpanded: View {
    var body: some View {
        Group {
            Divider()
                .background(Color.white.opacity(0.3))
            
            HStack(spacing: 16) {
                Button(action: {
                    // Open directions
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.title3)
                        Text("Directions")
                            .font(.caption2)
                    }
                    .foregroundColor(.primaryColor)
                    .frame(maxWidth: .infinity)
                }
                
                Button(action: {
                    // Edit item
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.title3)
                        Text("Edit")
                            .font(.caption2)
                    }
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                }
                
                Button(action: {
                    // Delete item
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "trash")
                            .font(.title3)
                        Text("Delete")
                            .font(.caption2)
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

// MARK: - Main View

struct TripItineraryView: View {
    @StateObject private var viewModel = TripViewModel()
    @State private var selectedTab = 0
    
    //TODO move separate place since it is a general component
    var body: some View {
        TabView(selection: $selectedTab) {
            tripContentView
                .tabItem {
                    Label("Plan", systemImage: "map.fill")
                }
                .tag(0)
            
            RankingView()
                .tabItem {
                    Label("Ranking", systemImage: "trophy.fill")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(.primaryColor)
    }
    
    var tripContentView: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [.backgroundTop, .backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 24) {
                    headerSection
                    actionButtons
                    timelineSection
                }
                .padding(.horizontal)
            }
            .safeAreaInset(edge: .bottom) {
                addButton
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(viewModel.tripTitle)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                Spacer()
                HStack {
                    Image(systemName: "cloud.sun.fill")
                        .symbolRenderingMode(.multicolor)
                    Text(viewModel.weather)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
            
            HStack {
                Image(systemName: "calendar")
                Text(viewModel.tripDates)
                    .foregroundColor(.textSecondary)
            }
            .font(.subheadline)
        }
        .padding(.top, 60)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            HeaderButton(icon: "sparkles", title: "Recommendations", iconColor: Color(red: 1.0, green: 0.7, blue: 0.0)) {
                // Action
            }
            HeaderButton(icon: "map.fill", title: "Map View", iconColor: Color(red: 0.2, green: 0.8, blue: 0.5)) {
                // Action
            }
        }
    }
    
    private var timelineSection: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.items) { item in
                TimelineItemView(item: item)
            }
        }
        .padding(.top, 10)
    }
    
    private var addButton: some View {
        HStack {
            Spacer()
            Button(action: {
                viewModel.addItem()
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.primaryColor)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

// MARK: - Preview

struct TripItineraryView_Previews: PreviewProvider {
    static var previews: some View {
        TripItineraryView()
    }
}
