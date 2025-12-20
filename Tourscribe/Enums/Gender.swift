import Foundation

enum Gender: String, CaseIterable, Identifiable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
    
    var id: String { self.rawValue }
    
    var localizedName: String {
        switch self {
        case .male:
            return String(localized: "gender.male")
        case .female:
            return String(localized: "gender.female")
        case .other:
            return String(localized: "gender.other")
        }
    }
}
