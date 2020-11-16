import Foundation

public final class Network {
    
    // MARK: - Private Properties
    
    private var actions: [Action]
    private let configuration: NetworkConfiguration
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
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
    
    public init(actions: [Action] = [], configuration: NetworkConfiguration, decoder: JSONDecoder = .init(), encoder: JSONEncoder = .init(), session: URLSession = .shared) {
        self.actions = actions
        self.configuration = configuration
        self.decoder = decoder
        self.encoder = encoder
        self.session = session
        
        if configuration.logging {
            add(action: LoggingAction())
        }
    }
}

// MARK: - Request Sending

extension Network: Networking {
    
    public func add(action: Action) {
        actions.append(action)
    }

    @discardableResult
    public func send<T: Request>(_ request: T, completionHandler: ((Result<T.Response, Error>) -> Void)?) -> URLSessionDataTask? {
        send(request.buildRequest(with: configuration.baseURL)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completionHandler?(.failure(error))
            case .success(let response):
                guard let data = response.data else {
                    completionHandler?(.failure(NetworkError.noData))
                    return
                }
                
                do {
                    let responseBody = try request.response(from: data, with: self.decoder)
                    completionHandler?(.success(responseBody))
                } catch {
                    completionHandler?(.failure(error))
                }
            }
        }
    }
    
    @discardableResult
    public func send(_ request: NetworkRequest, completionHandler: ((Result<NetworkResponse, Error>) -> Void)?) -> URLSessionDataTask? {
        var task: URLSessionDataTask?
        requestWillBeginActions.requestWillBegin(with: request) { [weak self] result in
            switch result {
            case .failure(let error):
                completionHandler?(.failure(error))
            case .success(let networkRequest):
                guard let self = self else { return }
                let urlRequest = self.urlRequest(from: networkRequest)
                task = self.session.dataTask(with: urlRequest) { data, response, error in
                    
                    if let error = error {
                        completionHandler?(.failure(error))
                        return
                    }
                    
                    let response = response as? HTTPURLResponse ?? HTTPURLResponse()
                    self.responseBeganActions.responseBegan(request: networkRequest, response: response)
                    let networkResponse = NetworkResponse(response: response, data: data)
                    
                    self.responseCompletedActions.responseReceived(request: networkRequest, response: networkResponse) { result in
                        switch result {
                        case .failure(let error):
                            completionHandler?(.failure(error))
                        case .success(let response):
                            completionHandler?(.success(response))
                        }
                    }
                }
                
                task?.resume()
                self.requestBeganActions.requestBegan(request: urlRequest)
            }
        }
        
        return task
    }
    
    // MARK: - Private Methods
    
    private func urlRequest(from networkRequest: NetworkRequest) -> URLRequest {
        networkRequest.asURLRequest(with: encoder)
    }
}
