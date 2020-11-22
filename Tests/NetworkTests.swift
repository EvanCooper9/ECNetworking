import ECNetworking
import XCTest

final class NetworkTests: XCTestCase {
    
    private enum Error: Swift.Error {
        case any
    }
    
    private var session: MockURLSession!
    private var network: Network!
    
    override func setUp() {
        super.setUp()
        session = MockURLSession()
        network = Network(configuration: .mock, session: session)
    }
    
    func testThatActionCanBeAdded() {
        let action = MockAction()
        network.add(action: action)
        network.send(MockRequest())
        
        XCTAssertTrue(action.requestWillBegin)
        XCTAssertTrue(action.requestBegan)
        XCTAssertTrue(action.responseBegan)
        XCTAssertTrue(action.responseCompleted)
    }
    
    func testThatRequestWillBeginErrorStopsRequestFromBeingSent() {
        let action = MockAction(requestWillBeginError: Error.any)
        network.add(action: action)
        let task = network.send(MockRequest(), completion: nil)
        
        XCTAssertTrue(action.requestWillBegin)
        XCTAssertFalse(action.requestBegan)
        XCTAssertNil(task)
    }
    
    func testThatResponseCompletedErrorIsReported() {
        let expectation = self.expectation(description: #function)
        
        let expectedError = Error.any
        let action = MockAction(responseCompletedError: expectedError)
        network.add(action: action)
        
        network.send(.mock) { result in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error as? Error, expectedError)
                expectation.fulfill()
            case .success:
                return
            }
        }
        
        XCTAssertTrue(action.requestWillBegin)
        XCTAssertTrue(action.requestBegan)
        XCTAssertTrue(action.responseBegan)
        XCTAssertTrue(action.responseCompleted)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testThatRequestIsSent() {
        let expectation = self.expectation(description: #function)
        
        network.send(MockRequest()) { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testThatNetworkRequestIsSent() {
        let expectation = self.expectation(description: #function)
        
        network.send(.mock) { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testThatURLSessionErrorIsReported() {
        let expectation = self.expectation(description: #function)
        
        let expectedError = Error.any
        session.error = expectedError
        
        network.send(.mock) { result in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error as? Error, expectedError)
                expectation.fulfill()
            case .success:
                return
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testThatNoDataFromURLSessionErrorIsReported() {
        let expectation = self.expectation(description: #function)
        
        network.send(MockRequest()) { result in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error as? NetworkError, .noData)
                expectation.fulfill()
            case .success:
                return
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testThatRequestsSucceed() {
        let expectation = self.expectation(description: #function)
        expectation.expectedFulfillmentCount = 2
        
        session.data = Data()
        
        network.send(MockRequest()) { result in
            switch result {
            case .failure(let error):
                XCTFail(error.localizedDescription)
            case .success:
                expectation.fulfill()
            }
        }
        
        network.send(.mock) { result in
            switch result {
            case .failure(let error):
                XCTFail(error.localizedDescription)
            case .success:
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
}
