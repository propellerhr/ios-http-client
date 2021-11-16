import Foundation

public struct HttpClientConfiguration {
    var baseUrl: URL

    public init(baseURL: URL) {
        self.baseUrl = baseURL
    }
}
