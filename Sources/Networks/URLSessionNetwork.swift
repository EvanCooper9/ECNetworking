import Foundation

public final class URLSessionNetwork {
    
    // MARK: - Private Properties
    
    private var actions: [Action]
    private var configuredActions: [Action] {
        var configuredActions = actions
        if let loggingAction {
            configuredActions.append(loggingAction)
        }
        return configuredActions
    }
    private var loggingAction: LoggingAction?

    private let configuration: NetworkConfiguration
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let session: URLSession
    
    private lazy var requestQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount =
            configuration.maximumConcurrentRequests ??
            OperationQueue.defaultMaxConcurrentOperationCount
        return queue
    }()
    
    private lazy var decodingQueue: DispatchQueue = {
        .init(
            label: "com.evancooper.ECNetworking.decoding",
            attributes: .concurrent
        )
    }()

    // MARK: - Lifecycle
    
    public init(actions: [Action] = [], configuration: NetworkConfiguration, decoder: JSONDecoder = .init(), encoder: JSONEncoder = .init(), session: URLSession = .shared) {
        self.actions = actions
        self.configuration = configuration
        self.decoder = decoder
        self.encoder = encoder
        self.session = session
        
        if configuration.logging {
            loggingAction = LoggingAction(encoder: encoder)
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
                    operation.request = networkRequest
                    defer { self.requestBegan(networkRequest) }
                    
                    if operation.isCancelled, let newOperation = operation.copy() as? NetworkOperation {
                        /// Request should begin (result is success) but it has already been cancelled. This is because there was some
                        /// asynchronous work that took place during an action's `requestWillBegin` before calling the completion.
                        /// This causes operation to be cancelled when starting and the request should be resent. We can't send re-queue
                        /// an operation that has previously been cancelled, so we should create a copy and queue it.
                        newOperation.requestSetup = nil
                        self.requestQueue.addOperation(newOperation)
                    }
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
                    self.decodingQueue.async {
                        do {
                            guard let data = response.data else { throw NetworkError.noData }
                            completion?(.success(try request.response(from: data, with: self.decoder)))
                        } catch {
                            completion?(.failure(error))
                        }
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
        configuredActions
            .compactMap { $0 as? RequestWillBeginAction }
            .requestWillBegin(request, completion: completion)
    }
}

extension URLSessionNetwork: RequestBeganAction {
    public func requestBegan(_ request: NetworkRequest) {
        configuredActions
            .compactMap { $0 as? RequestBeganAction }
            .forEach { $0.requestBegan(request) }
    }
}

extension URLSessionNetwork: ResponseBeganAction {
    public func responseBegan(request: NetworkRequest, response: NetworkResponse) {
        configuredActions
            .compactMap { $0 as? ResponseBeganAction }
            .forEach { $0.responseBegan(request: request, response: response) }
    }
}

extension URLSessionNetwork: ResponseCompletedAction {
    public func responseCompleted(request: NetworkRequest, response: NetworkResponse, completion: @escaping ResponseCompletion) {
        configuredActions
            .compactMap { $0 as? ResponseCompletedAction }
            .responseCompleted(request: request, response: response, completion: completion)
    }
}
