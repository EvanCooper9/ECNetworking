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

### SPM
```swift
.package(url: "https://github.com/EvanCooper9/ECNetworking", from: "1.0.0")
```

### Cocoapods
```ruby
pod 'ECNetworking'
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
let network = Network(configuration: configuration)
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

## License
ECNetworking is available under the MIT license. See the LICENSE file for more info.
