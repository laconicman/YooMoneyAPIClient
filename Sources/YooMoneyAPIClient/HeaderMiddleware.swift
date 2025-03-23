import OpenAPIRuntime
import Foundation
import HTTPTypes

/// A client middleware that injects a value into header field of the request.
package struct HeaderMiddleware { // This might want to be `public` someday.
    /// Header name to set
    private let httpFieldName: HTTPField.Name

    /// The value for the `Authorization` header field.
    private let value: String

    /// Creates a new middleware with conveniece init.
    /// - Parameter authorizationHeaderFieldValue: The value for the `Authorization` header field.
    package init(authorizationHeaderFieldValue value: String) {
        self.httpFieldName = .authorization
        self.value = value
    }

    /// Creates a new middleware.
    /// - Parameter httpFieldName: The header field to set with `value`.
    /// - Parameter value: The value for the `httpFieldName` header field.
    package init(httpFieldname: HTTPField.Name = .authorization, value: String) {
        self.httpFieldName = httpFieldname
        self.value = value
    }

}

extension HeaderMiddleware: ClientMiddleware {
    package func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        // Adds the `Authorization` header field with the provided value.
        request.headerFields[httpFieldName] = value
        // !!!: This is temporary solution. Needs optimizing.
        let idempotenceKey: String
        if let body {
            idempotenceKey = operationID + String(body.hashValue)
        } else {
            idempotenceKey = UUID().uuidString
        }
        request.headerFields[.init("Idempotence-Key")!] = idempotenceKey
        return try await next(request, body, baseURL)
    }
}
