/// Asynchronous Operation base class
///
/// This class performs all of the necessary KVN of `isFinished` and
/// `isExecuting` for a concurrent `NSOperation` subclass. So, to develop
/// a concurrent NSOperation subclass, you instead subclass this class which:
///
/// - must override `main()` with the tasks that initiate the asynchronous task;
///
/// - must call `complete()` function when the asynchronous task is done;
///
/// - optionally, periodically check `self.cancelled` status, performing any clean-up
///   necessary and then ensuring that `complete()` is called; or
///   override `cancel` method, calling `super.cancel()` and then cleaning-up
///   and ensuring `complete()` is called.

import Foundation

public class AsynchronousOperation : Operation {

    override public var isAsynchronous: Bool { true }

    private let lock = NSLock()

    private var _executing: Bool = false
    override private(set) public var isExecuting: Bool {
        get {
            lock.synchronize { _executing }
        }
        set {
            willChangeValue(for: \.isExecuting)
            lock.synchronize { _executing = newValue }
            didChangeValue(for: \.isExecuting)
        }
    }

    private var _finished: Bool = false
    override private(set) public var isFinished: Bool {
        get {
            lock.synchronize { _finished }
        }
        set {
            willChangeValue(for: \.isFinished)
            lock.synchronize { _finished = newValue }
            didChangeValue(for: \.isFinished)
        }
    }

    public func complete() {
        if isExecuting {
            isExecuting = false
            isFinished = true
        }
    }
    
    override public func start() {
        guard !isCancelled else {
            isFinished = true
            return
        }

        isExecuting = true

        main()
    }
}
