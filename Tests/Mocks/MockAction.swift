import ECNetworking
import Foundation

final class MockAction: Action {
    private(set) var requestWillBegin = false
    private(set) var requestBegan = false
    private(set) var responseBegan = false
    private(set) var responseCompleted = false
    
    private let requestWillBeginError: Error?
    private let responseCompletedError: Error?
    
    init(requestWillBeginError: Error? = nil, responseCompletedError: Error? = nil) {
        self.requestWillBeginError = requestWillBeginError
        self.responseCompletedError = responseCompletedError
    }
}

extension MockAction: RequestWillBeginAction {
    func requestWillBegin(_ request: NetworkRequest, completion: @escaping RequestCompletion) {
        requestWillBegin = true

        if let error = requestWillBeginError {
            completion(.failure(error))
        } else {
            completion(.success(request))
        }
    }
}

extension MockAction: RequestBeganAction {
    func requestBegan(_ request: NetworkRequest) {
        requestBegan = true
    }
}

extension MockAction: ResponseBeganAction {
    func responseBegan(request: NetworkRequest, response: NetworkResponse) {
        responseBegan = true
    }
}

extension MockAction: ResponseCompletedAction {
    func responseCompleted(request: NetworkRequest, response: NetworkResponse, completion: @escaping ResponseCompletion) {
        responseCompleted = true
        
        if let error = responseCompletedError {
            completion(.failure(error))
        } else {
            completion(.success(response))
        }
    }
}
