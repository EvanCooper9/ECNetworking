public protocol Networking {
    func add(action: Action)
    func send<T: Request>(_ request: T, completionHandler: @escaping ((Result<T.Response, Error>) -> Void))
}

extension Networking {
    public func send<T: Request>(_ request: T, completionHandler: @escaping ((Result<T.Response, Error>) -> Void)) {
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
    
    public func send<T: Request>(_ request: T, completionHandler: @escaping ((Result<T.Response, Error>) -> Void)) {
        let urlRequest = URLRequest(request: request, baseURL: configuration.baseURL)
        requestWillBeginActions.requestWillBegin(with: urlRequest) { result in
            switch result {
            case .failure(let error):
                completionHandler(.failure(error))
            case .success(let urlRequest):
                
                requestBeganActions.requestBegan(request: urlRequest)
                
                let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        completionHandler(.failure(error))
                        return
                    }
                    
                    guard let response = response as? HTTPURLResponse else {
                        completionHandler(.failure(NetworkError.badResponse))
                        return
                    }
                    
                    self.responseBeganActions.responseBegan(network: self, request: request, response: response)
                    
                    guard let data = data,
                        let responseBody = try? request.response(from: data, with: self.decoder) else {
                            completionHandler(.failure(NetworkError.badResponse))
                            return
                    }
                    
                    self.responseCompletedActions.responseReceived(sender: self, request: request, responseBody: responseBody, response: response) { result in
                        switch result {
                        case .failure(let error):
                            completionHandler(.failure(error))
                        case .success(let newResponse):
                            completionHandler(.success(newResponse))
                        }
                    }
                }
                
                task.resume()
            }
        }
    }
}
