import Foundation

public final class Network {
    
    // MARK: - Private Properties
    
    private var actions: [Action]
    private let configuration: NetworkConfiguration
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let session: URLSession

    // MARK: - Lifecycle
    
    public init(actions: [Action] = [], configuration: NetworkConfiguration, decoder: JSONDecoder = .init(), encoder: JSONEncoder = .init(), session: URLSession = .shared) {
        self.actions = actions
        self.configuration = configuration
        self.decoder = decoder
        self.encoder = encoder
        self.session = session
        
        if configuration.logging {
            add(action: LoggingAction(encoder: encoder))
        }
    }
}

// MARK: - Request Sending

extension Network: Networking {
    
    public func add(action: Action) {
        actions.append(action)
    }

    @discardableResult
    public func send<T: Request>(_ request: T, completion: ((Result<T.Response, Error>) -> Void)?) -> URLSessionDataTask? {
        var networkRequest = request.buildRequest(with: configuration.baseURL)
        networkRequest.customProperties = request.customProperties
        return send(networkRequest) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion?(.failure(error))
            case .success(let response):                
                guard let data = response.data else {
                    completion?(.failure(NetworkError.noData))
                    return
                }
                
                do {
                    let responseBody = try request.response(from: data, with: self.decoder)
                    completion?(.success(responseBody))
                } catch {
                    completion?(.failure(error))
                }
            }
        }
    }
    
    @discardableResult
    public func send(_ request: NetworkRequest, completion: ((Result<NetworkResponse, Error>) -> Void)?) -> URLSessionDataTask? {
        var task: URLSessionDataTask?
        requestWillBegin(request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion?(.failure(error))
            case .success(let request):
                let urlRequest = request.asURLRequest(with: self.encoder)
                task = self.session.dataTask(with: urlRequest) { data, response, error in
                    
                    if let error = error {
                        completion?(.failure(error))
                        return
                    }
                    
                    let response = NetworkResponse(
                        response: response as? HTTPURLResponse ?? .init(),
                        data: data
                    )
                    
                    self.responseBegan(request: request, response: response)
                    self.responseCompleted(request: request, response: response) { result in
                        switch result {
                        case .failure(let error):
                            completion?(.failure(error))
                        case .success(let response):
                            completion?(.success(response))
                        }
                    }
                }
                
                task?.resume()
                self.requestBegan(request)
            }
        }
        
        return task
    }
}

extension Network: RequestWillBeginAction {
    public func requestWillBegin(_ request: NetworkRequest, completion: @escaping RequestCompletion) {
        actions
            .compactMap { $0 as? RequestWillBeginAction }
            .requestWillBegin(request, completion: completion)
    }
}

extension Network: RequestBeganAction {
    public func requestBegan(_ request: NetworkRequest) {
        actions
            .compactMap { $0 as? RequestBeganAction }
            .forEach { $0.requestBegan(request) }
    }
}

extension Network: ResponseBeganAction {
    public func responseBegan(request: NetworkRequest, response: NetworkResponse) {
        actions
            .compactMap { $0 as? ResponseBeganAction }
            .forEach { $0.responseBegan(request: request, response: response) }
    }
}

extension Network: ResponseCompletedAction {
    public func responseCompleted(request: NetworkRequest, response: NetworkResponse, completion: @escaping ResponseCompletion) {
        actions
            .compactMap { $0 as? ResponseCompletedAction }
            .responseCompleted(request: request, response: response, completion: completion)
    }
}
