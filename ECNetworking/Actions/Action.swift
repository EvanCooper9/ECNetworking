public protocol Action {}

public protocol RequestWillBeginAction: Action {
    /// Called before a request will start. Provides an opportunity to modify a request before being sent
    /// - Note: `completion` must be called, or else requests will hang.
    /// - Parameters:
    ///   - request: The request that will be sent.
    ///   - completion: A closure that captures the result of this action. Failures will prevent the request from being sent.
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
    ///   - network: The network that sent the request.
    ///   - request: The request that was sent.
    ///   - response: The response that was received.
    func responseBegan(request: NetworkRequest, response: HTTPURLResponse)
}

public protocol ResponseCompletedAction: Action {
    
    typealias ResponseActionClosure<T: Request> = (Result<NetworkResult, Error>) -> Void
    
    /// Called after a request is received. Provides an opportunity to modify or manage a response before passing it to the caller.
    /// - Note: `completion` must be called, or else responses will hang.
    /// - Parameters:
    ///   - sender: The
    ///   - request: The request that was sent.
    ///   - responseBody: The body of the response.
    ///   - response: The response that was received.
    ///   - completion: A closure that captures the result of this action. Failures will prevent the response from being received by the caller.
    func responseReceived(request: NetworkRequest, result: NetworkResult, completion: @escaping (Result<NetworkResult, Error>) -> Void)
}
