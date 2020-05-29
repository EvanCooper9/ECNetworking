public protocol Action {}

public protocol RequestAction: Action {
    
    typealias RequestActionClosure = (Result<URLRequest, Error>) -> Void
    
    /// Called before a request will start. Provides an opportunity to modify a request before being sent
    /// - Note: `completion` must be called, or else requests will hang.
    /// - Parameters:
    ///   - request: The request that will be sent.
    ///   - completion: A closure that captures the result of this action. Failures will prevent the request from being sent.
    func requestWillBegin(_ request: URLRequest, completion: RequestActionClosure)
}

public protocol ResponseAction: Action {
    
    typealias ResponseActionClosure<T: Request> = (Result<T.Response, Error>) -> Void
    
    /// Called after a request is received. Provides an opportunity to modify or manage a response before passing it to the caller.
    /// - Note: `completion` must be called, or else responses will hang.
    /// - Parameters:
    ///   - request: The request that was sent.
    ///   - responseBody: The body of the response.
    ///   - response: The response that was received.
    ///   - completion: A closure that captures the result of this action. Failures will prevent the response from being received by the caller.
    func responseReceived<T: Request>(sender: Networking, request: T, responseBody: T.Response, response: HTTPURLResponse, completion: @escaping ResponseActionClosure<T>)
}
