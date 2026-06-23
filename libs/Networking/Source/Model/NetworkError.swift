import Foundation

public enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case encodingError(Error)
    /// The server returned a non-2xx status and the body was not a parseable API envelope.
    case serverError(statusCode: Int)
    /// The server returned a well-formed API envelope with a non-zero `code`.
    case apiError([APIError])
    case unknownError(Error)
}
