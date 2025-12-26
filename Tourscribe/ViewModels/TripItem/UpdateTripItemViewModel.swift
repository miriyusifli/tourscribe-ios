import Foundation

@Observable
@MainActor
class UpdateTripItemViewModel {
    private let tripItemService: TripItemServiceProtocol
    
    let itemType: TripItemType
    var name: String
    var startDateTime: Date
    var endDateTime: Date
    
    var location: Location?
    var departureLocation: Location?
    var arrivalLocation: Location?
    
    var airline: String
    var flightNumber: String
    var carrier: String
    var vehicleNumber: String
    
    var isLoading = false
    var errorMessage: String?
    var updatedItem: TripItem?
    
    private let originalItem: TripItem

    init(tripItem: TripItem, tripItemService: TripItemServiceProtocol = TripItemService()) {
        self.originalItem = tripItem
        self.tripItemService = tripItemService
        self.itemType = tripItem.itemType
        self.name = tripItem.name
        self.startDateTime = tripItem.startDateTime
        self.endDateTime = tripItem.endDateTime
        
        if tripItem.itemType.isMultiLocation {
            self.departureLocation = tripItem.locations.first { $0.sequence == 0 }
            self.arrivalLocation = tripItem.locations.first { $0.sequence == 1 }
        } else {
            self.location = tripItem.locations.first
        }
        
        switch tripItem.metadata {
        case .flight(let m):
            self.airline = m.airline
            self.flightNumber = m.flightNumber
            self.carrier = ""
            self.vehicleNumber = ""
        case .transport(let m):
            self.carrier = m.carrier
            self.vehicleNumber = m.vehicleNumber
            self.airline = ""
            self.flightNumber = ""
        default:
            self.airline = ""
            self.flightNumber = ""
            self.carrier = ""
            self.vehicleNumber = ""
        }
    }
    
    func updateTripItem() async {
        errorMessage = nil
        
        let locations: [Location]
        if itemType.isMultiLocation {
            locations = [departureLocation, arrivalLocation]
                .compactMap { $0 }
                .enumerated()
                .map { $0.element.withSequence($0.offset) }
        } else {
            locations = [location].compactMap { $0?.withSequence(0) }
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let request = try TripItemUpdateRequest(
                name: name,
                itemType: itemType,
                startDateTime: startDateTime,
                endDateTime: endDateTime,
                metadata: buildMetadata(),
                locations: locations
            )
            updatedItem = try await tripItemService.updateTripItem(itemId: originalItem.id, request: request)
        } catch let error as TripItemValidationError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = String(localized: "error.generic.unknown")
        }
    }
    
    private func buildMetadata() -> TripItemMetadata {
        switch itemType {
        case .flight:
            return .flight(FlightMetadata(airline: airline, flightNumber: flightNumber))
        case .accommodation:
            return .accommodation(AccommodationMetadata())
        case .activity:
            return .activity(ActivityMetadata())
        case .restaurant:
            return .restaurant(RestaurantMetadata())
        case .transport:
            return .transport(TransportMetadata(carrier: carrier, vehicleNumber: vehicleNumber))
        }
    }
}
