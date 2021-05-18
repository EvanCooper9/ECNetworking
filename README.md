# ECNetworking

A simple swifty networking layer. Supports custom interceptions

```swift
let request = ListUsersRequest()
network.send(request) { result in
    switch result {
    case .failure(let error):
        showError(error)
    case .success(let users):
        showUsers(users)
    }
}
```

## Installation

> Looking for an Rx version? Checkout [RxECNetworking](https://github.com/EvanCooper9/RxECNetworking)

### SPM
```swift
.package(url: "https://github.com/EvanCooper9/ECNetworking", from: "3.0.0")
```

## Usage
> Checkout the [example project](https://github.com/EvanCooper9/ECNetworking/tree/master/Example) for detailed usage
### Initialize a `Network`
`NetworkConfiguration` defines a base URL that is used for configuring all requests.

```swift
let configuration = NetworkConfiguration(
    baseURL: URL(string: "https://example.com")!,
    logging: true
)

let network = URLSessionNetwork(configuration: configuration)
```

### Modelling requests
To model a request, conform to `Request`
```swift
struct ListUsersRequest {
    let online: Bool
}

extension ListUsersRequest: Request {

    typealias Response = [User]

    func buildRequest(with baseURL: URL) -> NetworkRequest {
        let url = baseURL.appendingPathComponent("users")
        return .init(method: .post, url: url, body: self)
    }
}
```

### Sending requests

Initialize a request and send it!
```swift
let request = ListUsersRequest(online: true)
network.send(request) { result in
    switch result {
    case .failure(let error):
        // handle error
    case .success(let response):
        // handle response which is of type ListUsersRequest.Response = [User]
    }
}
```

### Adding request actions
Actions are used to add custom behaviour during the lifecyle of a network request. Things like logging and adding authentication headers can be accomplished through Actions. There are 4 types of actions. 
- `RequestWillBeginAction` - modify/handle a request before it begins
- `RequestBeganAction` - notifies a request has begun
- `ResponseBeganAction` - notifies a response has been received
- `ResponseCompletedAction` - modify/handle a response before passing it to the caller

> Note: A default logging action is available for use through the `logging` property of `NetworkConfiguration`. The example project has an additional `AuthenticationAction` example.

## Extending Requests
It may be useful to add other properties to a request. An authentication action, for example, might add authentication headers to requests before they're sent, but not all requests require authentication, like a login request.

>Note: A `Request` is transformed to a `NetworkRequest` through `buildRequest(baseURL:)` when being sent. Additional information can be persisted through `customProperties`. When implementing actions, you can act on the data stored within `customProperties` of a given `NetworkRequest`.

```swift
protocol MyRequest: Request {
    var requiresAuthentication: Bool { get }
}

extension MyRequest {
    // Provide default implementation if you want
    var requiresAuthentication: Bool { true }

    // Implement `customProperties` from `Request`
    var customProperties: [AnyHashable: Any] {
        ["requiresAuthentication": requiresAuthentication]
    }
}

extension NetworkRequest {
    var requiresAuthentication: Bool {
        customProperties["requiresAuthentication"] as? Bool ?? false
    }
}
```
And then when modelling requests,

```swift
struct LoginRequest {
    let username: String
    let password: String
}

// Conform to `MyRequest` instead of `Request`
extension LoginRequest: MyRequest {
    var requiresAuthentication: Bool { false }
    // ...
}
```

And then in your action,

```swift
struct AuthenticationAction: RequestWillBeginAction {
    func requestWillBegin(_ request: NetworkRequest, completion: @escaping RequestCompletion) {
        guard request.requiresAuthentication else { return }
        // Add authentication headers
    }
}
```

## License
ECNetworking is available under the MIT license. See the LICENSE file for more info.
