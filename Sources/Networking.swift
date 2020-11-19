import Foundation

public protocol Networking {
    func add(action: Action)
    @discardableResult func send<T: Request>(_ request: T, completion: ((Result<T.Response, Error>) -> Void)?) -> URLSessionDataTask?
    @discardableResult func send(_ request: NetworkRequest, completion: ((Result<NetworkResponse, Error>) -> Void)?) -> URLSessionDataTask?
}

extension Networking {
    
    @discardableResult
    func send<T: Request>(_ request: T, completion: ((Result<T.Response, Error>) -> Void)? = nil) -> URLSessionDataTask? {
        send(request, completion: completion)
    }
    
    public func send<T: Request>(_ request: T, completion: ((Result<T.Response, Error>) -> Void)? = nil) {
        send(request, completion: completion)
    }
}
