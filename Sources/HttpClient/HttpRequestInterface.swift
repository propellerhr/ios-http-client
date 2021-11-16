import Foundation

public protocol HttpRequestInterface {
    associatedtype Body: Encodable

    var method: HttpMethod { get }
    var path: String { get }
    var query: String? { get }
    var body: Body? { get }
    var shouldUseBaseUrl: Bool { get }

    // Headers
    var authorization: String? { get }
    var contentType: String { get }
    var accept: String { get }
}

public class EmptyHttpRequestBody: Encodable {}

public extension HttpRequestInterface {

    var body: Body? { nil }
    var query: String? { nil }
    var shouldUseBaseUrl: Bool { true }
    var authorization: String? { nil }
    var contentType: String { "application/json" }
    var accept: String { "application/json" }

    func urlRequest(withBaseUrl url: URL) -> URLRequest {
        guard let url = generateUrl(withBaseUrl: shouldUseBaseUrl ? url : nil) else {
            fatalError("Could not create an URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue.uppercased()
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        request.addValue(accept, forHTTPHeaderField: "Accept")

        if let authorization = authorization {
            request.addValue(authorization, forHTTPHeaderField: "Authorization")
        }

        if let body = body, [HttpMethod.post, HttpMethod.put].contains(method) {
            let serializedBody = try? JSONEncoder().encode(body)
            request.httpBody = serializedBody
        }

        return request
    }

    private func generateUrl(withBaseUrl url: URL?) -> URL? {
        var components: URLComponents?
        if let baseUrl = url {
            components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
            components?.path += path
        } else {
            components = URLComponents(string: path)
        }

        let encodedQuery = query?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        components?.percentEncodedQuery = encodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return components?.url
    }

}
