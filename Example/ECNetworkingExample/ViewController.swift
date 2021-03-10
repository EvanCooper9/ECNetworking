import ECNetworking
import UIKit

class ViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet private var logTextView: UITextView!
    
    // MARK: - Private Properties
    
    private lazy var network: Networking = {
        let configuration = NetworkConfiguration(
            baseURL: URL(string: "https://postman-echo.com")!,
            logging: true
        )
        
        let network = Network(configuration: configuration)
        network.add(action: AuthenticationAction(network: network))
        network.add(action: self)
        return network
    }()
    
    private let userDefaults: UserDefaults = .standard
    
    // MARK: - Actions
    
    @IBAction private func sendRequestButtonTapped(_ sender: Any) {
        addToLogTextView("Sending request...")
        addToLogTextView("Authenticated: \(userDefaults.authenticated)")
        network.send(SomeRequest()) { [weak self] _ in
            self?.addToLogTextView("Reqest completed\n")
        }
    }
    
    @IBAction private func clearAuthButtonTapped(_ sender: Any) {
        userDefaults.authenticated = false
    }
    
    @IBAction private func clearLogTapped(_ sender: Any) {
        logTextView.text = nil
    }
    
    // MARK: - Private Methods
    
    private func addToLogTextView(_ string: String) {
        DispatchQueue.main.async { [weak self] in
            self?.logTextView.text.append(string + "\n")
        }
    }
}

extension ViewController: ResponseBeganAction {
    func responseBegan(request: NetworkRequest, response: NetworkResponse) {
        guard let requestName = request.requestName else { return }
        addToLogTextView(" - Response for \(requestName)")
    }
}
