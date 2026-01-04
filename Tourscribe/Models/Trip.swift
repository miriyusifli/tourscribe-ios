import SwiftUI

struct Trip: Identifiable, Codable, Hashable {
    let id: Int64
    let userId: UUID
    let name: String
    let imgUrl: String
    let startDate: Date?
    let endDate: Date?
    let version: Int
    let createdAt: Date
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name, version
        case userId = "user_id"
        case imgUrl = "img_url"
        case startDate = "start_date"
        case endDate = "end_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var daysUntilStart: Int? {
        guard let startDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: startDate).day
    }
    
    var isOngoing: Bool {
        guard let start = startDate, let end = endDate else { return false }
        let now = Date()
        return now >= start && now <= end
    }
    
    var isPast: Bool {
        guard let endDate else { return false }
        return Date() > endDate
    }
    
    var isFuture: Bool {
        guard let startDate else { return false }
        return Date() < startDate
    }
    
    var daysSinceEnd: Int? {
        guard let endDate else { return nil }
        guard let days = Calendar.current.dateComponents([.day], from: endDate, to: Date()).day else { return nil }
        return max(0, days)
    }
    
    var relativeTimeLabel: String? {
        guard startDate != nil, endDate != nil else { return nil }
        
        if isOngoing {
            return String(localized: "trip.status.ongoing")
        }
        
        if isPast, let days = daysSinceEnd {
            if days == 0 { return String(localized: "trip.status.ended_today") }
            if days <= 30 { return String(localized: "trip.status.days_ago.\(days)") }
            let months = days / 30
            if months < 12 { return String(localized: "trip.status.months_ago.\(months)") }
            let years = months / 12
            return String(localized: "trip.status.years_ago.\(years)")
        }
        
        if let days = daysUntilStart, days >= 0 {
            if days <= 30 { return String(localized: "trip.status.in_days.\(days)") }
            let months = days / 30
            if months < 12 { return String(localized: "trip.status.in_months.\(months)") }
            let years = months / 12
            return String(localized: "trip.status.in_years.\(years)")
        }
        
        return nil
    }
}
