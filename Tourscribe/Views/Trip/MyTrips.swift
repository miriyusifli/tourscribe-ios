import SwiftUI

struct MyTrips: View {
    // MARK: - State
    @State private var selectedSegment = 0
    @State private var selectedTab = 0
    
    // Mock Data for Design Preview
    private let upcomingTrips = [
        TripMock(title: "Kyoto Spring Adventure", dates: "Apr 10 - Apr 24, 2026", status: .current),
        TripMock(title: "Italian Summer", dates: "Jul 15 - Jul 30, 2026", status: .upcoming)
    ]
    
    private let pastTrips = [
        TripMock(title: "New York Christmas", dates: "Dec 20 - Dec 27, 2024", status: .past)
    ]
    
    var body: some View {
        MainTabView(
            selection: $selectedTab,
            mainTabTitle: String(localized: "tab.my_trips"),
            mainTabIcon: "suitcase.fill"
        ) {
            myTripsContent
        }
    }
    
    private var myTripsContent: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [.backgroundTop, .backgroundBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    headerView
                    
                    // Segmented Control
                    pickerView
                    
                    // Content
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 20) {
                            let trips = selectedSegment == 0 ? upcomingTrips : pastTrips
                            ForEach(trips) { trip in
                                TripCardView(trip: trip)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100) // Space for floating button if needed
                    }
                    .safeAreaInset(edge: .bottom) {
                        addButton
                    }
                }
                .padding(.top, 10)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Text("My Trips")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    private var pickerView: some View {
        CustomSegmentedPicker(
            selection: $selectedSegment,
            items: ["Trips", "Past Trips"]
        )
        .frame(height: 42)
        .padding(.horizontal, 24)
    }
    
    private var addButton: some View {
        HStack {
            Spacer()
            Button(action: {
                // Create new trip action
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

// MARK: - Components

struct CustomSegmentedPicker: UIViewRepresentable {
    @Binding var selection: Int
    let items: [String]
    
    func makeUIView(context: Context) -> UISegmentedControl {
        let control = TallSegmentedControl(items: items)
        control.selectedSegmentIndex = selection
        control.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        
        // Styling
        control.selectedSegmentTintColor = UIColor(Color.primaryColor)
        control.backgroundColor = UIColor(Color.black.opacity(0.05))
        
        let descriptor = UIFont.systemFont(ofSize: 16, weight: .medium).fontDescriptor.withDesign(.rounded)
        let font = UIFont(descriptor: descriptor ?? UIFont.systemFont(ofSize: 16).fontDescriptor, size: 16)
        
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: font
        ], for: .selected)
        
        control.setTitleTextAttributes([
            .foregroundColor: UIColor(Color.textSecondary),
            .font: font
        ], for: .normal)
        
        return control
    }
    
    func updateUIView(_ uiView: UISegmentedControl, context: Context) {
        uiView.selectedSegmentIndex = selection
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: CustomSegmentedPicker
        
        init(_ parent: CustomSegmentedPicker) {
            self.parent = parent
        }
        
        
        @objc func valueChanged(_ sender: UISegmentedControl) {
            parent.selection = sender.selectedSegmentIndex
        }
    }
}

class TallSegmentedControl: UISegmentedControl {
    override var intrinsicContentSize: CGSize {
        // Enforce a taller height
        return CGSize(width: super.intrinsicContentSize.width, height: 42)
    }
}

struct TripCardView: View {
    let trip: TripMock
    
        var body: some View {
    
            VStack(alignment: .leading, spacing: 12) {
    
                // Header Row: Title & Status
    
                HStack(alignment: .top) {
    
                    VStack(alignment: .leading, spacing: 6) {
    
                        Text(trip.title)
    
                            .font(.system(size: 20, weight: .bold, design: .rounded))
    
                            .foregroundColor(.textPrimary)
    
                            .lineLimit(2)
    
                        
    
                        HStack(spacing: 6) {
    
                            Image(systemName: "calendar")
    
                                .font(.caption)
    
                            Text(trip.dates)
    
                                .font(.subheadline)
    
                                .fontWeight(.medium)
    
                        }
    
                        .foregroundColor(.textSecondary)
    
                    }
    
                    
    
                    Spacer()
    
                    
    
                    // Status Badge (Top Right)
    
                    statusBadge(for: trip.status)
    
                }
    
            }
    
            .padding(20)
    
            .background(.ultraThinMaterial)
    
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
                    .overlay(
            
                        RoundedRectangle(cornerRadius: 24)
            
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
            
                    )
            
                    .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 8)
            
                }
            
                
            
                    @ViewBuilder
            
                
            
                    private func statusBadge(for status: TripStatus) -> some View {
            
                
            
                        switch status {
            
                
            
                                case .current:
            
                
            
                                    HStack(spacing: 6) {
            
                
            
                                        Circle()
            
                
            
                                            .fill(Color.green)
            
                
            
                                            .frame(width: 8, height: 8)
            
                
            
                                        Text("On Trip")
            
                
            
                                            .font(.caption)
            
                
            
                                            .fontWeight(.bold)
            
                
            
                                            .foregroundColor(.green)
            
                
            
                                    }
            
                
            
                            .padding(.horizontal, 12)
            
                
            
                            .padding(.vertical, 6)
            
                
            
                            .background(Color.green.opacity(0.1))
            
                
            
                            .clipShape(Capsule())
            
                
            
                            .overlay(
            
                
            
                                Capsule()
            
                
            
                                    .stroke(Color.green.opacity(0.2), lineWidth: 1)
            
                
            
                            )
            
                
            
                        case .past:
            
                
            
                            Text(status.rawValue)
            
                
            
                                .font(.caption)
            
                
            
                                .fontWeight(.medium)
            
                
            
                                .foregroundColor(.textSecondary)
            
                
            
                                .padding(.horizontal, 10)
            
                
            
                                .padding(.vertical, 5)
            
                
            
                                .background(Color.black.opacity(0.05))
            
                
            
                                .clipShape(Capsule())
            
                
            
                        case .upcoming:
            
                
            
                            EmptyView()
            
                
            
                        }
            
                
            
                    }
            
                
            
                }

// MARK: - Mock Models

enum TripStatus: String {
    case current = "Current"
    case upcoming = "Upcoming"
    case past = "Past"
    
    var color: Color {
        switch self {
        case .current: return .green
        case .upcoming: return .primaryColor
        case .past: return .gray
        }
    }
}

struct TripMock: Identifiable {
    let id = UUID()
    let title: String
    let dates: String
    let status: TripStatus
}

#Preview {
    MyTrips()
}
