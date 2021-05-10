import Foundation

public final class NetworkOperation: AsynchronousOperation {

    var requestSetup: (() -> Void)?
    var requestCompletion: ((NetworkRequest, Data?, URLResponse?, Error?) -> ())?
    
    var request: NetworkRequest?
    
    private var session: URLSession
    private var encoder: JSONEncoder
    private var task: URLSessionTask?
    
    init(encoder: JSONEncoder, session: URLSession) {
        self.session = session
        self.encoder = encoder
    }

    public override func main() {
        requestSetup?()
        
        guard let networkRequest = request else {
            cancel()
            return
        }
        
        task = session.dataTask(with: networkRequest.asURLRequest(with: encoder))  { [weak self] data, response, error in
            guard let self = self else { return }
            self.requestCompletion?(networkRequest, data, response, error)
            self.complete()
        }
        
        task?.resume()
    }

    public override func cancel() {
        task?.cancel()
        super.cancel()
        complete()
    }
}

extension NetworkOperation: Cancellable {}
