//
//  TripServiceProtocol.swift
//  Tourscribe
//
//  Created by Mirabdulla Yusifli on 21.12.25.
//
import Foundation


protocol TripServiceProtocol {
    func createTrip(name: String, startDate: Date?, endDate: Date?) async throws -> Trip
    func fetchTrips() async throws -> [Trip]
}
