import Foundation

public extension URL {
    func appendingQueryParameters(_ queryParameters: [String: CustomStringConvertible?]) -> Self {
        guard var urlComponents = URLComponents(string: self.absoluteString) else { return self }
        
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        queryParameters.forEach { key, value in
            guard let value = value else { return }
            let queryItem = URLQueryItem(name: key, value: value.description)
            queryItems.append(queryItem)
        }

        urlComponents.queryItems = queryItems
        return urlComponents.url!
    }
}
