import Foundation

/// A single error entry returned inside the API error envelope.
///
/// The backend sends either lowercase (`code`, `message`) or PascalCase
/// (`Code`, `Message`) keys depending on the endpoint. Both are handled here.
public struct APIError: Decodable, Sendable, Equatable {
    public let code: Int
    public let message: String

    private enum Lower: String, CodingKey { case code, message }
    private enum Upper: String, CodingKey { case code = "Code", message = "Message" }

    public init(from decoder: any Decoder) throws {
        if let c = try? decoder.container(keyedBy: Lower.self), c.contains(.code) {
            code = try c.decode(Int.self, forKey: .code)
            message = try c.decode(String.self, forKey: .message)
        } else {
            let c = try decoder.container(keyedBy: Upper.self)
            code = try c.decode(Int.self, forKey: .code)
            message = try c.decode(String.self, forKey: .message)
        }
    }
}
