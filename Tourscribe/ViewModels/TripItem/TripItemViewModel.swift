import SwiftUI

@Observable
@MainActor
class TripItemViewModel {
    private let tripId: Int64
    private let tripItemService: TripItemServiceProtocol
    private let calendar = Calendar.current
    
    var tripItems: [TripItem] = []
    var isLoading = false
    var alert: AlertType? = nil
    var isShowingCreateSheet = false
    
    init(tripId: Int64, tripItemService: TripItemServiceProtocol = TripItemService()) {
        self.tripId = tripId
        self.tripItemService = tripItemService
    }
    
    init(tripId: Int64, previewItems: [TripItem]) {
        self.tripId = tripId
        self.tripItemService = TripItemService()
        self.tripItems = previewItems
        self.isLoading = false
    }
    
    /// Groups trip items by date. Accommodations appear on check-in and check-out days.
    var itemsByDate: [(date: Date, items: [TripItem])] {
        var grouped: [Date: [TripItem]] = [:]
        
        for item in tripItems {
            guard let startTime = item.startTime else { continue }
            let startDay = calendar.startOfDay(for: startTime)
            grouped[startDay, default: []].append(item)
            
            // For accommodations, also add to check-out day
            if item.itemType == .accommodation, let endTime = item.endTime {
                let endDay = calendar.startOfDay(for: endTime)
                if endDay != startDay {
                    grouped[endDay, default: []].append(item)
                }
            }
        }
        
        return grouped.sorted { $0.key < $1.key }.map { date, items in
            (date: date, items: items.sorted { ($0.startTime ?? .distantPast) < ($1.startTime ?? .distantPast) })
        }
    }
    
    /// Returns the active accommodation for a given date (staying overnight, not check-in or check-out day)
    func activeAccommodation(for date: Date) -> TripItem? {
        let dayStart = calendar.startOfDay(for: date)
        
        return tripItems.first { item in
            guard item.itemType == .accommodation,
                  let checkIn = item.startTime,
                  let checkOut = item.endTime else { return false }
            
            let checkInDay = calendar.startOfDay(for: checkIn)
            let checkOutDay = calendar.startOfDay(for: checkOut)
            
            // Show on days after check-in but before check-out (not on check-in/check-out days)
            return dayStart > checkInDay && dayStart < checkOutDay
        }
    }
    
    func fetchTripItems() async {
        isLoading = true
        do {
            tripItems = try await tripItemService.fetchTripItems(for: tripId)
        } catch {
            print(error)
            alert = .error(String(localized: "error.generic.unknown"))
        }
        isLoading = false
    }

    func updateTripItem(item: TripItem) async {
        guard let index = tripItems.firstIndex(where: { $0.id == item.id }) else { return }
        
        let request = TripItemUpdateRequest(
            name: item.name,
            itemType: item.itemType,
            startTime: item.startTime,
            endTime: item.endTime,
            metadata: item.metadata
        )
        
        do {
            let updatedItem = try await tripItemService.updateTripItem(
                itemId: item.id,
                data: request,
                locations: item.locations
            )
            tripItems[index] = updatedItem
        } catch {
            alert = .error(String(localized: "error.generic.unknown"))
        }
    }
    
    func deleteTripItem(itemId: Int64) async {
        guard let index = tripItems.firstIndex(where: { $0.id == itemId }) else { return }
        let deletedItem = tripItems.remove(at: index)
        
        do {
            try await tripItemService.deleteTripItem(itemId: itemId)
        } catch {
            tripItems.insert(deletedItem, at: min(index, tripItems.count))
            alert = .error(String(localized: "error.trip_item.delete_failed"))
        }
    }
}
