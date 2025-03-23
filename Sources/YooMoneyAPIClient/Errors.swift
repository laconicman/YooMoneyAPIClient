import Foundation

public enum ValidationError: Error {
    case blankId, missingDetails, itemCurrencyMismatch // TODO: Add associated value: `reason`.
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension ValidationError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .blankId:
            String(localized: "Order id can not be blank.")
        case .missingDetails:
            String(localized: "No order details provided (empty cart).")
        case .itemCurrencyMismatch:
            String(localized: "Currencies of items don't match order currency.")
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        default:
            String(localized: "Something went wrong.")
        }
    }
}
