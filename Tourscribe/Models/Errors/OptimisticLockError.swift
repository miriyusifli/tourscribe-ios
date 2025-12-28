import Foundation

enum OptimisticLockError: LocalizedError {
    case versionConflict
    
    var errorDescription: String? {
        switch self {
        case .versionConflict:
            return String(localized: "error.optimistic_lock.version_conflict")
        }
    }
}
