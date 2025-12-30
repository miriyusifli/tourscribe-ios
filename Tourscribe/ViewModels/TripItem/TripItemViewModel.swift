import SwiftUI

@Observable
@MainActor
class TripItemViewModel {
    private let tripId: Int64
    private let tripItemService: TripItemServiceProtocol
    private let tripService: TripServiceProtocol
    private let tripStore: TripStore
    private let calendar = Calendar.current
    
    var tripItems: [TripItem] = []
    var isLoading = false
    var isLoadingMore = false
    var hasMore = true
    var alert: AlertType? = nil
    
    private var cursor: TripItemCursor? {
        guard let last = tripItems.last else { return nil }
        return TripItemCursor(startDateTime: last.startDateTime, id: last.id)
    }
    
    init(tripId: Int64, tripItemService: TripItemServiceProtocol = TripItemService(), tripService: TripServiceProtocol = TripService(), tripStore: TripStore = .shared) {
        self.tripId = tripId
        self.tripItemService = tripItemService
        self.tripService = tripService
        self.tripStore = tripStore
    }
    
    init(tripId: Int64, previewItems: [TripItem]) {
        self.tripId = tripId
        self.tripItemService = TripItemService()
        self.tripService = TripService()
        self.tripStore = .shared
        self.tripItems = previewItems
        self.isLoading = false
    }
    
    /// Groups trip items by date. Accommodations appear on check-in and check-out days.
    var itemsByDate: [(date: Date, items: [TripItem])] {
        var grouped: [Date: [TripItem]] = [:]
        
        for item in tripItems {
            let startDay = calendar.startOfDay(for: item.startDateTime)
            grouped[startDay, default: []].append(item)
            
            // For accommodations, also add to check-out day
            if item.itemType == .accommodation {
                let endDay = calendar.startOfDay(for: item.endDateTime)
                if endDay != startDay {
                    grouped[endDay, default: []].append(item)
                }
            }
        }
        
        return grouped.sorted { $0.key < $1.key }.map { ($0.key, $0.value) }
    }
    
    /// Returns the active accommodation for a given date (staying overnight, not check-in or check-out day)
    func activeAccommodation(for date: Date) -> TripItem? {
        let dayStart = calendar.startOfDay(for: date)
        
        return tripItems.first { item in
            guard item.itemType == .accommodation else { return false }
            
            let checkInDay = calendar.startOfDay(for: item.startDateTime)
            let checkOutDay = calendar.startOfDay(for: item.endDateTime)
            
            // Show on days after check-in but before check-out (not on check-in/check-out days)
            return dayStart > checkInDay && dayStart < checkOutDay
        }
    }
    
    func fetchTripItems() async {
        if tripItems.isEmpty {
            isLoading = true
        }
        
        do {
            let page = try await tripItemService.fetchTripItems(for: tripId, cursor: nil, limit: AppConfig.tripItemsPageSize)
            tripItems = page.items
            hasMore = page.hasMore
        } catch {
            alert = .error(String(localized: "error.generic.unknown"))
        }
        
        isLoading = false
    }
    
    func loadMore() async {
        guard hasMore, !isLoadingMore, !isLoading else { return }
        
        isLoadingMore = true
        
        do {
            let page = try await tripItemService.fetchTripItems(for: tripId, cursor: cursor, limit: AppConfig.tripItemsPageSize)
            tripItems.append(contentsOf: page.items)
            hasMore = page.hasMore
        } catch {
            // Silent fail for load more
        }
        
        isLoadingMore = false
    }
    
    func deleteTripItem(itemId: Int64) async {
        guard let index = tripItems.firstIndex(where: { $0.id == itemId }) else { return }
        let deletedItem = tripItems.remove(at: index)
        
        do {
            try await tripItemService.deleteTripItem(itemId: itemId)
            await refreshTrip()
        } catch {
            tripItems.insert(deletedItem, at: min(index, tripItems.count))
            alert = .error(String(localized: "error.trip_item.delete_failed"))
        }
    }
    
    private func refreshTrip() async {
        guard let updatedTrip = try? await tripService.fetchTrip(tripId: tripId) else { return }
        tripStore.update(updatedTrip)
    }
}
