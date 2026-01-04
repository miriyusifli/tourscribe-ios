import SwiftUI

@Observable
@MainActor
class TripItemViewModel {
    private let tripId: Int64
    private let tripItemService: TripItemServiceProtocol
    private let tripService: TripServiceProtocol
    private let tripStore: TripStore
    private let store: TripItemStore
    private let calendar = Calendar.current
    
    var isLoading = false
    var isLoadingMore = false
    var alert: AlertType? = nil
    
    var tripItems: [TripItem] { store.items }
    
    init(
        tripId: Int64,
        tripItemService: TripItemServiceProtocol = TripItemService(),
        tripService: TripServiceProtocol = TripService(),
        tripStore: TripStore = .shared,
        store: TripItemStore = .shared
    ) {
        self.tripId = tripId
        self.tripItemService = tripItemService
        self.tripService = tripService
        self.tripStore = tripStore
        self.store = store
        
        if store.tripId != tripId {
            store.clear()
        }
    }
    
    init(tripId: Int64, previewItems: [TripItem]) {
        self.tripId = tripId
        self.tripItemService = TripItemService()
        self.tripService = TripService()
        self.tripStore = .shared
        self.store = .shared
        store.setItems(previewItems, for: tripId, hasMore: false)
    }
    
    var itemsByDate: [(date: Date, items: [TimelineDisplayItem])] {
        let grouped = tripItems.reduce(into: [Date: [TimelineDisplayItem]]()) { result, item in
            for displayItem in TimelineDisplayItem.from(item) {
                result[displayItem.displayDate, default: []].append(displayItem)
            }
        }
        
        return grouped
            .sorted { $0.key < $1.key }
            .map { ($0.key, $0.value.sorted { $0.sortTime < $1.sortTime }) }
    }
    
    func activeAccommodation(for date: Date) -> TripItem? {
        let dayStart = calendar.startOfDay(for: date)
        
        return tripItems.first { item in
            guard item.itemType == .accommodation else { return false }
            let checkInDay = calendar.startOfDay(for: item.startDateTime)
            let checkOutDay = calendar.startOfDay(for: item.endDateTime)
            return dayStart >= checkInDay && dayStart < checkOutDay
        }
    }
    
    func fetchTripItems() async {
        if tripItems.isEmpty {
            isLoading = true
        }
        
        do {
            let page = try await tripItemService.fetchTripItems(for: tripId, cursor: nil, limit: AppConfig.tripItemsPageSize)
            store.setItems(page.items, for: tripId, hasMore: page.hasMore)
        } catch {
            alert = .error(String(localized: "error.generic.unknown"))
        }
        
        isLoading = false
    }
    
    func fetchAllItems() async {
        guard !store.isFullyLoaded else { return }
        
        isLoading = true
        
        do {
            let items = try await tripItemService.fetchAllTripItems(for: tripId)
            store.setItems(items, for: tripId, hasMore: false)
        } catch {
            alert = .error(String(localized: "error.generic.unknown"))
        }
        
        isLoading = false
    }
    
    func loadMore() async {
        guard store.hasMore, !store.isFullyLoaded, !isLoadingMore, !isLoading else { return }
        
        isLoadingMore = true
        
        do {
            let page = try await tripItemService.fetchTripItems(for: tripId, cursor: store.cursor, limit: AppConfig.tripItemsPageSize)
            store.appendItems(page.items, hasMore: page.hasMore)
        } catch {
            // Silent fail for load more
        }
        
        isLoadingMore = false
    }
    
    func deleteTripItem(itemId: Int64) async {
        guard let deletedItem = store.removeItem(itemId) else { return }
        
        do {
            try await tripItemService.deleteTripItem(itemId: itemId)
            await refreshTrip()
        } catch {
            store.insert(deletedItem)
            alert = .error(String(localized: "error.trip_item.delete_failed"))
        }
    }
    
    private func refreshTrip() async {
        guard let updatedTrip = try? await tripService.fetchTrip(tripId: tripId) else { return }
        tripStore.update(updatedTrip)
    }
}
