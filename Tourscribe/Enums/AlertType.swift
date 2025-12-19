import Foundation

enum AlertType: Identifiable {
    case validation(String)
    case error(String)
    
    var id: String {
        switch self {
        case .validation(let message), .error(let message):
            return message
        }
    }
    
    var message: String {
        switch self {
        case .validation(let message), .error(let message):
            return message
        }
    }
    
    var title: String {
        switch self {
        case .validation: return String(localized: "alert.title.validation")
        case .error: return String(localized: "alert.title.error")
        }
    }
}
