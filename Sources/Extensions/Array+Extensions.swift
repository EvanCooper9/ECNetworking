import Foundation

extension Array: Action {}

extension Array: RequestWillBeginAction where Element == RequestWillBeginAction {
    public func requestWillBegin(_ request: NetworkRequest, completion: @escaping RequestCompletion) {
        guard let first = first else {
            completion(.success(request))
            return
        }
        
        first.requestWillBegin(request) { result in
            switch result {
            case .failure:
                completion(result)
            case .success(let request):
                let remaining = Array(self.dropFirst())
                remaining.requestWillBegin(request, completion: completion)
            }
        }
    }
}

extension Array: ResponseCompletedAction where Element == ResponseCompletedAction {
    public func responseCompleted(request: NetworkRequest, response: NetworkResponse, completion: @escaping ResponseCompletion) {
        guard let first = first else {
            completion(.success(response))
            return
        }

        first.responseCompleted(request: request, response: response) { result in
            switch result {
            case .failure:
                completion(result)
            case .success(let response):
                let remaining = Array(self.dropFirst())
                remaining.responseCompleted(request: request, response: response, completion: completion)
            }
        }
    }
}
