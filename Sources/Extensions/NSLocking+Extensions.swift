import Foundation

extension NSLocking {
    func synchronize<T>(block: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try block()
    }
}
