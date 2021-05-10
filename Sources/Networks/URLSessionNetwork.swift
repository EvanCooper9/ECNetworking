import Foundation

public final class URLSessionNetwork {
    
    // MARK: - Private Properties
    
    private var actions: [Action]
    private let configuration: NetworkConfiguration
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let session: URLSession
    
    private lazy var requestQueue: OperationQueue = {
        let queue = OperationQueue()
        if let maxConcurrentRequests = configuration.maximumConcurrentRequests {
            queue.maxConcurrentOperationCount = maxConcurrentRequests
        }
        return queue
    }()

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

extension URLSessionNetwork: Network {
    
    public func add(action: Action) {
        actions.append(action)
    }

    @discardableResult
    public func send<T: Request>(_ request: T, withPriority priority: Priority, completion: ((Result<T.Response, Error>) -> Void)?) -> Cancellable {
        let operation = NetworkOperation(encoder: encoder, session: session)
        operation.queuePriority = priority
        
        operation.requestSetup = { [weak self] in
            guard let self = self else { return }
            
            var networkRequest = request.buildRequest(with: self.configuration.baseURL)
            networkRequest.customProperties = request.customProperties

            self.requestWillBegin(networkRequest) { result in
                switch result {
                case .failure(let error):
                    completion?(.failure(error))
                case .success(let networkRequest):
                    guard !operation.isCancelled else {
                        /// Request should begin (result is success) but it has already been cancelled. This is because there was some
                        /// asynchronous action that took place during some action's `requestWillBegin` before calling the completion,
                        /// meaning the operation failed to start and the request should be resent.
                        self.send(request, withPriority: priority, completion: completion)
                        return
                    }
                    operation.request = networkRequest
                    self.requestBegan(networkRequest)
                }
            }
        }
            
        operation.requestCompletion = { [weak self] networkRequest, data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion?(.failure(error))
                return
            }
            
            let response = NetworkResponse(
                response: response as? HTTPURLResponse ?? .init(),
                data: data
            )
            
            self.responseBegan(request: networkRequest, response: response)
            self.responseCompleted(request: networkRequest, response: response) { result in
                switch result {
                case .failure(let error):
                    completion?(.failure(error))
                case .success(let response):
                    do {
                        guard let data = response.data else { throw NetworkError.noData }
                        completion?(.success(try request.response(from: data, with: self.decoder)))
                    } catch {
                        completion?(.failure(error))
                    }
                }
            }
        }

        requestQueue.addOperation(operation)
        return operation
    }
}

extension URLSessionNetwork: RequestWillBeginAction {
    public func requestWillBegin(_ request: NetworkRequest, completion: @escaping RequestCompletion) {
        actions
            .compactMap { $0 as? RequestWillBeginAction }
            .requestWillBegin(request, completion: completion)
    }
}

extension URLSessionNetwork: RequestBeganAction {
    public func requestBegan(_ request: NetworkRequest) {
        actions
            .compactMap { $0 as? RequestBeganAction }
            .forEach { $0.requestBegan(request) }
    }
}

extension URLSessionNetwork: ResponseBeganAction {
    public func responseBegan(request: NetworkRequest, response: NetworkResponse) {
        actions
            .compactMap { $0 as? ResponseBeganAction }
            .forEach { $0.responseBegan(request: request, response: response) }
    }
}

extension URLSessionNetwork: ResponseCompletedAction {
    public func responseCompleted(request: NetworkRequest, response: NetworkResponse, completion: @escaping ResponseCompletion) {
        actions
            .compactMap { $0 as? ResponseCompletedAction }
            .responseCompleted(request: request, response: response, completion: completion)
    }
}
