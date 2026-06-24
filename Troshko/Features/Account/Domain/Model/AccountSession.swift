import Foundation

struct AccountSession: Codable, Equatable {
    let userIdentifier: String
    let displayName: String?
    let email: String?
    let signedInAt: Date
}

