extension Array where Element == RequestAction {
    func requestWillBegin(with request: URLRequest, completion: (Result<URLRequest, Error>) -> Void) {
        guard let first = first else {
            completion(.success(request))
            return
        }
        
        first.requestWillBegin(request) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let request):
                let remaining = Array(dropFirst())
                remaining.requestWillBegin(with: request, completion: completion)
            }
        }
    }
}

extension Array where Element == ResponseAction {
    func responseReceived<T: Request>(sender: Networking, request: T, responseBody: T.Response, response: HTTPURLResponse, completion: @escaping (Result<T.Response, Error>) -> Void) {
        guard let first = first else {
            completion(.success(responseBody))
            return
        }
        
        first.responseReceived(sender: sender, request: request, responseBody: responseBody, response: response) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let newResponseBody):
                let remaining = Array(self.dropFirst())
                remaining.responseReceived(sender: sender, request: request, responseBody: newResponseBody, response: response, completion: completion)
            }
        }
    }
}
