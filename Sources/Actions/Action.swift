import Foundation

public protocol Action {}

public protocol RequestWillBeginAction: Action {
    
    typealias RequestCompletion = (Result<NetworkRequest, Error>) -> Void
    
    /// Called before a request will start. Provides an opportunity to modify a request before being sent.
    /// - Parameters:
    ///   - request: The request that will be sent.
    ///   - completion: A closure that captures the result of this action. Failures will prevent the request from being sent.
    /// - Note: Failing to call `completion` will result the request hanging.
    func requestWillBegin(_ request: NetworkRequest, completion: @escaping RequestCompletion)
}

public protocol RequestBeganAction: Action {
    
    /// Called when a request has started.
    /// - Parameter request: The request that has started.
    func requestBegan(_ request: NetworkRequest)
}

public protocol ResponseBeganAction: Action {
    
    /// Called when a response is received.
    /// - Parameters:
    ///   - request: The request that was sent.
    ///   - response: The response that was received.
    func responseBegan(request: NetworkRequest, response: NetworkResponse)
}

public protocol ResponseCompletedAction: Action {
    
    typealias ResponseCompletion = (Result<NetworkResponse, Error>) -> Void
    
    /// Called after a response is received. Provides an opportunity to modify or manage a response before passing it to the caller.
    /// - Parameters:
    ///   - request: the request that was sent
    ///   - response: the response that was received
    ///   - completion: A closure that captures the result of this action.
    /// - Note: Failing to call `completion` will result the response hanging.
    func responseCompleted(request: NetworkRequest, response: NetworkResponse, completion: @escaping ResponseCompletion)
}
