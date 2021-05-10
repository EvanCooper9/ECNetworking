import XCTest

@testable import ECNetworking

final class URLSessionNetworkTests: XCTestCase {
    
    private enum Error: Swift.Error {
        case any
    }
    
    private var session: MockURLSession!
    private var network: URLSessionNetwork!
    
    override func setUp() {
        super.setUp()
        session = MockURLSession()
        network = URLSessionNetwork(configuration: .mock, session: session)
    }
    
    func testThatActionCanBeAdded() {
        let action = MockAction()
        network.add(action: action)
        network.send(MockVoidRequest()) { _ in
            XCTAssertTrue(action.requestWillBegin)
            XCTAssertTrue(action.requestBegan)
            XCTAssertTrue(action.responseBegan)
            XCTAssertTrue(action.responseCompleted)
        }
    }
    
    func testThatRequestWillBeginErrorStopsRequestFromBeingSent() {
        let action = MockAction(requestWillBeginError: Error.any)
        network.add(action: action)
        
        network.send(MockVoidRequest()) { _ in
            XCTAssertTrue(action.requestWillBegin)
            XCTAssertFalse(action.requestBegan)
        }
    }
    
    func testThatResponseCompletedErrorIsReported() {
        let expectation = self.expectation(description: #function)
        
        let expectedError = Error.any
        let action = MockAction(responseCompletedError: expectedError)
        network.add(action: action)
        
        network.send(MockVoidRequest()) { result in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error as? Error, expectedError)
                XCTAssertTrue(action.requestWillBegin)
                XCTAssertTrue(action.requestBegan)
                XCTAssertTrue(action.responseBegan)
                XCTAssertTrue(action.responseCompleted)
                expectation.fulfill()
            case .success:
                return
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testThatRequestIsSent() {
        let expectation = self.expectation(description: #function)
        
        network.send(MockVoidRequest()) { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testThatURLSessionErrorIsReported() {
        let expectation = self.expectation(description: #function)
        
        let expectedError = Error.any
        session.error = expectedError
        
        network.send(MockVoidRequest()) { result in
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
        
        network.send(MockDataRequest()) { result in
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
    
    func testThatRequestSucceeds() {
        let expectation = self.expectation(description: #function)
        
        session.data = Data()
        
        network.send(MockVoidRequest()) { result in
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
