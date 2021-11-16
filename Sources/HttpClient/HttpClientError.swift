import Foundation

enum HttpClientError: Error {
    case unknown
    case invalidResponse
    case notHTTPResponse
    case serverError(statusCode: Int, message: String)

    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "error.http.unknown".localized
        case .invalidResponse:
            return "error.http.invalidResponse".localized
        case .notHTTPResponse:
            return "error.http.notHttpResponse".localized
        case .serverError(_, let message):
            return message
        }
    }
}

fileprivate extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
