import ECNetworking
import UIKit

class ViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet private var logTextView: UITextView!
    
    // MARK: - Private Properties
    
    private let userDefaults: UserDefaults = .standard
    
    private lazy var network: Network = {
        let configuration = NetworkConfiguration(
            baseURL: URL(string: "https://postman-echo.com")!,
            logging: false
        )
        
        let network = URLSessionNetwork(configuration: configuration)
        network.add(action: AuthenticationAction(network: network, userDefaults: userDefaults))
        network.add(action: self)
        return network
    }()
    
    // MARK: - Actions
    
    @IBAction private func sendRequestTapped(_ sender: Any) {
        sendRequest()
    }
    
    @IBAction private func sendMultipleRequestsTapped(_ sender: Any) {
        (0..<10).forEach { request in
            sendRequest(number: request)
        }
    }
    
    @IBAction private func clearAuthTapped(_ sender: Any) {
        userDefaults.authenticated = false
    }
    
    @IBAction private func clearLogTapped(_ sender: Any) {
        logTextView.text = nil
        logTextView.contentOffset = .zero
    }
    
    // MARK: - Private Methods
    
    private func sendRequest(number: Int? = nil) {
        addToLogTextView("Starting request\(number?.description ?? "")...")
        network.send(SomeRequest()) { [weak self] _ in
            self?.addToLogTextView("Reqest\(number?.description ?? "") completed")
        }
    }
    
    private func addToLogTextView(_ string: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.logTextView.text.append(string + "\n")
            
            let diff = self.logTextView.bounds.height - self.logTextView.contentSize.height
            if diff < 0 {
                self.logTextView.contentOffset = CGPoint(x: 0, y: -diff)
            }
        }
    }
}

extension ViewController: RequestBeganAction {
    func requestBegan(_ request: NetworkRequest) {
        guard let requestName = request.requestName else { return }
        let logs = [
            "Authenticated: \(userDefaults.authenticated)",
            " - Request for \(requestName)"
        ]
        addToLogTextView(logs.joined(separator: "\n"))
    }
}

extension ViewController: ResponseBeganAction {
    func responseBegan(request: NetworkRequest, response: NetworkResponse) {
        guard let requestName = request.requestName else { return }
        addToLogTextView(" - Response for \(requestName)")
    }
}
