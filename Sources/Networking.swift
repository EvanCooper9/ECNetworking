import Foundation

public protocol Networking {
    func add(action: Action)
    @discardableResult func send<T: Request>(_ request: T, completionHandler: ((Result<T.Response, Error>) -> Void)?) -> URLSessionDataTask?
    func send(request: NetworkRequest, completionHandler: ((Result<NetworkResult, Error>) -> Void)?)
}

extension Networking {
    
    @discardableResult
    func send<T: Request>(_ request: T, completionHandler: ((Result<T.Response, Error>) -> Void)? = nil) -> URLSessionDataTask? {
        send(request, completionHandler: completionHandler)
    }
    
    public func send<T: Request>(_ request: T, completionHandler: ((Result<T.Response, Error>) -> Void)? = nil) {
        send(request, completionHandler: completionHandler)
    }
}
