//
//  TripServiceProtocol.swift
//  Tourscribe
//
//  Created by Mirabdulla Yusifli on 21.12.25.
//
import Foundation

import Foundation

protocol TripServiceProtocol {
    func createTrip(request: TripCreateRequest) async throws -> Trip
    func fetchUpcomingTrips(cursor: TripCursor?, limit: Int) async throws -> TripPage
    func fetchPastTrips(cursor: TripCursor?, limit: Int) async throws -> TripPage
    func fetchTrip(tripId: Int64) async throws -> Trip
    func updateTrip(tripId: Int64, request: TripUpdateRequest) async throws -> Trip
    func deleteTrip(tripId: Int64) async throws
}
