import Foundation

struct Interest: Identifiable {
    let id: String
    let emoji: String
    private let _name: String?
    private let _description: String?
    
    init(id: String, emoji: String, name: String? = nil, description: String? = nil) {
        self.id = id
        self.emoji = emoji
        self._name = name
        self._description = description
    }
    
    // Computed properties fetch localized strings dynamically if explicit values aren't provided
    var name: String {
        _name ?? NSLocalizedString("interest.\(id).name", comment: "")
    }
    
    var description: String {
        _description ?? NSLocalizedString("interest.\(id).description", comment: "")
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
