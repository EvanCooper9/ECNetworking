import ECNetworking

enum AuthenticationError: Error {
    case missing
    case failed
}

struct AuthenticationAction {
    
    private let userDefauls: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefauls = userDefaults
    }
}

extension AuthenticationAction: RequestAction {
    func requestWillBegin(_ request: URLRequest, completion: RequestActionClosure) {
        var request = request
        var headers = request.allHTTPHeaderFields ?? [:]
        if !headers.keys.contains(CommonHeaders.authentication) {
            headers[CommonHeaders.authentication] = String(describing: userDefauls.authentication)
            request.allHTTPHeaderFields = headers
        }
        completion(.success(request))
    }
}

extension AuthenticationAction: ResponseAction {
    func responseReceived<T: Request>(sender: Networking, request: T, responseBody: T.Response, response: HTTPURLResponse, completion: @escaping ResponseActionClosure<T>) {
        
        guard let sampleGetReponseBody = responseBody as? SampleGetResponse else {
            completion(.success(responseBody))
            return
        }
        
        let authenticated = sampleGetReponseBody.headers
            .first { $0.key == CommonHeaders.authentication }
            .map { $0.value.boolValue } ?? false
        
        
        guard !authenticated else {
            completion(.success(responseBody))
            return
        }

        sender.send(AuthenticationRequest()) { result in
            switch result {
            case .failure:
                completion(.failure(AuthenticationError.failed))
            case .success:
                // Authentication successful. Resend the original request.
                self.userDefauls.authentication = true
                sender.send(request) { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let newResponse):
                        completion(.success(newResponse))
                    }
                }
            }
        }
    }
}

private extension String {
    var boolValue: Bool { (self as NSString).boolValue }
}
