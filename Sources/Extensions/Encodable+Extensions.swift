import Foundation

extension Encodable {
    public func encoded(using encoder: JSONEncoder = .init()) throws -> Data {
        try encoder.encode(self)
    }
}
