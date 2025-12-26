//
//  TripServiceProtocol.swift
//  Tourscribe
//
//  Created by Mirabdulla Yusifli on 21.12.25.
//
import Foundation


protocol TripServiceProtocol {
    func createTrip(name: String, startDate: Date?, endDate: Date?) async throws -> Trip
    func fetchUpcomingTrips() async throws -> [Trip]
    func fetchPastTrips() async throws -> [Trip]
    func updateTrip(tripId: Int64, request: TripUpdateRequest) async throws -> Trip
    func deleteTrip(tripId: String) async throws
}
