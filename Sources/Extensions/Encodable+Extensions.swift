import Foundation

extension Encodable {
    func encoded(using encoder: JSONEncoder = .init()) throws -> Data {
        try encoder.encode(self)
    }
}
