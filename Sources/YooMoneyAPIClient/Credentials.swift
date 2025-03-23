import Foundation

public struct Credentials: Sendable {
    let username: String
    let password: String
    
    var encoded: String {
        "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
    }
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

public extension Credentials {
    /// This is convenience var for debugging purposes. Make sure environment settings are gitignored and thus you won't leak credentials used during debug.
    static let fromEnvironment: Self = {
        guard let username = ProcessInfo.processInfo.environment["APP_USERNAME"] else {
            fatalError("APP_USERNAME environment variable is not set. You can set with `Edit sheme`.")
        }
        guard let password = ProcessInfo.processInfo.environment["APP_PASSWORD"] else {
            fatalError("APP_PASSWORD environment variable is not set. You can set with `Edit sheme`.")
        }
        return .init(username: username, password: password)
    }()
}
