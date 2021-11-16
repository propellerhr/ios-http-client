import Foundation
import RxSwift

public protocol HttpClientInterface {
    func perform<Model: Decodable, Request: HttpRequestInterface>(request: Request) -> Single<Model>
}

public class HttpClient: HttpClientInterface {

    public static var shared: HttpClient {
        guard let shared = _shared else {
            fatalError("HttpClient not initialized. Please call HttpClient.initialize(configuration:) before using it.")
        }

        return shared
    }

    private static var _shared: HttpClient?

    private let baseUrl: URL
    private let session = URLSession.shared
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    public static func initialize(configuration: HttpClientConfiguration) {
        _shared = HttpClient(configuration: configuration)
    }

    private init(configuration: HttpClientConfiguration) {
        self.baseUrl = configuration.baseUrl
        print("HttpClient inited")
    }

    public func perform<Model, Request>(request: Request) -> PrimitiveSequence<SingleTrait, Model> where Model: Decodable, Request: HttpRequestInterface {
        return Single<Model>.create { [weak self] single in
            guard let `self` = self else {
                return Disposables.create {}
            }

            let urlRequest = request.urlRequest(withBaseUrl: self.baseUrl)
            let task = self.session.dataTask(with: urlRequest) { data, response, error in

                if let error = error {
                    single(.failure(error))
                    return
                }

                guard let response = response as? HTTPURLResponse else {
                    single(.failure(HttpClientError.notHTTPResponse))
                    return
                }

                let statusCode = response.statusCode

                if(200..<300).contains(statusCode) {
                    if let data = data, let model = try? self.jsonDecoder.decode(Model.self, from: data) {
                        single(.success(model))
                    } else {
                        single(.failure(HttpClientError.invalidResponse))
                    }
                } else {
                    single(.failure(HttpClientError.serverError(statusCode: statusCode, message: HTTPURLResponse.localizedString(forStatusCode: statusCode))))
                }
            }

            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
}

