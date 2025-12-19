import Foundation

struct Interest: Identifiable {
    let id: String
    let emoji: String
    
    // Computed properties fetch localized strings dynamically
    var name: String {
        NSLocalizedString("interest.\(id).name", comment: "")
    }
    
    var description: String {
        NSLocalizedString("interest.\(id).description", comment: "")
    }
    
    static let all: [Interest] = [
        Interest(id: "beach", emoji: "🏖️"),
        Interest(id: "mountains", emoji: "🏔️"),
        Interest(id: "culture", emoji: "🏛️"),
        Interest(id: "food", emoji: "🍜"),
        Interest(id: "art", emoji: "🎨"),
        Interest(id: "nightlife", emoji: "🌃"),
        Interest(id: "adventure", emoji: "🏕️"),
        Interest(id: "shopping", emoji: "🛍️"),
        Interest(id: "photography", emoji: "📸"),
        Interest(id: "wellness", emoji: "🧘")
    ]
}
