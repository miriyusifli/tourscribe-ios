import Foundation

enum ValidationHelper {
    
    private static let emailPredicate: NSPredicate = {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex)
    }()
    
    static func isValidEmail(_ email: String) -> Bool {
        return emailPredicate.evaluate(with: email)
    }
    
    static func isValidPassword(_ password: String) -> Bool {
        password.count >= 6
    }
}
