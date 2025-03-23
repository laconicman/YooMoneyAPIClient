public extension Components.Schemas.Amount {
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func from(items: [Components.Schemas.ReceiptItem]) throws -> Self {
        let amountValuesSum = items.map({ $0.amount.value.double * $0.quantity.double }).reduce(0.0, +)
        let currencies = Set(items.map(\.amount.currency))
        guard let currency = currencies.first, currencies.count == 1 else {
            throw ValidationError.itemCurrencyMismatch
        }
        return .init(value: amountValuesSum.string, currency: currency)
    }
    
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    init(value: Double, currency: String) {
        self.init(value: value.string, currency: currency)
    }
}

public extension Components.Schemas.CreatePaymentReceipt {
    static let example: Self = .init(customer: .exampleAllFieldsSet, items: .exampleCartOfItems)
}

public extension Components.Schemas.Customer {
    static let exampleAllFieldsSet: Self = .init(fullName: "German Aven", inn: "6321341814", email: "receipt.rentel@gmail.com", phone: "+79123456789")
    static let exampleEmail: Self = .init(email: "receipt.rentel@gmail.com")
}

public extension Components.Schemas.ReceiptItem {
    static let exampleItem1: Self = .init(description: "CopyBar", amount: .init(value: "480.0", currency: "RUB"), quantity: "4", vatCode: ._1, paymentMode: .fullPayment, paymentSubject: .commodity, measure: .piece)
    static let exampleItem2: Self = .init(description: "Pack", amount: .init(value: "4.0", currency: "RUB"), quantity: "1", vatCode: ._1, paymentMode: .fullPayment, paymentSubject: .commodity, measure: .piece)
}

public extension [Components.Schemas.ReceiptItem] {
    static let exampleCartOfItems: Self = [.exampleItem1, .exampleItem2]
}

public extension Components.Schemas.Confirmation {
    static func redirect(returnUrl: String, confirmationUrl: String? = nil, enforce: Bool? = nil, locale: String? = nil) -> Self {
        // .redirect(.init(_type: .redirect, returnUrl: returnUrl, confirmationUrl: confirmationUrl, enforce: enforce, locale: locale))
        // .redirect(.init(value1: .init(_type: .redirect), value2: .init(_type: .redirect, returnUrl: returnUrl, confirmationUrl: confirmationUrl, enforce: enforce, locale: locale)))
        .redirect(.init(value1: .init(_type: .redirect), value2: .init(returnUrl: returnUrl, confirmationUrl: confirmationUrl, enforce: enforce, locale: locale)))
    }
    static let exampleRedirect: Self = .redirect(returnUrl: "https://example.com/return")
}

public extension Components.Schemas.PaymentMethodData {
    static let paymentMethodDataBankCard: Self = .bankCard(.init(value1: .init(_type: .bankCard), value2: .init()))
    static let paymentMethodDataSbp: Self = .sbp(.init(value1: .init(_type: .sbp), value2: .init()))
}

public extension Components.Schemas.CreatePaymentRequest {
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    static func example(capture: Bool? = nil, receipt: Components.Schemas.CreatePaymentReceipt? = .example, paymentMethodData: Components.Schemas.PaymentMethodData? = nil, confirmation: Components.Schemas.Confirmation? = .exampleRedirect) throws -> Self {
        .init(amount: try .from(items: .exampleCartOfItems), description: "Example payment #\(Int.random(in: 0...10000))", paymentToken: nil, paymentMethodId: nil, paymentMethodData: paymentMethodData, confirmation: confirmation, savePaymentMethod: nil, capture: capture, clientIp: nil, metadata: nil, receipt: receipt, merchantCustomerId: nil, recipient: nil, transfers: nil, deal: nil)
    }
}
