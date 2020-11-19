import Foundation

public protocol Action {}

public protocol RequestWillBeginAction: Action {
    
    /// Called before a request will start. Provides an opportunity to modify a request before being sent
    /// - Parameters:
    ///   - request: The request that will be sent.
    ///   - completion: A closure that captures the result of this action. Failures will prevent the request from being sent.
    /// - Note: Failing to call `completion` will result the request hanging.
    func requestWillBegin(_ request: NetworkRequest, completion: @escaping (Result<NetworkRequest, Error>) -> Void)
}

public protocol RequestBeganAction: Action {
    
    /// Called when a request is about to start.
    /// - Parameter request: The request that will start.
    func requestBegan(_ request: URLRequest)
}

public protocol ResponseBeganAction: Action {
    
    /// Called when a response is received.
    /// - Parameters:
    ///   - request: The request that was sent.
    ///   - response: The response that was received.
    func responseBegan(request: NetworkRequest, response: HTTPURLResponse)
}

public protocol ResponseCompletedAction: Action {
    
    /// Called after a request is received. Provides an opportunity to modify or manage a response before passing it to the caller.
    /// - Parameters:
    ///   - request: the request that was sent
    ///   - response: the response that was received
    ///   - completion: A closure that captures the result of this action.
    /// - Note: Failing to call `completion` will result the response hanging.
    func responseCompleted(request: NetworkRequest, response: NetworkResponse, completion: @escaping (Result<NetworkResponse, Error>) -> Void)
}
