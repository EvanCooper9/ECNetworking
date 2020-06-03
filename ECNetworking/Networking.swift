public protocol Networking {
    func add(action: Action)
    func send<T: Request>(_ request: T, completionHandler: ((Result<T.Response, Error>) -> Void)?)
    func send(request: NetworkRequest, completionHandler: ((Result<NetworkResult, Error>) -> Void)?)
}

extension Networking {
    public func send<T: Request>(_ request: T, completionHandler: ((Result<T.Response, Error>) -> Void)? = nil) {
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

    public func send<T: Request>(_ request: T, completionHandler: ((Result<T.Response, Error>) -> Void)?) {
        var networkRequest = request.buildRequest(with: configuration.baseURL)
        networkRequest.customProperties = request.customProperties
        
        requestWillBeginActions.requestWillBegin(with: networkRequest) { result in
            switch result {
            case .failure:
                completionHandler?(.failure(NetworkError.unknown))
            case .success(let networkRequest):
                
                let urlRequest = networkRequest.asURLRequest()
                
                let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
                    guard let self = self else { return }
                    
                    let result: NetworkResult
                    
                    if let response = response as? HTTPURLResponse {
                        let networkResponse = NetworkResponse(response: response, data: data)
                        if let error = error {
                            result = .failure(networkResponse, error)
                        } else if let networkError = NetworkError(rawValue: response.statusCode) {
                            result = .failure(networkResponse, networkError)
                        } else {
                            result = .success(networkResponse)
                        }
                        
                        self.responseBeganActions.responseBegan(request: networkRequest, response: response)
                    } else {
                        result = .failure(.init(response: HTTPURLResponse(), data: data), error ?? NetworkError.unknown)
                    }
                    
                    self.responseCompletedActions.responseReceived(request: networkRequest, result: result) { result in
                        switch result {
                        case .failure(let error):
                            completionHandler?(.failure(error))
                        case .success(let result):
                            switch result {
                            case .failure(let response, let error):
                                completionHandler?(.failure(error))
                            case .success(let response):
                                if let data = response.data, let responseBody = try? request.response(from: data, with: self.decoder) {
                                    completionHandler?(.success(responseBody))
                                } else {
                                    completionHandler?(.failure(NetworkError.unknown))
                                }
                            }
                        }
                    }
                }
                
                task.resume()
                requestBeganActions.requestBegan(request: urlRequest)
            }
        }
    }
    
    public func send(request: NetworkRequest, completionHandler: ((Result<NetworkResult, Error>) -> Void)?) {
        let urlRequest = request.asURLRequest()
        
        requestWillBeginActions.requestWillBegin(with: request) { result in
            switch result {
            case .failure:
                completionHandler?(.failure(NetworkError.unknown))
            case .success(let networkRequest):
                
                let urlRequest = networkRequest.asURLRequest()
                
                let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
                    guard let self = self else { return }
                    
                    let result: NetworkResult
                    
                    if let response = response as? HTTPURLResponse {
                        let networkResponse = NetworkResponse(response: response, data: data)
                        if let error = error {
                            result = .failure(networkResponse, error)
                        } else if let networkError = NetworkError(rawValue: response.statusCode) {
                            result = .failure(networkResponse, networkError)
                        } else {
                            result = .success(networkResponse)
                        }
                        
                        self.responseBeganActions.responseBegan(request: networkRequest, response: response)
                    } else {
                        result = .failure(.init(response: HTTPURLResponse(), data: data), error ?? NetworkError.unknown)
                    }
                    
                    self.responseCompletedActions.responseReceived(request: networkRequest, result: result) { result in
                        switch result {
                        case .failure(let error):
                            completionHandler?(.failure(error))
                        case .success(let response):
                            completionHandler?(.success(response))
                        }
                    }
                }
                
                task.resume()
                requestBeganActions.requestBegan(request: urlRequest)
            }
        }
    }
}
