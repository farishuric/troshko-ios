import Foundation

public final class StandardNetworkProvider: NetworkProvider {
    private let baseURL: URL?
    private let session: URLSession
    private let interceptor: NetworkInterceptor?
    private let logger: NetworkLogger?

    public init(
        baseURL: URL?,
        session: URLSession = .shared,
        interceptor: NetworkInterceptor? = nil,
        logger: NetworkLogger? = nil
    ) {
        self.baseURL = baseURL
        self.session = session
        self.interceptor = interceptor
        self.logger = logger
    }

    // MARK: - NetworkProvider

    public func request<T: Decodable>(_ request: NetworkRequest) async throws -> T {
        let data = try await makeRequest(request)
        do {
            let envelope = try JSONDecoder.api.decode(APIEnvelope<T>.self, from: data)
            guard envelope.isSuccess else {
                throw NetworkError.apiError(envelope.errors ?? [])
            }
            guard let payload = envelope.data else {
                throw NetworkError.noData
            }
            return payload
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    public func request(_ request: NetworkRequest) async throws {
        let data = try await makeRequest(request)
        do {
            let envelope = try JSONDecoder.api.decode(APIEnvelope<Empty>.self, from: data)
            guard envelope.isSuccess else {
                throw NetworkError.apiError(envelope.errors ?? [])
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    public func get(url: String,
                    headers: [String: String]? = nil,
                    queryParameters: [String: String]? = nil) async throws -> Data
    {
        guard var urlComponents = URLComponents(string: url) else {
            throw NetworkError.invalidURL
        }
        if let queryParameters {
            urlComponents.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let finalURL = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        urlRequest.allHTTPHeaderFields = headers
        return try await perform(urlRequest)
    }

    // MARK: - Private

    private static let platformHeaders: [String: String] = ["x-platform": "iOS"]

    private func makeRequest(_ request: NetworkRequest) async throws -> Data {
        guard let baseURL else { throw NetworkError.invalidURL }
        let rawURL = baseURL.appendingPathComponent(request.path)
        let finalURL: URL
        if let params = request.queryParameters, !params.isEmpty,
           var components = URLComponents(url: rawURL, resolvingAgainstBaseURL: false) {
            components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
            guard let url = components.url else { throw NetworkError.invalidURL }
            finalURL = url
        } else {
            finalURL = rawURL
        }
        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = Self.platformHeaders.merging(request.headers) { _, requestValue in requestValue }
        urlRequest.httpBody = request.body
        return try await perform(urlRequest)
    }

    /// Executes `urlRequest`, handling auth adaptation and 401 retry, and returns
    /// the raw response body regardless of HTTP status code. Envelope-level error
    /// checking happens in the callers so the error body is always available.
    private func perform(_ urlRequest: URLRequest) async throws -> Data {
        let adapted = try await interceptor?.adapt(urlRequest) ?? urlRequest
        logger?.logRequest(adapted)

        let (data, response) = try await session.data(for: adapted)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        logger?.logResponse(httpResponse, data: data, for: adapted)

        if httpResponse.statusCode == 401, let interceptor {
            if let retried = try await interceptor.retry(adapted, dueTo: httpResponse, data: data) {
                let finalRequest = try await interceptor.adapt(retried)
                logger?.logRequest(finalRequest)
                let (retryData, retryResponse) = try await session.data(for: finalRequest)
                guard let retryHTTP = retryResponse as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                logger?.logResponse(retryHTTP, data: retryData, for: finalRequest)
                return retryData
            }
        }

        return data
    }
}
