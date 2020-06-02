public protocol Networking {
    func add(action: Action)
    func send<T: Request>(_ request: T, completionHandler: ((Result<T.Response, NetworkError>) -> Void)?)
}

extension Networking {
    public func send<T: Request>(_ request: T, completionHandler: ((Result<T.Response, NetworkError>) -> Void)? = nil) {
        send(request, completionHandler: completionHandler)
    }
}

public final class Network {
    
    // MARK: - Private Properties
    
    private var actions: [Action]
    private let configuration: NetworkConfiguration
    private let decoder: JSONDecoder
    private let session: URLSession
    
    private var requestWillBeginActions: [RequestWillBeginAction] {
        actions.compactMap { $0 as? RequestWillBeginAction }
    }
    
    private var requestBeganActions: [RequestBeganAction] {
        actions.compactMap { $0 as? RequestBeganAction }
    }
    
    private var responseBeganActions: [ResponseBeganAction] {
        actions.compactMap { $0 as? ResponseBeganAction }
    }
    
    private var responseCompletedActions: [ResponseCompletedAction] {
        actions.compactMap { $0 as? ResponseCompletedAction }
    }

    // MARK: - Lifecycle
    
    public init(actions: [Action] = [], configuration: NetworkConfiguration, decoder: JSONDecoder = JSONDecoder(), session: URLSession = .shared) {
        self.actions = actions
        self.configuration = configuration
        self.decoder = decoder
        self.session = session
        
        guard configuration.logging else { return }
        add(action: LoggingAction())
    }
}

// MARK: - Request Sending

extension Network: Networking {
    
    public func add(action: Action) {
        actions.append(action)
    }

    public func send<T: Request>(_ request: T, completionHandler: ((Result<T.Response, NetworkError>) -> Void)?) {
        var networkRequest = request.buildRequest(with: configuration.baseURL)
        networkRequest.customProperties = request.customProperties
        
        requestWillBeginActions.requestWillBegin(with: networkRequest) { result in
            switch result {
            case .failure:
                completionHandler?(.failure(.unknown))
            case .success(let networkRequest):
                
                let urlRequest = networkRequest.asURLRequest()
                
                requestBeganActions.requestBegan(request: urlRequest)
                
                let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
                    guard let self = self else { return }
                    
                    if error != nil {
                        completionHandler?(.failure(.unknown))
                        return
                    }
                    
                    guard let response = response as? HTTPURLResponse else {
                        completionHandler?(.failure(.unknown))
                        return
                    }
                    
                    self.responseBeganActions.responseBegan(request: networkRequest, response: response)
                    
                    if let networkError = NetworkError(rawValue: response.statusCode) {
                        completionHandler?(.failure(networkError))
                        return
                    }
                    
                    guard let data = data,
                        let responseBody = try? request.response(from: data, with: self.decoder) else {
                            completionHandler?(.failure(.unknown))
                            return
                    }
                    
                    self.responseCompletedActions.responseReceived(request: request, responseBody: responseBody, response: response) { result in
                        switch result {
                        case .failure:
                            completionHandler?(.failure(.unknown))
                        case .success(let newResponse):
                            completionHandler?(.success(newResponse))
                        }
                    }
                }
                
                task.resume()
            }
        }
    }
}
