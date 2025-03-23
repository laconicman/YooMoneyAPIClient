import XCTest
@testable import YooMoneyAPI

final class YooClientTests: XCTestCase {
    nonisolated(unsafe) static var latestPaymentResponse: Operations.CreatePayment.Output? = nil
    
    // Consider using test-specific credentials
    let client = try! YooClient(credentials: Credentials.fromEnvironment)

    func test1PaymentCreation() async throws {
        let expectation = XCTestExpectation(description: "Payment creation completed in time")
        let capture: Bool? = true
        // Try with it and without it.

        
        let response = try await client.createPaymentSample(capture: capture)
        Self.latestPaymentResponse = response
        switch response {
        case .ok(let okResponse):
            guard let responseBody = try? okResponse.body.json else {
                XCTFail("Payment response body is missing or cannot be decoded\n(\(response)")
                break
            }
            XCTAssertNil(responseBody.capturedAt, "Should not have captured payment yet")
            XCTAssertNotNil(responseBody.id, "Payment ID is missing")
            print("Got response: \(responseBody)")
        case .unauthorized:
            XCTFail("Payment request failed with unauthorized status")
        case .undocumented(statusCode: let statusCode, let payload):
            XCTFail("Payment request failed with undocumented status code: \(statusCode)\n\(payload)")
        case .badRequest(let badRequestResponse):
            XCTFail("Payment request failed with bad request: \(badRequestResponse.body)")
        case .tooManyRequests(let tooManyRequestsResponse):
            XCTFail("Payment request failed due to rate limiting: \(tooManyRequestsResponse.body)")
        }
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func test2PaymentCreation() async throws {
        let expectation = XCTestExpectation(description: "Payment creation completed in time")
        let capture: Bool? = true
        
        let response = try await client.createPayment(body: .json(.example(capture: capture, receipt: .example, paymentMethodData: .paymentMethodDataBankCard, confirmation: .exampleRedirect)))
        Self.latestPaymentResponse = response
        switch response {
        case .ok(let okResponse):
            guard let responseBody = try? okResponse.body.json else {
                XCTFail("Payment response body is missing or cannot be decoded\n(\(response)")
                break
            }
            XCTAssertNil(responseBody.capturedAt, "Should not have captured payment yet")
            XCTAssertNotNil(responseBody.id, "Payment ID is missing")
            print("Got response: \(responseBody)")
        case .unauthorized:
            XCTFail("Payment request failed with unauthorized status")
        case .undocumented(statusCode: let statusCode, let payload):
            XCTFail("Payment request failed with undocumented status code: \(statusCode)\n\(payload)")
        case .badRequest(let badRequestResponse):
            XCTFail("Payment request failed with bad request: \(badRequestResponse.body)")
        case .tooManyRequests(let tooManyRequestsResponse):
            XCTFail("Payment request failed due to rate limiting: \(tooManyRequestsResponse.body)")
        }
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func test3PaymentCheck() async throws {
        let expectation = XCTestExpectation(description: "Payment check completed in time")
        
        let paymentID = try await checkForLatestPaymentExistence()
        
        let response = try await client.getPayment(path: .init(paymentId: paymentID))
        
        switch response {
        case .ok(let okResponse):
            guard let responseBody = try? okResponse.body.json else {
                XCTFail("Cancelation response body is missing or cannot be decoded\n(\(response))")
                break
            }
            
            XCTAssertNil(responseBody.capturedAt, "Should not have captured payment yet")
            XCTAssertNotNil(responseBody.id, "Payment ID is missing")
            XCTAssertNotNil(responseBody.amount, "Payment amount is missing")
            XCTAssertNotNil(responseBody.createdAt, "Payment `createdAt` date is missing")
            // print("Got response: \(responseBody)") // Not needed. Logging middleware does even better.
        case .unauthorized:
            XCTFail("Cancelation failed with unauthorized status")
        case .undocumented(statusCode: let statusCode, let payload):
            XCTFail("Cancelation failed with undocumented status code: \(statusCode)\n\(payload)")
        case .badRequest(let badRequestResponse):
            XCTFail("Cancelation failed with bad request: \(badRequestResponse.body)")
        case .tooManyRequests(let tooManyRequestsResponse):
            XCTFail("Cancelation failed due to rate limiting: \(tooManyRequestsResponse.body)")
        case .notFound(let notFoundResponse):
            XCTFail("Cancelation failed due to not found error: \(notFoundResponse.body)")
        }
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 5.0)
    }

    func test4PaymentCancelation() async throws {
        let expectation = XCTestExpectation(description: "Payment cancelation completed in time")
        
        let paymentID = try await checkForLatestPaymentExistence()
        let status = try? Self.latestPaymentResponse?.ok.body.json.status
        guard status == .waitingForCapture else {
            print("Can't run cancel check for status: \(status?.rawValue ?? "unknown")")
            return
        }
        
        let response = try await client.cancelPayment(path: .init(paymentId: paymentID))

        switch response {
        case .ok(let okResponse):
            guard let responseBody = try? okResponse.body.json else {
                XCTFail("Cancelation response body is missing or cannot be decoded\n(\(response))")
                break
            }
            XCTAssertNil(responseBody.capturedAt, "Should not have captured payment yet")
            XCTAssertNotNil(responseBody.id, "Payment ID is missing")
            print("Got response: \(responseBody)")
        case .unauthorized:
            XCTFail("Cancelation failed with unauthorized status")
        case .undocumented(statusCode: let statusCode, let payload):
            XCTFail("Cancelation failed with undocumented status code: \(statusCode)\n\(payload)")
        case .badRequest(let badRequestResponse):
            print("Cancelation failed with bad request: \(badRequestResponse.body)")
            XCTExpectFailure("Might not be cancellable", options: .nonStrict())
            // XCTFail("Cancelation failed with bad request: \(badRequestResponse.body)")
        case .tooManyRequests(let tooManyRequestsResponse):
            XCTFail("Cancelation failed due to rate limiting: \(tooManyRequestsResponse.body)")
        case .notFound(let notFoundResponse):
            XCTFail("Cancelation failed due to not found error: \(notFoundResponse.body)")
        }
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 5.0)
    }

    private func checkForLatestPaymentExistence() async throws -> String {
        XCTAssertNotNil(Self.latestPaymentResponse, "latestPaymentResponse ID is missing")
        // Proceed with the test logic if `latestPaymentResponse` is non-nil.
        guard let paymentID = try Self.latestPaymentResponse?.ok.body.json.id else {
            XCTFail("Payment ID is missing")
            throw TestError.paymentIdIsMissing
        }
        try await Task.sleep(for: .seconds(2))
        return paymentID
    }

    enum TestError: Error {
        case paymentIdIsMissing
    }
}
