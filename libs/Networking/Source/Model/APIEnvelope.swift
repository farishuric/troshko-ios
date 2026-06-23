import Foundation

/// The standard response wrapper every API endpoint returns.
///
/// The backend inconsistently uses either lowercase (`code`, `data`, `errors`)
/// or PascalCase (`Code`, `Data`, `Errors`) keys. Both forms are decoded here.
struct APIEnvelope<T: Decodable>: Decodable {
    let code: Int
    let data: T?
    let errors: [APIError]?

    var isSuccess: Bool { code == 0 }

    private enum Lower: String, CodingKey { case code, data, errors }
    private enum Upper: String, CodingKey { case code = "Code", data = "Data", errors = "Errors" }

    init(from decoder: any Decoder) throws {
        if let c = try? decoder.container(keyedBy: Lower.self), c.contains(.code) {
            code = try c.decode(Int.self, forKey: .code)
            data = try c.decodeIfPresent(T.self, forKey: .data)
            errors = try c.decodeIfPresent([APIError].self, forKey: .errors)
        } else {
            let c = try decoder.container(keyedBy: Upper.self)
            code = try c.decode(Int.self, forKey: .code)
            data = try c.decodeIfPresent(T.self, forKey: .data)
            errors = try c.decodeIfPresent([APIError].self, forKey: .errors)
        }
    }
}

// Used when a successful response carries no data payload (e.g. logout, cancel).
struct Empty: Decodable {}

extension JSONDecoder {
    /// Shared decoder for all API responses. Uses snake_case → camelCase conversion
    /// for data-layer DTOs; the envelope itself is handled via explicit CodingKeys.
    static let api: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()
}
