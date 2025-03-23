// MARK: Sample short hand functions primary for testing

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension APIProtocol {
    func createPaymentSample(capture: Bool? = nil, receipt: Components.Schemas.CreatePaymentReceipt? = .example, confirmation: Components.Schemas.Confirmation? = .exampleRedirect) async throws -> Operations.CreatePayment.Output {
        let body: Operations.CreatePayment.Input.Body = try .json(.example(capture: capture, receipt: .example, confirmation: .exampleRedirect))
        print(body)
        return try await createPayment(body: body)
    }
}
