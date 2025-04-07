# YooMoney (YooKassa) client library

Project is using [Swift OpenAPI Generator](https://github.com/apple/swift-openapi-generator), connected as plugin, so it automatically regenerates the code to reflect changes made to OpenAPI specifiation in `openapi.yaml`.
Keep this in mind if you need to make changes to API related logic and feel free to propose pull requests.

> **Disclaimer:** This is unoficial project, build only based on [the ofical doc](https://yookassa.ru/developers/api).
OpenAPI specification was as well build by the author of the project since no official one was provided even by requests.

## Overview

A library package that exposes generated (from OpenAPI specification) client as is. Allows to make all requests including cases where mutually exclusive parameters could be passed to endpoints.

Under the hood, the client uses the [URLSession](https://developer.apple.com/documentation/foundation/urlsession) API to perform the HTTP calls, wrapped in the [Swift OpenAPI URLSession Transport](https://github.com/apple/swift-openapi-urlsession).
For header mutation `HTTPTypes` is used.

## Regenerate code

Whenever the `openapi.yaml` document changes, rerun the code generation.
Open terminal at package folder and:
```console
% swift package generate-code-from-openapi
Plugin ‘OpenAPIGeneratorCommand’ wants permission to write to the package directory.
Stated reason: “To write the generated Swift files back into the source directory of the package.”.
Allow this plugin to write to the package directory? (yes/no) yes
...
✅ OpenAPI code generation for target 'CommandPluginInvocationClient' successfully completed.
```

## Usage

In another package or project, add this one as a package dependency.

Then, use the provided client API:

```swift
import YooClient

let client = YooClient()
let message = try await client.createPayment(amount: 123)
print("Received the greeting message: \(message)")
```

For testing purposes you can use default `Credentials` `fromEnvironment` static var. In this case you need to set environment variables "APP_USERNAME" and "APP_PASSWORD". In Xcode you can set them with `Edit sheme` menu.

## TODO:
 - Move `HeaderMiddleware` to a separate SPM (as with `OSLogLoggingMiddleware`).
 - Document main funcs
 - Refactor OpenAPI spec as for `Confirmation` related schemas. [done].
   Note that Swift types for schemas with `discriminator` have two issues:
   Refer to: https://github.com/OAI/OpenAPI-Specification/blob/main/versions/3.1.0.md
   1) When generating type from the the most laconic `discriminator`-`allOf` notation (when and all schemas comprising the parent schema include parent in allOf of their schema.) it is not possible to init the type properly. Only the map identifier can be passed to enum.
   2) When generating type from `discriminator`-`oneOf` notation (when and all schemas comprising the parent schema include parent in allOf of their schema but we list them explicitly via `oneOf`) we end up in recursion.
   It is possible to break recursion by introducing `Base` type. But yet generated init is too verbose and not too smart. We can make things more strict by introducing `const` in for discriminator field in child schemas, but it works only for primitive schemas (compare `Confirmation` and `PaymentMethod`, `PaymentMethodData`). 
   Default attribute works neither way.
 - Unify `Receipt` and CreatePaymentReceipt` by sharing common properties with `ReceiptBase` by means of `allOff`.
   
