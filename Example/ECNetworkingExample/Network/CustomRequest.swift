import ECNetworking

fileprivate enum Constants {
    static var isAuthenticationRequest: String { #function }
    static var requestName: String { #function }
}

protocol CustomRequest: Request {
    var isAuthenticationRequest: Bool { get }
    var requestName: String { get }
}

extension CustomRequest {
    var isAuthenticationRequest: Bool { false }
    var requestName: String { String(describing: Self.self) }
    
    var customProperties: [AnyHashable: Any] {
        [
            Constants.isAuthenticationRequest: isAuthenticationRequest,
            Constants.requestName: requestName
        ]
    }
}

extension NetworkRequest {
    var isAuthenticationRequest: Bool {
        customProperties[Constants.isAuthenticationRequest] as? Bool ?? false
    }
    
    var requestName: String? {
        customProperties[Constants.requestName] as? String
    }
}
