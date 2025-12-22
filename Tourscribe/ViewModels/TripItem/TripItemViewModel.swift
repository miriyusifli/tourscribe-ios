import SwiftUI
import Combine

@Observable
@MainActor
class TripItemViewModel {
    private let tripId: Int64
    private let tripItemService: TripItemServiceProtocol
    
    var tripItems: [TripItem] = []
    var isLoading = false
    var alert: AlertType? = nil
    
    init(tripId: Int64, tripItemService: TripItemServiceProtocol = TripItemService()) {
        self.tripId = tripId
        self.tripItemService = tripItemService
    }
    
    func fetchTripItems() async {
        isLoading = true
        do {
            tripItems = try await tripItemService.fetchTripItems(for: tripId)
        } catch {
            alert = .error(String(localized: "error.generic.unknown"))
        }
        isLoading = false
    }
    
    func createTripItem(name: String, itemType: TripItemType, startTime: Date?, endTime: Date?, metadata: TripItemMetadata?) async {
        isLoading = true
        let request = TripItemCreateRequest(
            tripId: tripId,
            name: name,
            itemType: itemType,
            startTime: startTime,
            endTime: endTime,
            metadata: metadata
        )
        do {
            let newItem = try await tripItemService.createTripItem(item: request)
            tripItems.append(newItem)
            tripItems.sort { ($0.startTime ?? .distantPast) < ($1.startTime ?? .distantPast) }
        } catch {
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
            let updatedItem = try await tripItemService.updateTripItem(itemId: item.id, data: request)
            tripItems[index] = updatedItem
        } catch {
            alert = .error(String(localized: "error.generic.unknown"))
        }
    }
    
    func deleteTripItem(itemId: Int64) async {
        tripItems.removeAll { $0.id == itemId }
        
        do {
            try await tripItemService.deleteTripItem(itemId: itemId)
        } catch {
            alert = .error(String(localized: "error.trip_item.delete_failed"))
            await fetchTripItems()
        }
    }
}
