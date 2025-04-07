import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes
import Foundation
import OSLogLoggingMiddleware

// Convenient alias to distinguish this particular client
public typealias YooClient = YooMoneyAPI.Client
public typealias Receipt = Components.Schemas.Receipt

public extension Client {
    init(serverURL: URL? = nil, credentials: Credentials, bodyLoggingConfiguration: BodyLoggingPolicy = .never) throws {
        let serverURL =  try serverURL ?? (Servers.Server1.url()) // Maybe spec server is used anyway.
        let configuration = Configuration(dateTranscoder: .iso8601WithFractionalSeconds)
        let basicAuthMiddleware = HeaderMiddleware(authorizationHeaderFieldValue: "Basic \(credentials.encoded)")
        let middlewares: [any ClientMiddleware]
        if #available(macOS 11.0, *) {
            middlewares = [basicAuthMiddleware, OSLogLoggingMiddleware(bodyLoggingConfiguration: .upTo(maxBytes: 2048))]
        } else {
            // Fallback on earlier versions
            middlewares = [basicAuthMiddleware]
        }
        self = Client(
            serverURL: serverURL,
            configuration: configuration,
            transport: URLSessionTransport(),
            middlewares: middlewares
        )
    }
    
    /// Reusable formatter to perform API specific conversions of `Double` often expressed as `String` throughout API.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static let floatingPointFormatStyle = FloatingPointFormatStyle<Double>(locale: Locale(identifier: "en_US"))
        .decimalSeparator(strategy: .automatic)
        .grouping(.never)
        .precision(.fractionLength(0...2))
   
}

public extension String {
    /// Convenience converter for stringly expressed numbers throughout API. Backed by reusable modern `FloatingPointFormatStyle`.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    var double: Double {
        (try? Double(self, format: Client.floatingPointFormatStyle)) ?? 0.0
    }
}

public extension Double {
    /// Convenience converter for stringly expressed numbers throughout API. Backed by reusable modern `FloatingPointFormatStyle`.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    var string: String {
        formatted(Client.floatingPointFormatStyle)
    }
}
