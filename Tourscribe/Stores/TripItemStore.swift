import SwiftUI

/// Single source of truth for trip items shared between `TripItineraryView` and `TripMapView`.
///
/// Holds items for **one trip at a time** to minimize memory usage. When user switches trips,
/// the store should be cleared via `clear()` before loading new trip data.
///
/// ## Usage Pattern
/// - `TripItineraryView`: Uses `setItems()` + `appendItems()` for pagination
/// - `TripMapView`: Uses `setItems()` with all items, setting `hasMore: false`
/// - When Map loads all items first, `isFullyLoaded` becomes `true` and Itinerary skips pagination
@Observable
@MainActor
final class TripItemStore {
    static let shared = TripItemStore()
    
    private(set) var tripId: Int64?
    private(set) var items: [TripItem] = []
    private(set) var isFullyLoaded = false
    private(set) var hasMore = true
    
    private init() {}
    
    /// Cursor for keyset pagination based on last item.
    ///
    /// Returns `nil` if `items` is empty. The cursor uses `startDateTime` and `id`
    /// to fetch the next page of items sorted by start date.
    var cursor: TripItemCursor? {
        guard let last = items.last else { return nil }
        return TripItemCursor(startDateTime: last.startDateTime, id: last.id)
    }
    
    /// Replaces all items for a trip.
    ///
    /// - Parameters:
    ///   - items: Array of trip items, must be pre-sorted by `startDateTime` ascending
    ///   - tripId: The trip these items belong to
    ///   - hasMore: `false` if all items are loaded (e.g., from `fetchAllTripItems`)
    ///
    /// When `hasMore` is `false`, sets `isFullyLoaded = true` which prevents
    /// further pagination calls in `TripItemViewModel.loadMore()`.
    func setItems(_ items: [TripItem], for tripId: Int64, hasMore: Bool) {
        self.tripId = tripId
        self.items = items
        self.hasMore = hasMore
        self.isFullyLoaded = !hasMore
    }
    
    /// Appends paginated items to the end of existing collection.
    ///
    /// - Parameters:
    ///   - items: Next page of items, must be pre-sorted by `startDateTime` ascending
    ///   - hasMore: `false` if this is the last page
    ///
    /// Use for **pagination only** where items arrive in sorted order from the API.
    /// Does not re-sort - simply appends to the end.
    /// For inserting a single item in sorted position, use `insert(_:)` instead.
    func appendItems(_ items: [TripItem], hasMore: Bool) {
        self.items.append(contentsOf: items)
        self.hasMore = hasMore
        if !hasMore { isFullyLoaded = true }
    }
    
    /// Removes item by id for optimistic delete.
    ///
    /// - Parameter itemId: The id of the item to remove
    /// - Returns: The removed `TripItem` for rollback on API failure, or `nil` if not found
    ///
    /// Used by `TripItemViewModel.deleteTripItem()` for optimistic UI updates.
    /// If the API call fails, use `insert(_:)` to restore the item.
    func removeItem(_ itemId: Int64) -> TripItem? {
        guard let index = items.firstIndex(where: { $0.id == itemId }) else { return nil }
        return items.remove(at: index)
    }
    
    /// Inserts a single item maintaining sort order by `startDateTime`.
    ///
    /// - Parameter item: The item to insert
    ///
    /// Use for **restoring deleted items** or inserting newly created items.
    /// Finds correct position via linear search (O(n)) and inserts there.
    /// For bulk additions from API, use `appendItems(_:hasMore:)` or `setItems(_:for:hasMore:)` instead.
    func insert(_ item: TripItem) {
        let index = items.firstIndex { $0.startDateTime > item.startDateTime } ?? items.count
        items.insert(item, at: index)
    }
    
    /// Resets store to initial empty state.
    ///
    /// Call when:
    /// - User navigates to a different trip
    /// - Pull-to-refresh to force fresh data
    /// - User logs out
    func clear() {
        tripId = nil
        items = []
        isFullyLoaded = false
        hasMore = true
    }
}
