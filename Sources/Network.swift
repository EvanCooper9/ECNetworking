import Foundation

public protocol Network {
    
    typealias Priority = Operation.QueuePriority
    
    func add(action: Action)
    
    @discardableResult
    func send<T: Request>(_ request: T, withPriority priority: Priority, completion: ((Result<T.Response, Error>) -> Void)?) -> Cancellable
}

public extension Network {
    
    @discardableResult
    func send<T: Request>(_ request: T, withPriority priority: Priority = .normal, completion: ((Result<T.Response, Error>) -> Void)? = nil) -> Cancellable {
        send(request, withPriority: priority, completion: completion)
    }
}
